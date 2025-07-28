import 'package:flutter/material.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/constants/app_strings.dart';
import '../../../core/helpers/phone_formatter.dart';
import '../../../core/helpers/responsive_helper.dart';

/// حوار إضافة/تعديل جهة اتصال
class ContactDialog extends StatefulWidget {
  final String title;
  final String? initialName;
  final String? initialPhone;
  final String? initialNote;
  final Function(String name, String phone, String? note) onSave;

  const ContactDialog({
    super.key,
    required this.title,
    required this.onSave,
    this.initialName,
    this.initialPhone,
    this.initialNote,
  });

  @override
  State<ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<ContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _phoneController.text = widget.initialPhone ?? '';
    _noteController.text = widget.initialNote ?? '';
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
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(isMobile),
              const SizedBox(height: 24),
              _buildForm(isMobile),
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
            gradient: AppConstants.appGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.person_add,
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
        _buildNameField(isMobile),
        const SizedBox(height: 16),
        _buildPhoneField(isMobile),
        const SizedBox(height: 16),
        _buildNoteField(isMobile),
      ],
    );
  }

  /// بناء حقل الاسم
  Widget _buildNameField(bool isMobile) {
    return TextFormField(
      controller: _nameController,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppStrings.fieldRequired;
        }
        if (value.trim().length < 2) {
          return 'الاسم قصير جداً';
        }
        if (value.length > AppConstants.maxContactNameLength) {
          return 'الاسم طويل جداً';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: AppStrings.contactName,
        hintText: AppStrings.nameHint,
        prefixIcon: const Icon(Icons.person, color: AppConstants.appGreen),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(
            color: AppConstants.appGreen,
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
      onChanged: (value) => setState(() {}),
    );
  }

  /// بناء حقل الهاتف
  Widget _buildPhoneField(bool isMobile) {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textDirection: TextDirection.ltr,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppStrings.fieldRequired;
        }

        final validationError = PhoneNumberFormatter.getValidationError(value);
        if (validationError.isNotEmpty) {
          return validationError;
        }

        return null;
      },
      decoration: InputDecoration(
        labelText: AppStrings.contactPhone,
        hintText: AppStrings.phoneHint,
        prefixIcon: const Icon(Icons.phone, color: AppConstants.appGreen),
        suffixIcon: _phoneController.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _phoneController.clear();
            setState(() {});
          },
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(
            color: AppConstants.appGreen,
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
        // helperText: _getPhoneHelperText(),
        helperStyle: TextStyle(
          color: _getPhoneHelperColor(),
          fontWeight: FontWeight.w500,
        ),
      ),
      onChanged: (value) => setState(() {}),
    );
  }

  /// بناء حقل الملاحظة
  Widget _buildNoteField(bool isMobile) {
    return TextFormField(
      controller: _noteController,
      maxLines: 3,
      maxLength: 500,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'ملاحظة (اختيارية)',
        hintText: 'إضافة ملاحظة حول جهة الاتصال...',
        prefixIcon: const Icon(Icons.note, color: AppConstants.appGreen),
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(
            color: AppConstants.appGreen,
            width: 2,
          ),
        ),
      ),
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
              backgroundColor: AppConstants.appGreen,
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

  /// الحصول على نص مساعد للهاتف
  // String _getPhoneHelperText() {
  //   final phone = _phoneController.text.trim();
  //   if (phone.isEmpty) {
  //     return 'استخدم الصيغة الدولية +966XXXXXXXXX';
  //   }
  //
  //   if (PhoneNumberFormatter.isValid(phone)) {
  //     final carrier = PhoneNumberFormatter.getCarrier(phone);
  //     final formatted = PhoneNumberFormatter.display(phone);
  //     return 'رقم صحيح • $carrier • $formatted';
  //   } else {
  //     return PhoneNumberFormatter.getValidationError(phone);
  //   }
  // }

  /// الحصول على لون نص المساعد للهاتف
  Color _getPhoneHelperColor() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      return Colors.grey.shade600;
    }

    if (PhoneNumberFormatter.isValid(phone)) {
      return AppConstants.successGreen;
    } else {
      return AppConstants.errorRed;
    }
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

      final name = _nameController.text.trim();
      final phone = PhoneNumberFormatter.format(_phoneController.text.trim());
      final note = _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim();

      widget.onSave(name, phone, note);

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
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}