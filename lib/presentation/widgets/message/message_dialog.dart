import 'package:flutter/material.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/constants/app_strings.dart';
import '../../../core/helpers/responsive_helper.dart';
import '../../../data/models/message.dart';

/// حوار إضافة/تعديل رسالة
class MessageDialog extends StatefulWidget {
  final String title;
  final String? initialTitle;
  final String? initialContent;
  final MessageCategory? initialCategory;
  final Function(String title, String content, MessageCategory category) onSave;

  const MessageDialog({
    super.key,
    required this.title,
    required this.onSave,
    this.initialTitle,
    this.initialContent,
    this.initialCategory,
  });

  @override
  State<MessageDialog> createState() => _MessageDialogState();
}

class _MessageDialogState extends State<MessageDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  late MessageCategory _selectedCategory;
  bool _isLoading = false;
  bool _autoDetectCategory = true;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle ?? '';
    _contentController.text = widget.initialContent ?? '';
    _selectedCategory = widget.initialCategory ?? MessageCategory.general;

    _contentController.addListener(_onContentChanged);
  }

  /// معالج تغيير المحتوى للتصنيف التلقائي
  void _onContentChanged() {
    if (_autoDetectCategory && _contentController.text.isNotEmpty) {
      final tempMessage = Message.create(
        title: _titleController.text,
        content: _contentController.text,
      );

      final suggestedCategory = tempMessage.suggestedCategory;
      if (suggestedCategory != _selectedCategory) {
        setState(() {
          _selectedCategory = suggestedCategory;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final dialogWidth = ResponsiveHelper.getDialogWidth(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(isMobile),
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildForm(isMobile),
                      const SizedBox(height: 24),
                      _buildCategorySection(isMobile),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildActions(isMobile),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء الرأس
  Widget _buildHeader(bool isMobile) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AppConstants.whatsappGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.message,
            color: Colors.white,
            size: isMobile ? 20 : 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
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

  /// بناء النموذج
  Widget _buildForm(bool isMobile) {
    return Column(
      children: [
        _buildTitleField(isMobile),
        const SizedBox(height: 16),
        _buildContentField(isMobile),
      ],
    );
  }

  /// بناء حقل العنوان
  Widget _buildTitleField(bool isMobile) {
    return TextFormField(
      controller: _titleController,
      textInputAction: TextInputAction.next,
      maxLength: AppConstants.maxMessageTitleLength,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppStrings.fieldRequired;
        }
        if (value.trim().length < 3) {
          return 'العنوان قصير جداً';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: AppStrings.messageTitle,
        hintText: AppStrings.messageTitleHint,
        prefixIcon: const Icon(Icons.title, color: AppConstants.whatsappGreen),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(
            color: AppConstants.whatsappGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(
            color: AppConstants.errorRed,
            width: 1,
          ),
        ),
      ),
      onChanged: (value) {
        setState(() {});
        _onContentChanged();
      },
    );
  }

  /// بناء حقل المحتوى
  Widget _buildContentField(bool isMobile) {
    return TextFormField(
      controller: _contentController,
      maxLines: isMobile ? 6 : 8,
      maxLength: AppConstants.maxMessageLength,
      textInputAction: TextInputAction.newline,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppStrings.fieldRequired;
        }
        if (value.trim().length < 10) {
          return 'المحتوى قصير جداً';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: AppStrings.messageContent,
        hintText: AppStrings.messageContentHint,
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 60),
          child: Icon(Icons.message, color: AppConstants.whatsappGreen),
        ),
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(
            color: AppConstants.whatsappGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(
            color: AppConstants.errorRed,
            width: 1,
          ),
        ),
        helperText: _getContentHelperText(),
        helperMaxLines: 2,
      ),
      onChanged: (value) {
        setState(() {});
        _onContentChanged();
      },
    );
  }

  /// بناء قسم التصنيف
  Widget _buildCategorySection(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.category,
                color: AppConstants.whatsappGreen,
                size: isMobile ? 20 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                'تصنيف الرسالة',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Switch(
                value: _autoDetectCategory,
                onChanged: (value) {
                  setState(() {
                    _autoDetectCategory = value;
                  });
                },
                activeColor: AppConstants.whatsappGreen,
              ),
              const SizedBox(width: 8),
              Text(
                'تلقائي',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCategoryGrid(isMobile),
        ],
      ),
    );
  }

  /// بناء شبكة التصنيفات
  Widget _buildCategoryGrid(bool isMobile) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 3,
      ),
      itemCount: MessageCategory.values.length,
      itemBuilder: (context, index) {
        final category = MessageCategory.values[index];
        final isSelected = _selectedCategory == category;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = category;
              _autoDetectCategory = false;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppConstants.whatsappGreen
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppConstants.whatsappGreen
                    : Colors.grey.shade300,
              ),
            ),
            child: Center(
              child: Text(
                category.displayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  /// بناء الأعمال
  Widget _buildActions(bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(fontSize: isMobile ? 14 : 16),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[600],
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              ),
              padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSave,
            child: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(
              AppStrings.save,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.whatsappGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              ),
              padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  /// الحصول على نص مساعد للمحتوى
  String _getContentHelperText() {
    final content = _contentController.text;
    final length = content.length;
    final wordCount = content.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;

    return 'الطول: $length حرف • الكلمات: $wordCount';
  }

  /// معالج الحفظ
  void _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // محاكاة تأخير الشبكة
      await Future.delayed(const Duration(milliseconds: 500));

      final title = _titleController.text.trim();
      final content = _contentController.text.trim();

      widget.onSave(title, content, _selectedCategory);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // معالجة الخطأ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في الحفظ: ${e.toString()}'),
            backgroundColor: AppConstants.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}