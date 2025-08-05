import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManger {
  static bool isAdActive = true;
  static String bannerHome1 = isAdActive
      ? "ca-app-pub-3940256099942544/9214589741"
      : "ca-app-pub-7679264832786592/1566931134";

  static String bannerHome2 = isAdActive
      ? "ca-app-pub-3940256099942544/9214589741"
      : "ca-app-pub-7679264832786592/9283850616";

  static String homeInterstitialAd = isAdActive
      ? "ca-app-pub-3940256099942544/1033173712"
      : "ca-app-pub-7679264832786592/5442812560";

  static String appOpenAds= isAdActive
      ? "ca-app-pub-3940256099942544/9257395921"
      : "ca-app-pub-7679264832786592/7288226750";




}