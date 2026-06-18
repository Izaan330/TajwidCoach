import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/revenue_cat_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Premium Tier Enum
// ─────────────────────────────────────────────────────────────────────────────

enum PremiumTier {
  free,
  premium,
  family,
  lifetime,
  sheikhPro,
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Plan Model
// ─────────────────────────────────────────────────────────────────────────────

class PremiumPlan {
  final String id;
  final String name;
  final String price;
  final String period;
  final String description;
  final List<String> features;
  final bool isPopular;
  final PremiumTier tier;

  const PremiumPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    required this.description,
    required this.features,
    required this.tier,
    this.isPopular = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Gatable Feature IDs
// ─────────────────────────────────────────────────────────────────────────────

/// All features that can be gated behind premium.
/// The Quran itself (reading all 114 Surahs) is ALWAYS free.
class PremiumFeature {
  static const String advancedAI = 'advanced_ai';
  static const String allQaris = 'all_qaris';
  static const String hifzTools = 'hifz_tools';
  static const String offlineMode = 'offline_mode';
  static const String adFree = 'ad_free';
  static const String wordFeedback = 'word_feedback';
  static const String sheikhCompare = 'sheikh_compare';
  static const String streakFreezePurchase = 'streak_freeze_purchase';
  static const String familyLeaderboard = 'family_leaderboard';
  static const String sheikhUnlimitedStudents = 'sheikh_unlimited_students';
  static const String sheikhIjazah = 'sheikh_ijazah';
  static const String sheikhPriorityListing = 'sheikh_priority_listing';
  static const String premiumThemes = 'premium_themes';
  static const String premiumBadges = 'premium_badges';
  static const String unlimitedFreezes = 'unlimited_freezes';
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Provider
// ─────────────────────────────────────────────────────────────────────────────

class PremiumProvider extends ChangeNotifier {
  PremiumTier _tier = PremiumTier.free;
  bool _isLoading = false;
  String _currentPlanId = 'free';
  String? _userId;

  Future<void> updateUserId(String? uid) async {
    if (_userId == uid) return;
    _userId = uid;
    
    if (uid == null) {
      try {
        await _initRevenueCat();
        if (RevenueCatService.isConfigured) {
          await RevenueCatService.logOut();
        } else {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('mock_plan_id');
        }
      } catch (e) {
        debugPrint('RevenueCat logout error: $e');
      }
      _tier = PremiumTier.free;
      _currentPlanId = 'free';
      _familyCode = null;
      _familyMemberUids = [];
      _sheikhCredits = 0;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 1. RevenueCat Sync
      await _initRevenueCat();
      if (RevenueCatService.isConfigured) {
        await RevenueCatService.logIn(uid);
        final customerInfo = await RevenueCatService.getCustomerInfo();
        if (customerInfo != null) {
          _updateFromCustomerInfo(customerInfo);
        }
      } else {
        // Load mockPlanId from Firestore in development/mock mode
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (userDoc.exists) {
          final data = userDoc.data()!;
          final mockPlanId = data['mockPlanId'];
          if (mockPlanId != null) {
            _currentPlanId = mockPlanId;
            _tier = _tierFromPlanId(mockPlanId);
            
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('mock_plan_id', mockPlanId);
          }
        }
      }
      
      // 2. Fetch family/credits from Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        _sheikhCredits = data['sheikhCredits'] ?? 0;
        _familyCode = data['familyCode'];
        
        if (_familyCode != null) {
          final famDoc = await FirebaseFirestore.instance.collection('families').doc(_familyCode).get();
          if (famDoc.exists) {
            final famData = famDoc.data()!;
            _familyMemberUids = List<String>.from(famData['members'] ?? []);
            // If user is a member of a family, they get family tier benefits
            if (_tier == PremiumTier.free) {
              _tier = PremiumTier.family;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Premium sync error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Family Plan
  String? _familyCode;
  List<String> _familyMemberUids = [];

  // Premium Bridge — Sheikh credits & discounts
  int _sheikhCredits = 0; // ₹ credits for Sheikh sessions
  static const double sheikhDiscountPercent = 15.0; // 15% off for Premium

  // ─── Getters ──────────────────────────────────────────────────────────────

  PremiumTier get tier => _tier;
  bool get isPremium => _tier != PremiumTier.free;
  bool get isLoading => _isLoading;
  String get currentPlanId => _currentPlanId;
  String? get userId => _userId;

  // Convenience tier checks
  bool get isFree => _tier == PremiumTier.free;
  bool get isPremiumTier => _tier == PremiumTier.premium || _tier == PremiumTier.lifetime;
  bool get isFamilyPlan => _tier == PremiumTier.family;
  bool get isLifetime => _tier == PremiumTier.lifetime;
  bool get isSheikhPro => _tier == PremiumTier.sheikhPro;

  // Feature-level convenience getters
  bool get hasAdvancedAI => isPremium;
  bool get hasAllQaris => isPremium;
  bool get hasHifzTools => isPremium;
  bool get hasOfflineMode => isPremium;
  bool get hasAdFree => isPremium;
  bool get hasWordFeedback => isPremium;
  bool get hasSheikhCompare => isPremium;
  bool get hasPremiumThemes => isPremium;
  bool get hasPremiumBadges => isPremium;
  bool get canPurchaseStreakFreezes => isPremium;
  bool get hasFamilyLeaderboard => isFamilyPlan;
  bool get hasSheikhIjazah => isSheikhPro;
  bool get hasSheikhPriorityListing => isSheikhPro;

  // Family
  String? get familyCode => _familyCode;
  List<String> get familyMemberUids => _familyMemberUids;

  Future<void> generateFamilyCode() async {
    if (_userId == null || _tier != PremiumTier.family) return;
    
    // Simple 6-digit code
    final code = (DateTime.now().millisecondsSinceEpoch % 1000000)
        .toString()
        .padLeft(6, '0');
    
    _familyCode = code;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('families').doc(code).set({
        'ownerUid': _userId,
        'members': [_userId],
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      await FirebaseFirestore.instance.collection('users').doc(_userId).set({
        'familyCode': code,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error generating family code: $e');
    }
  }

  Future<bool> joinFamilyWithCode(String code) async {
    if (_userId == null) return false;

    try {
      final doc = await FirebaseFirestore.instance.collection('families').doc(code).get();
      if (!doc.exists) return false;

      final data = doc.data()!;
      final List members = List.from(data['members'] ?? []);
      
      if (members.length >= 3) {
        // Limit for Family plan is 3 members
        return false;
      }

      if (!members.contains(_userId)) {
        members.add(_userId);
        await FirebaseFirestore.instance.collection('families').doc(code).update({
          'members': members,
        });
      }

      await FirebaseFirestore.instance.collection('users').doc(_userId).set({
        'familyCode': code,
      }, SetOptions(merge: true));

      _familyCode = code;
      _tier = PremiumTier.family; // User gets family benefits
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error joining family: $e');
      return false;
    }
  }

  // Premium Bridge
  int get sheikhCredits => _sheikhCredits;

  int get maxFreezes {
    switch (_tier) {
      case PremiumTier.free: return 2;
      case PremiumTier.premium: return 5;
      case PremiumTier.family: return 10;
      case PremiumTier.lifetime: return 10;
      case PremiumTier.sheikhPro: return 999;
    }
  }

  /// Get the effective price for a Sheikh session after Premium discount.
  int getEffectiveSessionPrice(int basePrice) {
    if (!isPremium) return basePrice;
    return (basePrice * (1 - sheikhDiscountPercent / 100)).round();
  }

  // ─── Free Qari / Rule Limits ──────────────────────────────────────────────

  /// Number of Qaris available on the free tier.
  static const int freeQariCount = 3;

  /// IDs of the 3 free Qaris.
  static const List<String> freeQariIds = ['mishary', 'husary', 'sudais'];

  /// Number of Tajwid rules analyzed on the free tier.
  static const int freeRuleCount = 5;

  /// IDs of the 5 free Tajwid rules.
  static const List<String> freeRuleIds = [
    'ghunnah',
    'ikhfa',
    'idgham',
    'qalqalah',
    'madd',
  ];

  // ─── Feature Gating ───────────────────────────────────────────────────────

  /// Master feature-gating method. Returns `true` if the feature is LOCKED.
  static bool isFeatureLocked(String featureId, PremiumTier tier) {
    // All features are unlocked for paid tiers (except family-specific / sheikh-specific)
    if (tier != PremiumTier.free) {
      // Family-only features
      if (featureId == PremiumFeature.familyLeaderboard) {
        return tier != PremiumTier.family;
      }
      // Sheikh-Pro-only features
      if (featureId == PremiumFeature.sheikhIjazah ||
          featureId == PremiumFeature.sheikhPriorityListing ||
          featureId == PremiumFeature.sheikhUnlimitedStudents ||
          featureId == PremiumFeature.unlimitedFreezes) {
        return tier != PremiumTier.sheikhPro;
      }
      return false; // Everything else is unlocked for any paid tier
    }

    // Free tier — these features are always available:
    const freeFeatures = {
      'streak',
      'progress',
      'basic_tajwid',
      'noorani_qaida',
    };
    return !freeFeatures.contains(featureId);
  }

  /// Convenience: check if a feature is locked for the current user.
  bool isLocked(String featureId) => isFeatureLocked(featureId, _tier);

  /// Check if a specific Qari is available.
  bool isQariLocked(String qariId) {
    if (isPremium) return false;
    return !freeQariIds.contains(qariId);
  }

  // ─── Initialization ───────────────────────────────────────────────────────

  PremiumProvider() {
    _initRevenueCat();
  }

  Future<void>? _initFuture;

  Future<void> _initRevenueCat() {
    _initFuture ??= _doInitRevenueCat();
    return _initFuture!;
  }

  Future<void> _doInitRevenueCat() async {
    try {
      if (RevenueCatService.isConfigured) {
        await RevenueCatService.init();
      } else {
        await _loadLocalMockStatus();
      }
    } catch (e) {
      debugPrint('RevenueCat initialization error: $e');
      await _loadLocalMockStatus();
    }
  }

  Future<void> _loadLocalMockStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localPlanId = prefs.getString('mock_plan_id') ?? 'free';
      _currentPlanId = localPlanId;
      _tier = _tierFromPlanId(localPlanId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading local mock status: $e');
    }
  }



  void _updateFromCustomerInfo(CustomerInfo customerInfo) {
    debugPrint('PremiumProvider: _updateFromCustomerInfo called');
    debugPrint('PremiumProvider: All entitlements: ${customerInfo.entitlements.all}');
    
    // Look up entitlement checking both possible keys, with a fallback to any active entitlement
    final entitlement = customerInfo.entitlements.all["Quran Pro: Tajwid AI"] ??
        customerInfo.entitlements.all["premium"] ??
        (customerInfo.entitlements.active.isNotEmpty
            ? customerInfo.entitlements.active.values.first
            : null);

    debugPrint('PremiumProvider: Entitlement = ${entitlement?.toString()}');
    debugPrint('PremiumProvider: isActive = ${entitlement?.isActive}');
    debugPrint('PremiumProvider: productIdentifier = ${entitlement?.productIdentifier}');
    
    if (entitlement?.isActive == true) {
      final storeProductId = entitlement?.productIdentifier ?? 'tajwidcoach_premium_yearly';
      _currentPlanId = _storeProductIdToPlanId(storeProductId);
      _tier = _tierFromPlanId(_currentPlanId);
      debugPrint('PremiumProvider: Premium ACTIVE — tier=$_tier, planId=$_currentPlanId (Store Product ID: $storeProductId)');
    } else {
      _tier = PremiumTier.free;
      _currentPlanId = 'free';
      debugPrint('PremiumProvider: Premium INACTIVE — free tier');
    }
    notifyListeners();
  }

  String _storeProductIdToPlanId(String storeProductId) {
    if (storeProductId.contains('individual-yearly')) {
      return 'yearly';
    }
    if (storeProductId.contains('individual-monthly')) {
      return 'monthly';
    }
    if (storeProductId.contains('family-yearly')) {
      return 'family_yearly';
    }
    if (storeProductId.contains('family-monthly')) {
      return 'family_monthly';
    }
    switch (storeProductId) {
      case 'tajwidcoach_premium_yearly':
        return 'yearly';
      case 'tajwidcoach_premium_family':
        return 'family_yearly';
      case 'tajwidcoach_premium_lifetime':
        return 'lifetime';
      case 'tajwidcoach_sheikh_pro':
        return 'monthly_2';
      default:
        return storeProductId;
    }
  }

  PremiumTier _tierFromPlanId(String planId) {
    switch (planId) {
      case 'yearly':
      case 'monthly':
      case 'tajwidcoach_premium_yearly':
        return PremiumTier.premium;
      case 'family_yearly':
      case 'family_monthly':
      case 'tajwidcoach_premium_family':
        return PremiumTier.family;
      case 'lifetime':
      case 'tajwidcoach_premium_lifetime':
        return PremiumTier.lifetime;
      case 'monthly_2':
      case 'tajwidcoach_sheikh_pro':
        return PremiumTier.sheikhPro;
      default:
        return PremiumTier.premium;
    }
  }

  // ─── Plans ────────────────────────────────────────────────────────────────

  static const List<PremiumPlan> plans = [
    PremiumPlan(
      id: 'monthly',
      name: 'Premium Monthly',
      price: '₹29',
      period: '/month',
      tier: PremiumTier.premium,
      description: 'Full AI coaching + all Qaris',
      features: [
        'Advanced AI Engine — 25+ Tajwid rules',
        '15 World-class Qari audio',
        'Word-level mistake detection',
        'Hifz tools & revision plans',
        'Offline Quran & audio download',
        'Compare vs Sheikh waveform',
        'Extra streak freezes',
        'Premium Mushaf themes',
        'Ad-free experience',
        'Priority support',
      ],
    ),
    PremiumPlan(
      id: 'yearly',
      name: 'Premium Yearly',
      price: '₹199',
      period: '/year',
      tier: PremiumTier.premium,
      description: 'Save 40% with yearly billing',
      isPopular: true,
      features: [
        'Advanced AI Engine — 25+ Tajwid rules',
        '15 World-class Qari audio',
        'Word-level mistake detection',
        'Hifz tools & revision plans',
        'Offline Quran & audio download',
        'Compare vs Sheikh waveform',
        'Extra streak freezes',
        'Premium Mushaf themes',
        'Ad-free experience',
        'Priority support',
      ],
    ),
    PremiumPlan(
      id: 'family_monthly',
      name: 'Family Monthly',
      price: '₹79',
      period: '/month',
      tier: PremiumTier.family,
      description: 'Up to 3 users on one plan',
      features: [
        'All Premium features',
        'Up to 3 family members',
        'Shared family leaderboard',
        'Family progress dashboard',
        '15% off Sheikh sessions',
        '₹100 Sheikh credit / quarter',
      ],
    ),
    PremiumPlan(
      id: 'family_yearly',
      name: 'Family Yearly',
      price: '₹499',
      period: '/year',
      tier: PremiumTier.family,
      description: 'Save 45% with yearly billing',
      features: [
        'All Premium features',
        'Up to 3 family members',
        'Shared family leaderboard',
        'Family progress dashboard',
        '15% off Sheikh sessions',
        '₹100 Sheikh credit / quarter',
      ],
    ),
    PremiumPlan(
      id: 'lifetime',
      name: 'Lifetime',
      price: '\$29',
      period: 'one-time',
      tier: PremiumTier.lifetime,
      description: 'Pay once, use forever',
      features: [
        'All Premium features forever',
        'All future updates included',
        'Exclusive "Khadim al-Quran" badge',
        '15% off Sheikh sessions',
        '₹100 Sheikh credit / quarter',
      ],
    ),
    PremiumPlan(
      id: 'monthly_2',
      name: 'Sheikh Pro',
      price: '₹999',
      period: '/month',
      tier: PremiumTier.sheikhPro,
      description: 'For verified Sheikhs',
      features: [
        'Unlimited students',
        'Sheikh dashboard & analytics',
        'Digital Ijazah certificates',
        'Group classes (5 students)',
        'Parent progress reports',
        'Madrasa bulk import',
        'Priority listing in search',
      ],
    ),
  ];

  // ─── Purchase ─────────────────────────────────────────────────────────────

  Future<void> purchasePlan(String planId) async {
    debugPrint('PremiumProvider: purchasePlan("$planId") called. isConfigured=${RevenueCatService.isConfigured}');
    _isLoading = true;
    notifyListeners();

    try {
      // If we're using placeholder keys, skip RevenueCat and go to mock
      if (!RevenueCatService.isConfigured) {
        await Future.delayed(const Duration(seconds: 1));
        if (planId.startsWith('credits_')) {
          final amount = int.parse(planId.split('_')[1]);
          await addSheikhCredits(amount);
        } else {
          _currentPlanId = planId;
          _tier = _tierFromPlanId(planId);

          // Award Premium Bridge credits on upgrade
          if (_tier == PremiumTier.premium || _tier == PremiumTier.family || _tier == PremiumTier.lifetime) {
            _sheikhCredits += 100; // ₹100 initial credit
          }

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('mock_plan_id', planId);

          if (_userId != null) {
            await FirebaseFirestore.instance.collection('users').doc(_userId).set({
              'mockPlanId': planId,
              'sheikhCredits': _sheikhCredits,
            }, SetOptions(merge: true));
          }
        }
      } else {
        final customerInfo = await RevenueCatService.purchasePlan(planId);
        if (customerInfo != null) {
          if (planId.startsWith('credits_')) {
            final amount = int.parse(planId.split('_')[1]);
            await addSheikhCredits(amount);
          } else {
            _updateFromCustomerInfo(customerInfo);
          }
        }
      }
    } catch (e) {
      debugPrint('Purchase error: $e');
      // Even on error, if in dev mode, we can mock it
      if (!RevenueCatService.isConfigured) {
        if (planId.startsWith('credits_')) {
          final amount = int.parse(planId.split('_')[1]);
          await addSheikhCredits(amount);
        } else {
          _currentPlanId = planId;
          _tier = _tierFromPlanId(planId);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('mock_plan_id', planId);

          if (_userId != null) {
            await FirebaseFirestore.instance.collection('users').doc(_userId).set({
              'mockPlanId': planId,
            }, SetOptions(merge: true));
          }
        }
      } else {
        _isLoading = false;
        notifyListeners();
        rethrow;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> restorePurchases() async {
    debugPrint('PremiumProvider: restorePurchases() called. isConfigured=${RevenueCatService.isConfigured}');
    _isLoading = true;
    notifyListeners();

    try {
      await _initRevenueCat();
      if (RevenueCatService.isConfigured) {
        final customerInfo = await RevenueCatService.restorePurchases();
        if (customerInfo != null) {
          _updateFromCustomerInfo(customerInfo);
          return _tier != PremiumTier.free;
        }
        return false;
      } else {
        await Future.delayed(const Duration(seconds: 1));
        debugPrint('RevenueCat: Mock restore successful');

        if (_userId != null) {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(_userId).get();
          if (userDoc.exists) {
            final mockPlanId = userDoc.data()?['mockPlanId'];
            if (mockPlanId != null) {
              _currentPlanId = mockPlanId;
              _tier = _tierFromPlanId(mockPlanId);

              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('mock_plan_id', mockPlanId);
              notifyListeners();
              return true;
            }
          }
          return false;
        } else {
          _currentPlanId = 'yearly';
          _tier = PremiumTier.premium;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('mock_plan_id', 'yearly');
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint('Restore error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Premium Bridge ───────────────────────────────────────────────────────

  /// Use Sheikh credits for a session. Returns true if successful.
  Future<bool> useSheikhCredits(int amount) async {
    if (_sheikhCredits >= amount) {
      _sheikhCredits -= amount;
      notifyListeners();

      if (_userId != null) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(_userId).set({
            'sheikhCredits': _sheikhCredits,
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint('Error saving sheikh credits: $e');
        }
      }
      return true;
    }
    return false;
  }

  /// Add Sheikh credits (e.g. from top-up / session purchase).
  Future<void> addSheikhCredits(int amount) async {
    _sheikhCredits += amount;
    notifyListeners();

    if (_userId != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(_userId).set({
          'sheikhCredits': _sheikhCredits,
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Error saving sheikh credits: $e');
      }
    }
  }

  /// Award quarterly Sheikh credits (called from a scheduled check).
  void awardQuarterlyCredits() {
    if (isPremium) {
      _sheikhCredits += 100;
      notifyListeners();
    }
  }
}
