import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_manger.dart';

class Ads {
  InterstitialAd? _interstitialAd;
  AppOpenAd? _appOpenAd;
  NativeAd? _nativeAd;

  void showInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdManger.homeInterstitialAd,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          if (_interstitialAd != null) _interstitialAd!.show();
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
            },
          );
        },

        onAdFailedToLoad: (error) {},
      ),
    );
  }

  void showAppOpenAds() {
    AppOpenAd.load(
      adUnitId: AdManger.appOpenAds,
      request: const AdRequest(),

      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          if (_appOpenAd != null) _appOpenAd!.show();
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _appOpenAd = null;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _appOpenAd = null;
            },
          );

          },

        onAdFailedToLoad: (error) {
          print('AppOpenAd failed to load: $error');
        },
      ),
    );
  }


}
