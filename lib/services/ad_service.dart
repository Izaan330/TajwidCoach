import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    // await MobileAds.instance.initialize();
    _initialized = true;
    debugPrint('AdService Initialized (Mock)');
  }

  static Widget getBannerAd({required bool isPremium}) {
    if (isPremium) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: 60,
      color: Colors.grey[200],
      child: const Center(
        child: Text(
          'AD BANNER (Free Version)\nUpgrade to Premium to remove ads',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ),
    );
  }
}
