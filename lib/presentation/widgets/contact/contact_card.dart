import 'package:flutter/material.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/helpers/responsive_helper.dart';
import '../../../data/models/contact.dart';

/// بطاقة جهة الاتصال
class ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onMessage;
  final VoidCallback? onCall;
  final bool isSelected;

  const ContactCard({
    super.key,
    required this.contact,
    this.onEdit,
    this.onDelete,
    this.onMessage,
    this.onCall,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;


    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppConstants.appLight : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(color: AppConstants.appGreen, width: 2)
            : Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppConstants.appGreen.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: isSelected ? 12 : 8,
            offset: Offset(0, isSelected ? 4 : 2),
          ),
        ],
      ),
      child: _buildContent(context, isMobile, screenWidth),
    );
  }

  /// بناء المحتوى - طريقة محسنة لتجنب overflow
  Widget _buildContent(BuildContext context, bool isMobile, double screenWidth) {
    // استخدام Column بدلاً من ListTile للتحكم الأفضل في التخطيط
    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        children: [
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    const SizedBox(height: 4),
                    _buildPhoneInfo(),
                    if (contact.hasNote) ...[
                      const SizedBox(height: 6),
                      _buildNote(),
                    ],
                  ],
                ),
              ),
              // أزرار الأعمال في عمود منفصل
              _buildActionsColumn(isMobile, screenWidth),
            ],
          ),
          // أزرار إضافية في صف منفصل للشاشات الصغيرة
          if (isMobile && _hasMultipleActions()) ...[
            const SizedBox(height: 12),
            _buildActionsRow(isMobile),
          ],
        ],
      ),
    );
  }

  /// بناء الصورة الرمزية
  Widget _buildAvatar() {
    return Hero(
      tag: 'contact_${contact.id}',
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: isSelected
              ? AppConstants.appGradient
              : LinearGradient(
            colors: [Colors.grey.shade300, Colors.grey.shade400],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: (isSelected ? AppConstants.appGreen : Colors.grey)
                  .withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            contact.initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  /// بناء العنوان
  Widget _buildTitle() {
    return Text(
      contact.name,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: isSelected ? AppConstants.appDarkGreen : Colors.black87,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  /// بناء معلومات الهاتف
  Widget _buildPhoneInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          contact.displayPhone,
          style: TextStyle(
            color: isSelected
                ? AppConstants.appDarkGreen.withOpacity(0.8)
                : Colors.grey[600],
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              contact.hasValidPhone ? Icons.check_circle : Icons.error,
              size: 12,
              color: contact.hasValidPhone
                  ? AppConstants.successGreen
                  : AppConstants.errorRed,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                contact.hasValidPhone ? contact.carrier : 'رقم غير صحيح',
                style: TextStyle(
                  fontSize: 11,
                  color: contact.hasValidPhone
                      ? AppConstants.successGreen
                      : AppConstants.errorRed,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// بناء الملاحظة
  Widget _buildNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? AppConstants.appGreen.withOpacity(0.2)
            : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        contact.note!,
        style: TextStyle(
          fontSize: 10,
          color: isSelected
              ? AppConstants.appDarkGreen
              : Colors.blue.shade700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// بناء عمود الأعمال (للشاشات الكبيرة)
  Widget _buildActionsColumn(bool isMobile, double screenWidth) {
    if (isMobile && _hasMultipleActions()) {
      // في الجوال، عرض زر واحد فقط أو أيقونة المزيد
      return _buildPrimaryAction(isMobile) ?? _buildMoreButton(isMobile);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _buildActionsList(isMobile, maxActions: isMobile ? 2 : 4),
    );
  }

  /// بناء صف الأعمال (للشاشات الصغيرة)
  Widget _buildActionsRow(bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _buildActionsList(isMobile, maxActions: 4),
    );
  }

  /// بناء قائمة الأعمال
  List<Widget> _buildActionsList(bool isMobile, {int maxActions = 4}) {
    final actions = <Widget>[];
    int actionCount = 0;

    if (onMessage != null && actionCount < maxActions) {
      actions.add(_buildActionButton(
        Icons.message,
        AppConstants.appGreen,
        onMessage!,
        'إرسال رسالة',
        isMobile,
      ));
      actionCount++;
    }

    if (onCall != null && actionCount < maxActions) {
      actions.add(_buildActionButton(
        Icons.phone,
        AppConstants.infoBlue,
        onCall!,
        'اتصال',
        isMobile,
      ));
      actionCount++;
    }

    if (onEdit != null && actionCount < maxActions) {
      actions.add(_buildActionButton(
        Icons.edit,
        AppConstants.warningOrange,
        onEdit!,
        'تعديل',
        isMobile,
      ));
      actionCount++;
    }

    if (onDelete != null && actionCount < maxActions) {
      actions.add(_buildActionButton(
        Icons.delete,
        AppConstants.errorRed,
        onDelete!,
        'حذف',
        isMobile,
      ));
      actionCount++;
    }

    if (isSelected) {
      actions.add(
        Icon(
          Icons.check_circle,
          color: AppConstants.appGreen,
          size: isMobile ? 18 : 20,
        ),
      );
    }

    return actions;
  }

  /// بناء الإجراء الأساسي
  Widget? _buildPrimaryAction(bool isMobile) {
    if (onMessage != null) {
      return _buildActionButton(
        Icons.message,
        AppConstants.appGreen,
        onMessage!,
        'إرسال رسالة',
        isMobile,
      );
    }
    if (onCall != null) {
      return _buildActionButton(
        Icons.phone,
        AppConstants.infoBlue,
        onCall!,
        'اتصال',
        isMobile,
      );
    }
    return null;
  }

  /// بناء زر المزيد
  Widget _buildMoreButton(bool isMobile) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Colors.grey[600],
        size: isMobile ? 18 : 20,
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
          case 'call':
            onCall?.call();
            break;
          case 'message':
            onMessage?.call();
            break;
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];

        if (onMessage != null) {
          items.add(
            const PopupMenuItem(
              value: 'message',
              child: Row(
                children: [
                  Icon(Icons.chat, color: AppConstants.appGreen),
                  SizedBox(width: 8),
                  Text('فتح محادثة'),
                ],
              ),
            ),
          );
        }

        if (onCall != null) {
          items.add(
            const PopupMenuItem(
              value: 'call',
              child: Row(
                children: [
                  Icon(Icons.phone, color: AppConstants.infoBlue),
                  SizedBox(width: 8),
                  Text('اتصال'),
                ],
              ),
            ),
          );
        }

        if (onEdit != null) {
          items.add(
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: AppConstants.warningOrange),
                  SizedBox(width: 8),
                  Text('تعديل'),
                ],
              ),
            ),
          );
        }

        if (onDelete != null) {
          items.add(
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppConstants.errorRed),
                  SizedBox(width: 8),
                  Text('حذف'),
                ],
              ),
            ),
          );
        }

        return items;
      },
    );
  }

  /// بناء زر إجراء
  Widget _buildActionButton(
      IconData icon,
      Color color,
      VoidCallback onPressed,
      String tooltip,
      bool isMobile,
      ) {
    return Tooltip(
      message: tooltip,
      child: Container(
        margin: const EdgeInsets.all(2),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: color,
            size: isMobile ? 16 : 18,
          ),
          style: IconButton.styleFrom(
            backgroundColor: color.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            padding: EdgeInsets.all(isMobile ? 4 : 6),
            minimumSize: Size(isMobile ? 28 : 32, isMobile ? 28 : 32),
          ),
        ),
      ),
    );
  }

  /// التحقق من وجود أعمال متعددة
  bool _hasMultipleActions() {
    int count = 0;
    if (onMessage != null) count++;
    if (onCall != null) count++;
    if (onEdit != null) count++;
    if (onDelete != null) count++;
    return count > 2;
  }
}