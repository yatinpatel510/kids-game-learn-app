import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kids_lern_app/core/app_constants.dart';

class AdManager {
  static final AdManager instance = AdManager._internal();
  AdManager._internal();

  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoading = false;

  // Test Ad Unit IDs provided by Google AdMob
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return adMobUnitId;
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    throw UnsupportedError('Unsupported platform for ads');
  }

  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      // Register test device ID to allow viewing test ads on your development device
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: ['BDD6A1E7DE36A9DB3AF463E5A722E87E'],
        ),
      );
      preloadRewardedAd();
    } catch (e) {
      debugPrint('AdManager: MobileAds initialization failed: $e');
    }
  }

  void preloadRewardedAd() {
    if (_rewardedAd != null || _isRewardedAdLoading) return;
    _isRewardedAdLoading = true;

    debugPrint('AdManager: Preloading Rewarded Video Ad...');
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
          debugPrint('AdManager: Rewarded ad loaded successfully.');
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isRewardedAdLoading = false;
          debugPrint('AdManager: Rewarded ad failed to load: $error');
          // Retry loading after 15 seconds
          Future.delayed(const Duration(seconds: 15), preloadRewardedAd);
        },
      ),
    );
  }

  bool get isAdReady => _rewardedAd != null;

  void showRewardedAd({
    required VoidCallback onEarnedReward,
    required VoidCallback onAdDismissed,
    required VoidCallback onAdFailed,
  }) {
    if (_rewardedAd == null) {
      debugPrint('AdManager: Ad not ready, loading and waiting...');
      _loadAndShow(
        onEarnedReward: onEarnedReward,
        onAdDismissed: onAdDismissed,
        onAdFailed: onAdFailed,
      );
      return;
    }
    _showAd(
      onEarnedReward: onEarnedReward,
      onAdDismissed: onAdDismissed,
      onAdFailed: onAdFailed,
    );
  }

  void _loadAndShow({
    required VoidCallback onEarnedReward,
    required VoidCallback onAdDismissed,
    required VoidCallback onAdFailed,
  }) {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
          debugPrint('AdManager: Ad loaded on-demand, showing now.');
          _showAd(
            onEarnedReward: onEarnedReward,
            onAdDismissed: onAdDismissed,
            onAdFailed: onAdFailed,
          );
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoading = false;
          debugPrint('AdManager: On-demand load failed: $error');
          onAdFailed();
        },
      ),
    );
  }

  void _showAd({
    required VoidCallback onEarnedReward,
    required VoidCallback onAdDismissed,
    required VoidCallback onAdFailed,
  }) {
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('AdManager: Ad dismissed.');
        ad.dispose();
        _rewardedAd = null;
        onAdDismissed();
        preloadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdManager: Ad failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
        onAdFailed();
        preloadRewardedAd();
      },
    );
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('AdManager: User rewarded: ${reward.amount} ${reward.type}');
        onEarnedReward();
      },
    );
  }
}
