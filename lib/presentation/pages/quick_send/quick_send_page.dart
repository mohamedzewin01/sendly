import 'package:flutter/material.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/constants/app_strings.dart';
import '../../../core/helpers/responsive_helper.dart';
import '../../../core/helpers/phone_formatter.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/message.dart';

/// صفحة الإرسال السريع
class QuickSendPage extends StatefulWidget {
  final List<Message> messages;
  final Function(String, String) onSendMessage;
  final Function(Message) onUpdateMessage;

  const QuickSendPage({
    super.key,
    required this.messages,
    required this.onSendMessage,
    required this.onUpdateMessage,
  });

  @override
  State<QuickSendPage> createState() => _QuickSendPageState();
}

class _QuickSendPageState extends State<QuickSendPage>
    with SingleTickerProviderStateMixin {

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  String? _selectedMessageId;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: AppConstants.normalAnimation,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF7F8FC), Color(0xFFE8F5E8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMainCard(context, isMobile),
                      if (widget.messages.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildSavedMessagesSection(context, isMobile),
                      ],
                      const SizedBox(height: 24),
                      _buildQuickTipsSection(isMobile),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// بناء البطاقة الرئيسية
  Widget _buildMainCard(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        gradient: AppConstants.whatsappGradient,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppConstants.whatsappGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(isMobile),
          const SizedBox(height: 24),
          _buildInputForm(context, isMobile),
        ],
      ),
    );
  }

  /// بناء رأس البطاقة
  Widget _buildCardHeader(bool isMobile) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.send_rounded,
            color: Colors.white,
            size: isMobile ? 28 : 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.quickSend,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 22 : 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.quickSendDescription,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// بناء نموذج الإدخال
  Widget _buildInputForm(BuildContext context, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        child: Column(
          children: [
            _buildPhoneField(isMobile),
            const SizedBox(height: 20),
            _buildMessageField(isMobile),
            const SizedBox(height: 24),
            _buildSendButton(isMobile),
          ],
        ),
      ),
    );
  }

  /// بناء حقل رقم الهاتف
  Widget _buildPhoneField(bool isMobile) {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textDirection: TextDirection.ltr,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppStrings.fieldRequired;
        }

        final validationError = PhoneNumberFormatter.getValidationError(value);
        if (validationError.isNotEmpty) {
          return validationError;
        }

        return null;
      },
      decoration: InputDecoration(
        labelText: AppStrings.phoneNumber,
        hintText: AppStrings.phoneHint,
        prefixIcon: const Icon(Icons.phone, color: AppConstants.whatsappGreen),
        suffixIcon: _phoneController.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => _phoneController.clear(),
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppConstants.whatsappGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppConstants.errorRed,
            width: 1,
          ),
        ),
      ),
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  /// بناء حقل الرسالة
  Widget _buildMessageField(bool isMobile) {
    return TextFormField(
      controller: _messageController,
      maxLines: isMobile ? 4 : 5,
      maxLength: AppConstants.maxMessageLength,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppStrings.fieldRequired;
        }
        if (value.length < 5) {
          return 'الرسالة قصيرة جداً';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: AppStrings.messageText,
        hintText: AppStrings.messageContentHint,
        prefixIcon: const Icon(Icons.message, color: AppConstants.whatsappGreen),
        suffixIcon: _messageController.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _messageController.clear();
            setState(() {
              _selectedMessageId = null;
            });
          },
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppConstants.whatsappGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppConstants.errorRed,
            width: 1,
          ),
        ),
        helperText: 'عدد الأحرف: ${_messageController.text.length}',
      ),
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  /// بناء زر الإرسال
  Widget _buildSendButton(bool isMobile) {
    final isValid = _phoneController.text.isNotEmpty &&
        _messageController.text.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isValid ? _handleSendMessage : null,
        icon: const Icon(Icons.send, size: 24),
        label: Text(
          AppStrings.sendViaWhatsApp,
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.whatsappGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isValid ? 4 : 0,
        ),
      ),
    );
  }

  /// بناء قسم الرسائل المحفوظة
  Widget _buildSavedMessagesSection(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.bookmark,
              color: AppConstants.warningOrange,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              AppStrings.savedMessages,
              style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.whatsappDarkGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: isMobile ? 140 : 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.messages.length,
            itemBuilder: (context, index) {
              final message = widget.messages[index];
              final isSelected = _selectedMessageId == message.id;

              return GestureDetector(
                onTap: () => _selectMessage(message),
                child: Container(
                  width: isMobile ? 220 : 260,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppConstants.whatsappLight
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppConstants.whatsappGreen
                          : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? AppConstants.whatsappGradient
                                    : LinearGradient(
                                  colors: [
                                    Colors.grey.shade300,
                                    Colors.grey.shade400,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.message_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                message.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 14 : 16,
                                  color: isSelected
                                      ? AppConstants.whatsappDarkGreen
                                      : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Text(
                            message.content,
                            style: TextStyle(
                              color: isSelected
                                  ? AppConstants.whatsappDarkGreen.withOpacity(0.8)
                                  : Colors.grey[600],
                              fontSize: isMobile ? 12 : 14,
                              height: 1.4,
                            ),
                            maxLines: isMobile ? 3 : 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppConstants.whatsappGreen.withOpacity(0.2)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                AppStrings.tapToUse,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppConstants.whatsappDarkGreen
                                      : Colors.grey[600],
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (message.usageCount > 0)
                              Text(
                                'استُخدم ${message.usageCount} مرة',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// بناء قسم النصائح السريعة
  Widget _buildQuickTipsSection(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.infoBlue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppConstants.infoBlue,
                size: isMobile ? 20 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                'نصائح سريعة',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.infoBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTip('استخدم الصيغة الدولية للأرقام: +966501234567'),
          _buildTip('احفظ رسائلك المتكررة لاستخدامها بسرعة'),
          _buildTip('يمكنك مسح الحقول بالضغط على أيقونة X'),
        ],
      ),
    );
  }

  /// بناء نصيحة واحدة
  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppConstants.successGreen,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// اختيار رسالة محفوظة
  void _selectMessage(Message message) {
    setState(() {
      _messageController.text = message.content;
      _selectedMessageId = message.id;
    });

    AppUtils.showCustomSnackBar(
      context,
      'تم اختيار الرسالة: ${message.title}',
      isSuccess: true,
    );
  }

  /// معالج إرسال الرسالة
  void _handleSendMessage() {
    if (_formKey.currentState!.validate()) {
      final phone = _phoneController.text;
      final message = _messageController.text;

      widget.onSendMessage(phone, message);

      // تحديث عداد الاستخدام للرسالة المحددة
      if (_selectedMessageId != null) {
        final selectedMessage = widget.messages
            .where((m) => m.id == _selectedMessageId)
            .firstOrNull;

        if (selectedMessage != null) {
          final updatedMessage = selectedMessage.incrementUsage();
          widget.onUpdateMessage(updatedMessage);
        }
      }

      // مسح الحقول
      _phoneController.clear();
      _messageController.clear();
      setState(() {
        _selectedMessageId = null;
      });

      // إعادة تشغيل الرسم المتحرك
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}