


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/helpers/responsive_helper.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/message.dart';

/// بطاقة الرسالة
class MessageCard extends StatelessWidget {
  final Message message;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSend;
  final VoidCallback? onUse;
  final bool isSelected;

  const MessageCard({
    super.key,
    required this.message,
    this.onEdit,
    this.onDelete,
    this.onSend,
    this.onUse,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppConstants.whatsappLight : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(color: AppConstants.whatsappGreen, width: 2)
            : Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppConstants.whatsappGreen.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: isSelected ? 12 : 8,
            offset: Offset(0, isSelected ? 4 : 2),
          ),
        ],
      ),
      child: _buildContent(context, isMobile),
    );
  }

  /// بناء المحتوى
  Widget _buildContent(BuildContext context, bool isMobile) {
    return Column(
      children: [
        // المحتوى الأساسي
        Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    const SizedBox(height: 6),
                    _buildPreview(),
                    const SizedBox(height: 8),
                    _buildChips(),
                  ],
                ),
              ),
              _buildQuickActions(context, isMobile),
            ],
          ),
        ),

        // أزرار الإجراءات السريعة في الأسفل
        _buildBottomActions(context, isMobile),
      ],
    );
  }

  /// بناء الأيقونة
  Widget _buildIcon() {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        gradient: isSelected
            ? AppConstants.whatsappGradient
            : LinearGradient(
          colors: [
            _getCategoryColor().withOpacity(0.7),
            _getCategoryColor(),
          ],
        ),
        borderRadius: BorderRadius.circular(22.5),
        boxShadow: [
          BoxShadow(
            color: _getCategoryColor().withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.message_rounded, color: Colors.white, size: 20),
    );
  }

  /// بناء العنوان
  Widget _buildTitle() {
    return Text(
      message.title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        color: isSelected ? AppConstants.whatsappDarkGreen : Colors.black87,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  /// بناء المعاينة
  Widget _buildPreview() {
    return Text(
      message.preview(50),
      style: TextStyle(
        color: isSelected
            ? AppConstants.whatsappDarkGreen.withOpacity(0.8)
            : Colors.grey[600],
        fontSize: 13,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// بناء الرقاقات
  Widget _buildChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCategoryChip(),
          const SizedBox(width: 6),
          _buildStatsChip(),
          if (message.usageCount > 0) ...[
            const SizedBox(width: 6),
            _buildUsageChip(),
          ],
        ],
      ),
    );
  }

  /// بناء رقاقة التصنيف
  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getCategoryColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        message.category.displayName,
        style: TextStyle(
          fontSize: 9,
          color: _getCategoryColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// بناء رقاقة الإحصائيات
  Widget _buildStatsChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${message.length} حرف',
        style: TextStyle(
          fontSize: 9,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// بناء رقاقة الاستخدام
  Widget _buildUsageChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppConstants.successGreen.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${message.usageCount}×',
        style: const TextStyle(
          fontSize: 9,
          color: AppConstants.successGreen,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// بناء الأعمال السريعة
  Widget _buildQuickActions(BuildContext context, bool isMobile) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Colors.grey[600],
        size: isMobile ? 18 : 20,
      ),
      onSelected: (value) => _handleAction(context, value),
      itemBuilder: (context) => [
        if (onUse != null)
          const PopupMenuItem(
            value: 'copy',
            child: Row(
              children: [
                Icon(Icons.copy, size: 18, color: AppConstants.infoBlue),
                SizedBox(width: 8),
                Text('نسخ'),
              ],
            ),
          ),
        if (onSend != null)
          const PopupMenuItem(
            value: 'send',
            child: Row(
              children: [
                Icon(Icons.send, size: 18, color: AppConstants.whatsappGreen),
                SizedBox(width: 8),
                Text('إرسال'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'details',
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.orange),
              SizedBox(width: 8),
              Text('التفاصيل'),
            ],
          ),
        ),
        if (onEdit != null || onDelete != null) const PopupMenuDivider(),
        if (onEdit != null)
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 18, color: AppConstants.warningOrange),
                SizedBox(width: 8),
                Text('تعديل'),
              ],
            ),
          ),
        if (onDelete != null)
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 18, color: AppConstants.errorRed),
                SizedBox(width: 8),
                Text('حذف'),
              ],
            ),
          ),
      ],
    );
  }

  /// بناء أزرار الإجراءات السفلية
  Widget _buildBottomActions(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 16,
        0,
        isMobile ? 12 : 16,
        isMobile ? 12 : 16,
      ),
      child: Row(
        children: [
          // زر النسخ
          if (onUse != null)
            Expanded(
              child: _buildActionButton(
                context,
                'نسخ',
                Icons.copy,
                AppConstants.infoBlue,
                    () => _handleCopy(context),
                isMobile,
              ),
            ),

          if (onUse != null && onSend != null) const SizedBox(width: 8),

          // زر الإرسال
          if (onSend != null)
            Expanded(
              child: _buildActionButton(
                context,
                'إرسال',
                Icons.send,
                AppConstants.whatsappGreen,
                    () => _handleSend(context),
                isMobile,
              ),
            ),

          if ((onUse != null || onSend != null) && (onEdit != null || onDelete != null))
            const SizedBox(width: 8),

          // زر التعديل
          if (onEdit != null)
            _buildIconButton(
              context,
              Icons.edit,
              AppConstants.warningOrange,
                  () => _handleEdit(context),
              'تعديل',
              isMobile,
            ),

          if (onEdit != null && onDelete != null) const SizedBox(width: 4),

          // زر الحذف
          if (onDelete != null)
            _buildIconButton(
              context,
              Icons.delete_outline,
              AppConstants.errorRed,
                  () => _handleDelete(context),
              'حذف',
              isMobile,
            ),
        ],
      ),
    );
  }

  /// بناء زر إجراء
  Widget _buildActionButton(
      BuildContext context,
      String text,
      IconData icon,
      Color color,
      VoidCallback onPressed,
      bool isMobile,
      ) {
    return SizedBox(
      height: isMobile ? 36 : 40,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: isMobile ? 14 : 16),
        label: Text(
          text,
          style: TextStyle(
            fontSize: isMobile ? 11 : 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 12,
            vertical: 0,
          ),
        ),
      ),
    );
  }

  /// بناء زر أيقونة
  Widget _buildIconButton(
      BuildContext context,
      IconData icon,
      Color color,
      VoidCallback onPressed,
      String tooltip,
      bool isMobile,
      ) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: isMobile ? 32 : 36,
        height: isMobile ? 32 : 36,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: color, size: isMobile ? 16 : 18),
          style: IconButton.styleFrom(
            backgroundColor: color.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  /// معالجة الإجراءات
  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'copy':
        _handleCopy(context);
        break;
      case 'send':
        _handleSend(context);
        break;
      case 'edit':
        _handleEdit(context);
        break;
      case 'delete':
        _handleDelete(context);
        break;
      case 'details':
        _showDetailsDialog(context);
        break;
    }
  }

  /// معالجة النسخ
  void _handleCopy(BuildContext context) {
    if (onUse != null) {
      // نسخ إلى الحافظة
      Clipboard.setData(ClipboardData(text: message.content));

      // إظهار رسالة تأكيد
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              const Text('تم نسخ الرسالة إلى الحافظة'),
            ],
          ),
          backgroundColor: AppConstants.successGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      // استدعاء الدالة لزيادة عداد الاستخدام
      onUse!();
    }
  }

  /// معالجة الإرسال
  void _handleSend(BuildContext context) {
    if (onSend != null) {
      onSend!();

      // إظهار رسالة تأكيد
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.send, color: Colors.white),
              const SizedBox(width: 8),
              const Text('جاري إرسال الرسالة...'),
            ],
          ),
          backgroundColor: AppConstants.whatsappGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// معالجة التعديل
  void _handleEdit(BuildContext context) {
    if (onEdit != null) {
      onEdit!();
    }
  }

  /// معالجة الحذف
  void _handleDelete(BuildContext context) {
    if (onDelete != null) {
      // إظهار حوار تأكيد
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: AppConstants.errorRed),
              SizedBox(width: 8),
              Text('تأكيد الحذف'),
            ],
          ),
          content: Text('هل تريد حذف الرسالة "${message.title}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                onDelete!();


                // إظهار رسالة تأكيد
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text('تم حذف الرسالة بنجاح'),
                      ],
                    ),
                    backgroundColor: AppConstants.errorRed,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.errorRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('حذف'),
            ),
          ],
        ),
      );
    }
  }

  /// عرض حوار التفاصيل
  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _MessageDetailsDialog(
        message: message,
        onEdit: onEdit,
        onDelete: onDelete,
        onSend: onSend,
        onUse: onUse,
      ),
    );
  }

  /// الحصول على لون التصنيف
  Color _getCategoryColor() {
    switch (message.category) {
      case MessageCategory.business:
        return AppConstants.infoBlue;
      case MessageCategory.personal:
        return AppConstants.successGreen;
      case MessageCategory.marketing:
        return AppConstants.warningOrange;
      case MessageCategory.support:
        return AppConstants.errorRed;
      case MessageCategory.announcement:
        return Colors.purple;
      case MessageCategory.greeting:
        return Colors.pink;
      case MessageCategory.reminder:
        return Colors.indigo;
      default:
        return AppConstants.whatsappGreen;
    }
  }
}

/// حوار تفاصيل الرسالة
class _MessageDetailsDialog extends StatelessWidget {
  final Message message;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSend;
  final VoidCallback? onUse;

  const _MessageDetailsDialog({
    required this.message,
    this.onEdit,
    this.onDelete,
    this.onSend,
    this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      child: Container(
        width: ResponsiveHelper.getDialogWidth(context),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, isMobile),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMessageContent(isMobile),
                    const SizedBox(height: 16),
                    _buildMetadata(isMobile),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildActions(context, isMobile),
          ],
        ),
      ),
    );
  }

  /// بناء الرأس
  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: AppConstants.whatsappGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.message,
            color: Colors.white,
            size: isMobile ? 18 : 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message.title,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  /// بناء محتوى الرسالة
  Widget _buildMessageContent(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        message.content,
        style: TextStyle(
          fontSize: isMobile ? 14 : 16,
          height: 1.5,
          color: Colors.black87,
        ),
        textDirection: message.textDirection,
      ),
    );
  }

  /// بناء البيانات الوصفية
  Widget _buildMetadata(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: AppConstants.infoBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConstants.infoBlue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildMetadataRow(
            'الطول:',
            '${message.length} حرف',
            Icons.text_fields,
          ),
          _buildMetadataRow(
            'عدد الكلمات:',
            '${message.wordCount}',
            Icons.title,
          ),
          _buildMetadataRow(
            'التصنيف:',
            message.category.displayName,
            Icons.category,
          ),
          _buildMetadataRow(
            'مرات الاستخدام:',
            '${message.usageCount}',
            Icons.trending_up,
          ),
          _buildMetadataRow(
            'تاريخ الإنشاء:',
            AppUtils.formatDateTime(message.createdAt),
            Icons.date_range,
          ),
        ],
      ),
    );
  }

  /// بناء صف البيانات الوصفية
  Widget _buildMetadataRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppConstants.infoBlue),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppConstants.infoBlue,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// بناء الأعمال
  Widget _buildActions(BuildContext context, bool isMobile) {
    return Column(
      children: [
        Row(
          children: [
            if (onUse != null)
              Expanded(
                child: _buildActionButton(
                  'نسخ',
                  Icons.copy,
                  AppConstants.infoBlue,
                      () {
                    Clipboard.setData(ClipboardData(text: message.content));
                    onUse!();
                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم نسخ الرسالة إلى الحافظة'),
                        backgroundColor: AppConstants.successGreen,
                      ),
                    );
                  },
                  isMobile,
                ),
              ),
            if (onUse != null && onSend != null) const SizedBox(width: 8),
            if (onSend != null)
              Expanded(
                child: _buildActionButton(
                  'إرسال',
                  Icons.send,
                  AppConstants.whatsappGreen,
                      () {
                    onSend!();
                    Navigator.of(context).pop();
                  },
                  isMobile,
                ),
              ),
          ],
        ),
        if ((onUse != null || onSend != null) && (onEdit != null || onDelete != null))
          const SizedBox(height: 12),
        if (onEdit != null || onDelete != null)
          Row(
            children: [
              if (onEdit != null)
                Expanded(
                  child: _buildActionButton(
                    'تعديل',
                    Icons.edit,
                    AppConstants.warningOrange,
                        () {
                      onEdit!();
                      Navigator.of(context).pop();
                    },
                    isMobile,
                  ),
                ),
              if (onEdit != null && onDelete != null) const SizedBox(width: 8),
              if (onDelete != null)
                Expanded(
                  child: _buildActionButton(
                    'حذف',
                    Icons.delete,
                    AppConstants.errorRed,
                        () {
                      onDelete!();
                      Navigator.of(context).pop();
                    },
                    isMobile,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  /// بناء زر إجراء
  Widget _buildActionButton(
      String text,
      IconData icon,
      Color color,
      VoidCallback onPressed,
      bool isMobile,
      ) {
    return SizedBox(
      height: isMobile ? 40 : 44,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: isMobile ? 16 : 18),
        label: Text(
          text,
          style: TextStyle(
            fontSize: isMobile ? 12 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
      ),
    );
  }
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();