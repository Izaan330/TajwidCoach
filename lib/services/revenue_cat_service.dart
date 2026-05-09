import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  // Replace these with your actual keys from the RevenueCat dashboard
  static const _appleApiKey = 'appl_api_key_here';
  static const _googleApiKey = 'goog_api_key_here';

  static bool get isConfigured => _appleApiKey != 'appl_api_key_here' && _googleApiKey != 'goog_api_key_here';

  static Future<void> init() async {
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
    }
  }

  static Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
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
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        final package = offerings.current!.availablePackages.firstWhere(
          (pkg) => pkg.storeProduct.identifier == planId,
          orElse: () => offerings.current!.availablePackages.first,
        );
        final result = await Purchases.purchase(PurchaseParams.package(package));
        return result.customerInfo;
      } else {
        final products = await Purchases.getProducts([planId]);
        if (products.isNotEmpty) {
          final result = await Purchases.purchase(PurchaseParams.storeProduct(products.first));
          return result.customerInfo;
        }
      }
    } catch (e) {
      debugPrint('RevenueCat: Purchase error for $planId: $e');
      rethrow;
    }
    return null;
  }

  static Future<CustomerInfo?> restorePurchases() async {
    try {
      return await Purchases.restorePurchases();
    } catch (e) {
      debugPrint('RevenueCat: Restore error: $e');
      rethrow;
    }
  }
}
