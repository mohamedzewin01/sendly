import 'package:flutter/material.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/helpers/responsive_helper.dart';

/// ويدجت لعرض الحالة الفارغة
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Color? color;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onActionPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final effectiveColor = color ?? AppConstants.whatsappGreen;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(isMobile, effectiveColor),
            const SizedBox(height: 24),
            _buildTitle(isMobile),
            const SizedBox(height: 12),
            _buildSubtitle(isMobile),
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: 32),
              _buildActionButton(isMobile, effectiveColor),
            ],
          ],
        ),
      ),
    );
  }

  /// بناء الأيقونة
  Widget _buildIcon(bool isMobile, Color effectiveColor) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 30 : 40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        size: isMobile ? 60 : 80,
        color: Colors.white,
      ),
    );
  }

  /// بناء العنوان
  Widget _buildTitle(bool isMobile) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isMobile ? 18 : 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// بناء العنوان الفرعي
  Widget _buildSubtitle(bool isMobile) {
    return Text(
      subtitle,
      style: TextStyle(
        fontSize: isMobile ? 14 : 16,
        color: Colors.white.withOpacity(0.8),
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// بناء زر الإجراء
  Widget _buildActionButton(bool isMobile, Color effectiveColor) {
    return ElevatedButton.icon(
      onPressed: onActionPressed,
      icon: const Icon(Icons.add, size: 20),
      label: Text(
        actionText!,
        style: TextStyle(
          fontSize: isMobile ? 14 : 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: effectiveColor,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 32,
          vertical: isMobile ? 12 : 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 4,
      ),
    );
  }
}