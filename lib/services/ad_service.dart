import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static bool _initialized = false;
  static RewardedAd? _rewardedAd;
  static bool _isRewardedAdLoading = false;
  static int _rewardedAdLoadAttempts = 0;

  // ───────────────────────────────────────────────────────────────────────────
  // AD CONFIGURATION: Set to false and paste your IDs when publishing
  // ───────────────────────────────────────────────────────────────────────────
  static const bool _useTestAds = true;

  // Paste your production Ad Unit IDs from the AdMob Dashboard here:
  static const String _prodAndroidBannerAdUnitId = 'ca-app-pub-6764397821753786/6529267403';
  static const String _prodAndroidRewardedAdUnitId = 'ca-app-pub-6764397821753786/9917848072';
  static const String _prodIOSBannerAdUnitId = 'ca-app-pub-6764397821753786/8238465121';
  static const String _prodIOSRewardedAdUnitId = 'ca-app-pub-6764397821753786/4829172923';

  // ───────────────────────────────────────────────────────────────────────────

  /// Resolves the appropriate Rewarded Ad Unit ID based on configuration and platform.
  static String get rewardedAdUnitId {
    if (_useTestAds) {
      if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/5224354917'; // Android Test Rewarded
      if (Platform.isIOS) return 'ca-app-pub-3940256099942544/1712485313'; // iOS Test Rewarded
    } else {
      if (Platform.isAndroid) return _prodAndroidRewardedAdUnitId;
      if (Platform.isIOS) return _prodIOSRewardedAdUnitId;
    }
    return '';
  }

  /// Resolves the appropriate Banner Ad Unit ID based on configuration and platform.
  static String get bannerAdUnitId {
    if (_useTestAds) {
      if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/6300978111'; // Android Test Banner
      if (Platform.isIOS) return 'ca-app-pub-3940256099942544/2934735716'; // iOS Test Banner
    } else {
      if (Platform.isAndroid) return _prodAndroidBannerAdUnitId;
      if (Platform.isIOS) return _prodIOSBannerAdUnitId;
    }
    return '';
  }

  static Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) {
      _initialized = true;
      debugPrint('AdService (Web): Web is not supported for AdMob mobile SDK');
      return;
    }

    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      debugPrint('AdService: MobileAds initialized successfully.');
      loadRewardedAd();
    } catch (e) {
      debugPrint('AdService initialization failed: $e');
    }
  }

  /// Prefetch / Load a rewarded ad
  static void loadRewardedAd() {
    if (kIsWeb || !_initialized) return;
    if (_isRewardedAdLoading || _rewardedAd != null) return;

    _isRewardedAdLoading = true;
    debugPrint('AdService: Loading rewarded ad...');

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
          _rewardedAdLoadAttempts = 0;
          debugPrint('AdService: Rewarded ad loaded successfully.');
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isRewardedAdLoading = false;
          _rewardedAdLoadAttempts++;
          debugPrint('AdService: Rewarded ad failed to load: $error');
          
          // Retry loading up to 3 times with exponential backoff
          if (_rewardedAdLoadAttempts < 3) {
            Future.delayed(Duration(seconds: _rewardedAdLoadAttempts * 5), () {
              loadRewardedAd();
            });
          }
        },
      ),
    );
  }

  /// Show a loaded rewarded ad, with support for reward and dismiss callbacks
  static void showRewardedAd({
    required VoidCallback onRewardEarned,
    required VoidCallback onAdClosed,
    required VoidCallback onAdFailedToShow,
  }) {
    if (kIsWeb) {
      // Direct reward fallback on unsupported web
      debugPrint('AdService: Web fallback - auto reward');
      onRewardEarned();
      onAdClosed();
      return;
    }

    if (_rewardedAd == null) {
      debugPrint('AdService: No rewarded ad available. Attempting load and using callback fallback.');
      onAdFailedToShow();
      loadRewardedAd();
      return;
    }

    bool earnedReward = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('AdService: Rewarded ad showed full screen.');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('AdService: Rewarded ad dismissed.');
        ad.dispose();
        _rewardedAd = null;
        onAdClosed();
        loadRewardedAd(); // Cache the next ad
        if (earnedReward) {
          onRewardEarned();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdService: Rewarded ad failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
        onAdFailedToShow();
        loadRewardedAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('AdService: User earned reward: ${reward.amount} ${reward.type}');
        earnedReward = true;
      },
    );
  }

  /// Returns a fully functioning AdBannerWidget or fallback for Premium users
  static Widget getBannerAd({required bool isPremium}) {
    if (isPremium) return const SizedBox.shrink();
    if (kIsWeb) return const SizedBox.shrink();
    return const AdBannerWidget();
  }
}

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdService: Banner ad failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
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
