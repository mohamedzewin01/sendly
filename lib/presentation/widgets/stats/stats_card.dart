import 'package:flutter/material.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/helpers/responsive_helper.dart';

/// بطاقة إحصائيات
class StatsCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? subtitle;
  final Widget? trailing;

  const StatsCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.onTap,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: onTap != null
              ? Border.all(color: color.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Row(
          children: [
            _buildIcon(isMobile),
            const SizedBox(width: 20),
            Expanded(
              child: _buildContent(isMobile),
            ),
            if (trailing != null) trailing!,
            if (onTap != null) _buildActionIcon(),
          ],
        ),
      ),
    );
  }

  /// بناء الأيقونة
  Widget _buildIcon(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        icon,
        color: color,
        size: isMobile ? 24 : 30,
      ),
    );
  }

  /// بناء المحتوى
  Widget _buildContent(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ],
    );
  }

  /// بناء أيقونة الإجراء
  Widget _buildActionIcon() {
    return Icon(
      Icons.add_circle,
      color: color,
      size: 30,
    );
  }
}