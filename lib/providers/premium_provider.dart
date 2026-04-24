import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PremiumPlan {
  final String id;
  final String name;
  final String price;
  final String period;
  final String description;
  final List<String> features;
  final bool isPopular;

  const PremiumPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    required this.description,
    required this.features,
    this.isPopular = false,
  });
}

class PremiumProvider extends ChangeNotifier {
  static const _appleApiKey = 'appl_api_key_here';
  static const _googleApiKey = 'goog_api_key_here';

  bool _isPremium = false;
  bool _isLoading = false;
  String _currentPlan = 'free';
  String? _userId;

  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  String get currentPlan => _currentPlan;

  PremiumProvider() {
    _initRevenueCat();
  }

  void updateUserId(String? uid) async {
    if (_userId != uid) {
      _userId = uid;
      if (_userId != null) {
        try {
          await Purchases.logIn(_userId!);
          _checkStatus();
        } catch (e) {
          debugPrint('RevenueCat login error: $e');
        }
      } else {
        await Purchases.logOut();
        _isPremium = false;
        _currentPlan = 'free';
        notifyListeners();
      }
    }
  }

  Future<void> _initRevenueCat() async {
    if (kIsWeb) return;

    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_googleApiKey);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_appleApiKey);
    }

    if (configuration != null) {
      await Purchases.configure(configuration);
      _checkStatus();
    }
  }

  Future<void> _checkStatus() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      _updateFromCustomerInfo(customerInfo);
    } catch (e) {
      debugPrint('Error fetching customer info: $e');
    }
  }

  void _updateFromCustomerInfo(CustomerInfo customerInfo) {
    final entitlement = customerInfo.entitlements.all["premium"];
    if (entitlement?.isActive == true) {
      _isPremium = true;
      _currentPlan = entitlement?.productIdentifier ?? 'premium';
    } else {
      _isPremium = false;
      _currentPlan = 'free';
    }
    notifyListeners();
  }

  static const List<PremiumPlan> plans = [
    PremiumPlan(
      id: 'premium_yearly',
      name: 'Premium',
      price: '₹199',
      period: '/year',
      description: 'Full Quran access + AI analysis',
      isPopular: true,
      features: [
        'Full Quran — 114 Surahs',
        '15 World-class Qaris',
        'Advanced AI — 25 rules',
        'Word-level feedback',
        'Hifz tools & revision plans',
        'Offline audio download',
        'Compare vs Sheikh waveform',
        'Ad-free experience',
        'Priority support',
      ],
    ),
    PremiumPlan(
      id: 'family_yearly',
      name: 'Family',
      price: '₹499',
      period: '/year',
      description: '3 users on one plan',
      features: [
        'All Premium features',
        'Up to 3 family members',
        'Shared progress dashboard',
        'Family leaderboard',
      ],
    ),
    PremiumPlan(
      id: 'lifetime',
      name: 'Lifetime',
      price: '\$29',
      period: 'one-time',
      description: 'Pay once, use forever',
      features: [
        'All Premium features forever',
        'All future updates',
        'Sheikh Pro trial (1 month)',
        'Exclusive badge',
      ],
    ),
    PremiumPlan(
      id: 'sheikh_pro',
      name: 'Sheikh Pro',
      price: '₹999',
      period: '/month',
      description: 'For verified scholars',
      features: [
        'Unlimited students',
        'Sheikh dashboard',
        'Digital Ijazah certificates',
        'Group classes (5 students)',
        'Parent progress reports',
        'Madrasa bulk import',
        'Priority listing',
      ],
    ),
  ];

  static bool isFeatureLocked(String featureId, bool isPremium) {
    const freeFeatures = {
      'juz30',
      'basic_tajwid',
      'streak',
      'progress',
      'noorani_qaida',
    };
    return !isPremium && !freeFeatures.contains(featureId);
  }

  Future<void> purchasePlan(String planId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        // Real purchase path using offerings
        final package = offerings.current!.availablePackages.firstWhere(
          (pkg) => pkg.storeProduct.identifier == planId,
          orElse: () => offerings.current!.availablePackages.first,
        );
        
        final purchaseResult = await Purchases.purchase(PurchaseParams.package(package));
        _updateFromCustomerInfo(purchaseResult.customerInfo);
      } else {
        // Fallback for demo/dev if offerings not set up
        final products = await Purchases.getProducts([planId]);
        if (products.isNotEmpty) {
          final purchaseResult = await Purchases.purchase(PurchaseParams.storeProduct(products.first));
          _updateFromCustomerInfo(purchaseResult.customerInfo);
        } else {
          // Final mock fallback
          await Future.delayed(const Duration(seconds: 2));
          _isPremium = true;
          _currentPlan = planId;
        }
      }
    } catch (e) {
      debugPrint('Purchase error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> restorePurchases() async {
    _isLoading = true;
    notifyListeners();

    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      _updateFromCustomerInfo(customerInfo);
    } catch (e) {
      debugPrint('Restore error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}

