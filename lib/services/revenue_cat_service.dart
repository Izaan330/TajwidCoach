import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class RevenueCatService {
  // Public SDK keys from the RevenueCat dashboard.
  // Apple key — still a test placeholder (iOS not yet published).
  static const _appleApiKey = 'test_cVlsLjKsUBKNirqTCiiRGySsiGs';
  // Google key — real production key for Google Play.
  static const _googleApiKey = 'goog_gKFpeWooMyawuXRMVpTSfuPBDuV';

  // Mapping internal plan IDs to store product IDs
  static const Map<String, String> _planToStoreProductId = {
    'monthly': 'tajwidcoach_premium_individual:individual-monthly',
    'yearly': 'tajwidcoach_premium_individual:individual-yearly',
    'family_monthly': 'tajwidcoach_premium_family:family-monthly',
    'family_yearly': 'tajwidcoach_premium_family:family-yearly',
    'lifetime': 'tajwidcoach_premium_lifetime',
    'monthly_2': 'tajwidcoach_sheikh_pro:sheikh-monthly',
    'credits_100': 'tajwidcoach_credits_100',
    'credits_500': 'tajwidcoach_credits_500',
    'credits_1000': 'tajwidcoach_credits_1000',
  };

  // Mapping internal plan IDs to RevenueCat package IDs
  static const Map<String, String> _planToPackageId = {
    'monthly': 'individual_monthly_premium',
    'yearly': 'individual_yearly_premium',
    'family_monthly': 'family_monthly_premium',
    'family_yearly': 'family_yearly_premium',
    'lifetime': 'individual_lifetime_premium',
    'monthly_2': 'sheikh_monthly_premium',
    'credits_100': 'sheikh_credits_100',
    'credits_500': 'sheikh_credits_500',
    'credits_1000': 'sheikh_credits_1000',
  };

  static String mapPlanIdToStoreProductId(String planId) {
    return _planToStoreProductId[planId] ?? planId;
  }

  static String mapPlanIdToPackageId(String planId) {
    return _planToPackageId[planId] ?? planId;
  }

  static bool get _isGoogleKeyReal =>
      _googleApiKey.isNotEmpty &&
      _googleApiKey != 'goog_api_key_here' &&
      !_googleApiKey.startsWith('test_');

  static bool get _isAppleKeyReal =>
      _appleApiKey.isNotEmpty &&
      _appleApiKey != 'appl_api_key_here' &&
      !_appleApiKey.startsWith('test_');

  /// Returns true only if a real key is available for the current platform.
  /// On Android: only the Google key needs to be real.
  /// On iOS: only the Apple key needs to be real.
  /// This allows Android to use real RevenueCat even while iOS is not yet live.
  static bool get isConfigured {
    if (kIsWeb) return false;
    if (Platform.isAndroid) return _isGoogleKeyReal;
    if (Platform.isIOS) return _isAppleKeyReal;
    return false;
  }

  static Future<void> init() async {
    if (kIsWeb) return;

    debugPrint('RevenueCat: Initializing with API keys...');
    debugPrint('RevenueCat: isConfigured = $isConfigured');
    debugPrint('RevenueCat: Apple key starts with: ${_appleApiKey.substring(0, _appleApiKey.length > 5 ? 5 : _appleApiKey.length)}...');
    debugPrint('RevenueCat: Google key starts with: ${_googleApiKey.substring(0, _googleApiKey.length > 5 ? 5 : _googleApiKey.length)}...');

    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_googleApiKey);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_appleApiKey);
    }

    if (configuration != null) {
      await Purchases.configure(configuration);
      debugPrint('RevenueCat: Configured successfully for ${Platform.isIOS ? "iOS" : "Android"}');
    }
  }

  static Future<CustomerInfo?> getCustomerInfo() async {
    try {
      final info = await Purchases.getCustomerInfo();
      debugPrint('RevenueCat: CustomerInfo fetched. Entitlements: ${info.entitlements.all}');
      debugPrint('RevenueCat: Active entitlements: ${info.entitlements.active.keys.toList()}');
      debugPrint('RevenueCat: Original app user ID: ${info.originalAppUserId}');
      return info;
    } catch (e) {
      debugPrint('RevenueCat: Error fetching customer info: $e');
      return null;
    }
  }

  static Future<void> logIn(String userId) async {
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      debugPrint('RevenueCat: Error logging in user $userId: $e');
    }
  }

  static Future<void> logOut() async {
    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint('RevenueCat: Error logging out: $e');
    }
  }

  static Future<CustomerInfo?> purchasePlan(String planId) async {
    try {
      final storeProductId = mapPlanIdToStoreProductId(planId);
      final packageId = mapPlanIdToPackageId(planId);
      debugPrint('RevenueCat: Attempting purchase for plan "$planId" (Store Product ID: "$storeProductId", Package ID: "$packageId")');
      
      final offerings = await Purchases.getOfferings();
      // Use current offering or fallback to tajwid_ai_offering
      final offering = offerings.current ?? offerings.all['tajwid_ai_offering'];
      debugPrint('RevenueCat: Using offering = ${offering?.identifier}');
      if (offering != null) {
        debugPrint('RevenueCat: Available packages = ${offering.availablePackages.map((p) => p.identifier).toList()}');
      }

      if (offering != null && offering.availablePackages.isNotEmpty) {
        final matchingPackages = offering.availablePackages.where(
          (pkg) => pkg.identifier == packageId || pkg.storeProduct.identifier == storeProductId || pkg.identifier == planId,
        );
        if (matchingPackages.isNotEmpty) {
          final package = matchingPackages.first;
          debugPrint('RevenueCat: Purchasing package "${package.identifier}" (Store Product: "${package.storeProduct.identifier}")');
          final result =
              await Purchases.purchase(PurchaseParams.package(package));
          debugPrint('RevenueCat: Purchase successful. Entitlements: ${result.customerInfo.entitlements.all}');
          return result.customerInfo;
        }
      }

      debugPrint('RevenueCat: Matching package not found in current offering. Falling back to store product search for "$storeProductId"');
      final products = await Purchases.getProducts([storeProductId]);
      debugPrint('RevenueCat: Found ${products.length} products for "$storeProductId"');
      if (products.isNotEmpty) {
        final result = await Purchases.purchase(
            PurchaseParams.storeProduct(products.first));
        debugPrint('RevenueCat: Purchase successful. Entitlements: ${result.customerInfo.entitlements.all}');
        return result.customerInfo;
      } else {
        throw Exception('Product "$storeProductId" not found on the store.');
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('1') && msg.contains('User cancelled')) {
        debugPrint('RevenueCat: Purchase cancelled by user');
      } else if (msg.contains('25') && msg.contains('Payment pending')) {
        debugPrint('RevenueCat: Payment pending (iOS)');
      } else {
        debugPrint('RevenueCat: Purchase error for $planId: $e');
      }
      rethrow;
    }
  }

  static Future<CustomerInfo?> restorePurchases() async {
    try {
      debugPrint('RevenueCat: Restoring purchases...');
      final info = await Purchases.restorePurchases();
      debugPrint('RevenueCat: Restore complete. Entitlements: ${info.entitlements.all}');
      debugPrint('RevenueCat: Active entitlements after restore: ${info.entitlements.active.keys.toList()}');
      return info;
    } catch (e) {
      debugPrint('RevenueCat: Restore error: $e');
      rethrow;
    }
  }

  static Future<void> presentCustomerCenter() async {
    try {
      await RevenueCatUI.presentCustomerCenter();
    } catch (e) {
      debugPrint('RevenueCat: Error presenting customer center: $e');
    }
  }
}
