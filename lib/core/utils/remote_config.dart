import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// جلب قيم Remote Config مرة واحدة فقط لكل تشغيل، يشاركها فحص التحديث والإعلانات
class RemoteConfigSync {
  RemoteConfigSync._();

  static Future<void>? _pending;

  /// آمن للاستدعاء من أكثر من مكان: الجلب يحدث مرة واحدة، وعند فشله تبقى آخر قيم محفوظة
  static Future<void> ensure() => _pending ??= _fetch();

  static Future<void> _fetch() async {
    try {
      final config = FirebaseRemoteConfig.instance;
      await config.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ),
      );
      await config.fetchAndActivate();
    } catch (e) {
      debugPrint('Remote Config fetch failed: $e');
    }
  }
}

/// يتحقق من وجود إصدار أحدث للتطبيق عبر Firebase Remote Config
class ForceUpdateChecker {
  FirebaseRemoteConfig get remoteConfig => FirebaseRemoteConfig.instance;
  static const String _defaultStoreUrl =
      'https://play.google.com/store/apps/details?id=com.mnrra.sandlyn';

  /// يرجع بيانات التحديث إن كان الإصدار الحالي أقدم من الأحدث، وإلا null
  Future<UpdateInfo?> check() async {
    try {
      await RemoteConfigSync.ensure();

      final updateInfo = _getUpdateInfo();
      final currentVersion = await _getCurrentVersion();

      if (_isVersionOutdated(currentVersion, updateInfo.latestVersion)) {
        return updateInfo;
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
    return null;
  }

  UpdateInfo _getUpdateInfo() {
    return UpdateInfo(
      latestVersion: remoteConfig.getString('latest_version'),
      forceUpdate: remoteConfig.getBool('force_update'),
      updateMessage: remoteConfig.getString('update_message').isNotEmpty
          ? remoteConfig.getString('update_message')
          : null,
      features: remoteConfig.getString('new_features').isNotEmpty
          ? remoteConfig.getString('new_features').split(',')
          : [],
      storeUrl: remoteConfig.getString('store_url').isNotEmpty
          ? remoteConfig.getString('store_url')
          : _defaultStoreUrl,
    );
  }

  Future<String> _getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  bool _isVersionOutdated(String current, String latest) {
    final currentParts = current.split('.').map(int.parse).toList();
    final latestParts = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length || currentParts[i] < latestParts[i]) {
        return true;
      } else if (currentParts[i] > latestParts[i]) {
        return false;
      }
    }
    return false;
  }
}

class UpdateInfo {
  final String latestVersion;
  final bool forceUpdate;
  final String? updateMessage;
  final List<String> features;
  final String storeUrl;

  UpdateInfo({
    required this.latestVersion,
    required this.forceUpdate,
    this.updateMessage,
    required this.features,
    required this.storeUrl,
  });
}
