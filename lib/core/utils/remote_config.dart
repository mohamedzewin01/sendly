import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateChecker {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  static const String _defaultStoreUrl = "https://play.google.com/store/apps/details?id=com.mnrra.sandlyn";

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      await _configureRemoteConfig();
      await remoteConfig.fetchAndActivate();

      final updateInfo = _getUpdateInfo();
      final currentVersion = await _getCurrentVersion();

      if (_isVersionOutdated(currentVersion, updateInfo.latestVersion)) {
        if (!context.mounted) return;

        if (updateInfo.forceUpdate) {
          await _showForceUpdateDialog(context, updateInfo);
        } else {
          await _showOptionalUpdateDialog(context, updateInfo);
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  Future<void> _configureRemoteConfig() async {
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration.zero,
    ));
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

  Future<void> _showForceUpdateDialog(BuildContext context, UpdateInfo updateInfo) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red[50]!, Colors.orange[50]!],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with animated icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[400]!, Colors.orange[400]!],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.system_security_update_warning_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    "تحديث مطلوب",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Version info
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "الإصدار ${updateInfo.latestVersion}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Main message
                  Text(
                    updateInfo.updateMessage ??
                        "للاستمرار في استخدام التطبيق بأمان، يجب تحديثه إلى أحدث إصدار.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Security notice
                  // Container(
                  //   padding: const EdgeInsets.all(16),
                  //   decoration: BoxDecoration(
                  //     color: Colors.red[50],
                  //     borderRadius: BorderRadius.circular(16),
                  //     border: Border.all(color: Colors.red[200]!, width: 1),
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.security_rounded, color: Colors.red[600], size: 24),
                  //       const SizedBox(width: 12),
                  //       Expanded(
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             Text(
                  //               "تحديث أمني ضروري",
                  //               style: TextStyle(
                  //                 fontSize: 15,
                  //                 fontWeight: FontWeight.w600,
                  //                 color: Colors.red[700],
                  //               ),
                  //             ),
                  //             const SizedBox(height: 4),
                  //             Text(
                  //               "يحتوي على إصلاحات أمنية مهمة لحماية بياناتك",
                  //               style: TextStyle(
                  //                 fontSize: 13,
                  //                 color: Colors.red[600],
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  // Features list if available
                  if (updateInfo.features.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildFeaturesList(updateInfo.features, true),
                  ],

                  const SizedBox(height: 32),

                  // Update button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _launchStore(context, updateInfo.storeUrl),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[500],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: Colors.red.withOpacity(0.4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.download_rounded, size: 24),
                          const SizedBox(width: 12),
                          const Text(
                            "تحديث الآن",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showOptionalUpdateDialog(BuildContext context, UpdateInfo updateInfo) async {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue[50]!, Colors.purple[50]!],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with animated icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[400]!, Colors.purple[400]!],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.system_update_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  "تحديث متاح",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),

                // Version info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "الإصدار ${updateInfo.latestVersion}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Main message
                Text(
                  updateInfo.updateMessage ??
                      "يتوفر إصدار جديد من التطبيق مع ميزات محسّنة وتحسينات في الأداء.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),

                // Recommendation notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue[200]!, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.recommend_rounded, color: Colors.blue[600], size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ننصح بالتحديث",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "للحصول على أفضل تجربة وأحدث الميزات",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Features list if available
                if (updateInfo.features.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildFeaturesList(updateInfo.features, false),
                ],

                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(color: Colors.grey[400]!),
                        ),
                        child: Text(
                          "لاحقاً",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _launchStore(context, updateInfo.storeUrl);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[500],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: Colors.blue.withOpacity(0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.download_rounded, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              "تحديث",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList(List<String> features, bool isForceUpdate) {
    final color = isForceUpdate ? Colors.orange : Colors.blue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_rounded, color: color[600], size: 20),
              const SizedBox(width: 8),
              Text(
                "الميزات الجديدة:",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...features.take(3).map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color[600],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature.trim(),
                    style: TextStyle(
                      fontSize: 14,
                      color: color[600],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Future<void> _launchStore(BuildContext context, String storeUrl) async {
    try {
      final uri = Uri.parse(storeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showErrorSnackBar(context, "لا يمكن فتح متجر التطبيقات");
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, "حدث خطأ أثناء فتح متجر التطبيقات");
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 8,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: "إغلاق",
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
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