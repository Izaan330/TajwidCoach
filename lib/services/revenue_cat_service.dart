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
      debugPrint('RevenueCat: Attempting purchase for plan "$planId"');
      final offerings = await Purchases.getOfferings();
      debugPrint('RevenueCat: Current offering = ${offerings.current?.identifier}');
      debugPrint('RevenueCat: Available packages = ${offerings.current?.availablePackages.map((p) => p.storeProduct.identifier).toList()}');

      if (offerings.current != null) {
        final package = offerings.current!.availablePackages.firstWhere(
          (pkg) => pkg.storeProduct.identifier == planId,
          orElse: () => offerings.current!.availablePackages.first,
        );
        debugPrint('RevenueCat: Purchasing package "${package.storeProduct.identifier}" (${package.storeProduct.title})');
        final result =
            await Purchases.purchase(PurchaseParams.package(package));
        debugPrint('RevenueCat: Purchase successful. Entitlements: ${result.customerInfo.entitlements.all}');
        return result.customerInfo;
      } else {
        debugPrint('RevenueCat: No current offering, falling back to getProducts');
        final products = await Purchases.getProducts([planId]);
        debugPrint('RevenueCat: Found ${products.length} products for "$planId"');
        if (products.isNotEmpty) {
          final result = await Purchases.purchase(
              PurchaseParams.storeProduct(products.first));
          debugPrint('RevenueCat: Purchase successful. Entitlements: ${result.customerInfo.entitlements.all}');
          return result.customerInfo;
        }
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
    return null;
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
