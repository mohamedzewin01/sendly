import 'package:flutter/material.dart';
import 'package:sendly/assets_manager.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/helpers/responsive_helper.dart';

/// شريط التطبيق المخصص
class CustomAppBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final int contactsCount;
  final int messagesCount;
  final VoidCallback? onMenuPressed;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.contactsCount = 0,
    this.messagesCount = 0,
    this.onMenuPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: [
          _buildIcon(isMobile),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTitle(isMobile),
          ),
          _buildStatsChip(context),
        ],
      ),
    );
  }

  /// بناء الأيقونة
  Widget _buildIcon(bool isMobile) {
    return Hero(
      tag: 'app_icon',
      child: Container(
        padding: EdgeInsets.all(isMobile ? 6 : 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Image.asset(
          Assets.logoPng,
          width: isMobile ? 30 : 35,
          height: isMobile ? 30 : 35,
        ),

        // Icon(
        //   Icons.chat_bubble_outline,
        //   color: Colors.white,
        //   size: isMobile ? 28 : 36,
        // ),
      ),
    );
  }

  /// بناء العنوان
  Widget _buildTitle(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            // fontSize: ResponsiveHelper.getResponsiveFontSize(
            //   context as BuildContext,
            //   isMobile ? 22 : 28,
            // ),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            // fontSize: ResponsiveHelper.getResponsiveFontSize(
            //   context as BuildContext,
            //   isMobile ? 12 : 16,
            // ),
          ),
        ),
      ],
    );
  }

  /// بناء رقاقة الإحصائيات
  Widget _buildStatsChip(BuildContext context) {
    if (contactsCount == 0 && messagesCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (contactsCount > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.contacts,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  contactsCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          if (contactsCount > 0 && messagesCount > 0)
            const SizedBox(height: 4),
          if (messagesCount > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.message,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  messagesCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}