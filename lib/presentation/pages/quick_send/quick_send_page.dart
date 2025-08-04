// import 'package:flutter/material.dart';
// import 'package:sendly/core/utils/ad_manger.dart';
// import '../../../app/constants/app_constants.dart';
// import '../../../app/constants/app_strings.dart';
// import '../../../core/helpers/responsive_helper.dart';
// import '../../../core/helpers/phone_formatter.dart';
// import '../../../core/utils/app_utils.dart';
// import '../../../data/models/message.dart';
//
// /// صفحة الإرسال السريع
// class QuickSendPage extends StatefulWidget {
//   final List<Message> messages;
//   final Function(String, String) onSendMessage;
//   final Function(Message) onUpdateMessage;
//
//   const QuickSendPage({
//     super.key,
//     required this.messages,
//     required this.onSendMessage,
//     required this.onUpdateMessage,
//   });
//
//   @override
//   State<QuickSendPage> createState() => _QuickSendPageState();
// }
//
// class _QuickSendPageState extends State<QuickSendPage>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _messageController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   late AnimationController _animationController;
//   late Animation<double> _slideAnimation;
//   late Animation<double> _fadeAnimation;
//
//   bool _isBannerAdLoaded = false;
//
//
//
//   String? _selectedMessageId;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _initializeAnimations();
//   }
//
//   void _initializeAnimations() {
//     _animationController = AnimationController(
//       duration: AppConstants.normalAnimation,
//       vsync: this,
//     );
//
//     _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
//     );
//
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
//     );
//
//     _animationController.forward();
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     final padding = ResponsiveHelper.getResponsivePadding(context);
//     final isMobile = ResponsiveHelper.isMobile(context);
//
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xFFF7F8FC), Color(0xFFE8F5E8)],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//       ),
//       child: AnimatedBuilder(
//         animation: _animationController,
//         builder: (context, child) {
//           return Transform.translate(
//             offset: Offset(0, _slideAnimation.value),
//             child: FadeTransition(
//               opacity: _fadeAnimation,
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.all(padding),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildMainCard(context, isMobile),
//                       if (widget.messages.isNotEmpty) ...[
//                         const SizedBox(height: 24),
//                         _buildSavedMessagesSection(context, isMobile),
//                       ],
//                       const SizedBox(height: 5),
//
//
//                       _buildQuickTipsSection(isMobile),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   /// بناء البطاقة الرئيسية
//   Widget _buildMainCard(BuildContext context, bool isMobile) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(isMobile ? 20 : 24),
//       decoration: BoxDecoration(
//         gradient: AppConstants.appGradient,
//         borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
//         boxShadow: [
//           BoxShadow(
//             color: AppConstants.appGreen.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildCardHeader(isMobile),
//           const SizedBox(height: 24),
//           _buildInputForm(context, isMobile),
//         ],
//       ),
//     );
//   }
//
//   /// بناء رأس البطاقة
//   Widget _buildCardHeader(bool isMobile) {
//     return Row(
//       children: [
//         Container(
//           padding: EdgeInsets.all(isMobile ? 12 : 16),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Icon(
//             Icons.open_in_new,
//             color: Colors.white,
//             size: isMobile ? 28 : 32,
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 AppStrings.quickSend,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: isMobile ? 22 : 26,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 AppStrings.quickSendDescription,
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.9),
//                   fontSize: isMobile ? 14 : 16,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   /// بناء نموذج الإدخال
//   Widget _buildInputForm(BuildContext context, bool isMobile) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(isMobile ? 20 : 24),
//         child: Column(
//           children: [
//             _buildPhoneField(isMobile),
//             const SizedBox(height: 20),
//             _buildMessageField(isMobile),
//             const SizedBox(height: 24),
//             _buildSendButton(isMobile),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// بناء حقل رقم الهاتف
//   Widget _buildPhoneField(bool isMobile) {
//     return TextFormField(
//       controller: _phoneController,
//       keyboardType: TextInputType.phone,
//       textDirection: TextDirection.ltr,
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return AppStrings.fieldRequired;
//         }
//
//         final validationError = PhoneNumberFormatter.getValidationError(value);
//         if (validationError.isNotEmpty) {
//           return validationError;
//         }
//
//         return null;
//       },
//       decoration: InputDecoration(
//         labelText: AppStrings.phoneNumber,
//         hintText: AppStrings.phoneHint,
//         prefixIcon: const Icon(Icons.phone, color: AppConstants.appGreen),
//         suffixIcon: _phoneController.text.isNotEmpty
//             ? IconButton(
//                 icon: const Icon(Icons.clear),
//                 onPressed: () => _phoneController.clear(),
//               )
//             : null,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(
//             color: AppConstants.appGreen,
//             width: 2,
//           ),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppConstants.errorRed, width: 1),
//         ),
//       ),
//       onChanged: (value) {
//         setState(() {});
//       },
//     );
//   }
//
//   /// بناء حقل الرسالة
//   Widget _buildMessageField(bool isMobile) {
//     return TextFormField(
//       controller: _messageController,
//       maxLines: isMobile ? 4 : 5,
//       maxLength: AppConstants.maxMessageLength,
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return AppStrings.fieldRequired;
//         }
//         if (value.length < 5) {
//           return 'الرسالة قصيرة جداً';
//         }
//         return null;
//       },
//       decoration: InputDecoration(
//         labelText: AppStrings.messageText,
//         hintText: AppStrings.messageContentHint,
//         prefixIcon: const Icon(
//           Icons.message,
//           color: AppConstants.appGreen,
//         ),
//         suffixIcon: _messageController.text.isNotEmpty
//             ? IconButton(
//                 icon: const Icon(Icons.clear),
//                 onPressed: () {
//                   _messageController.clear();
//                   setState(() {
//                     _selectedMessageId = null;
//                   });
//                 },
//               )
//             : null,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(
//             color: AppConstants.appGreen,
//             width: 2,
//           ),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppConstants.errorRed, width: 1),
//         ),
//         helperText: 'عدد الأحرف: ${_messageController.text.length}',
//       ),
//       onChanged: (value) {
//         setState(() {});
//       },
//     );
//   }
//
//   /// بناء زر الإرسال
//   Widget _buildSendButton(bool isMobile) {
//     final isValid = _phoneController.text.isNotEmpty &&
//         _messageController.text.isNotEmpty;
//
//     return SizedBox(
//       width: double.infinity,
//       height: 56,
//       child: ElevatedButton.icon(
//         onPressed: isValid ? _handleSendMessage : null,
//         icon: const Icon(Icons.open_in_new, size: 24), // تم تغيير الأيقونة
//         label: Text(
//           AppStrings.openMessagingApp, // تم التغيير
//           style: TextStyle(
//             fontSize: isMobile ? 16 : 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppConstants.appGreen,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           elevation: isValid ? 4 : 0,
//         ),
//       ),
//     );
//   }
//
//   /// بناء قسم الرسائل المحفوظة
//   Widget _buildSavedMessagesSection(BuildContext context, bool isMobile) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             const Icon(
//               Icons.bookmark,
//               color: AppConstants.warningOrange,
//               size: 24,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               AppStrings.savedMessages,
//               style: TextStyle(
//                 fontSize: isMobile ? 18 : 20,
//                 fontWeight: FontWeight.bold,
//                 color: AppConstants.appDarkGreen,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         SizedBox(
//           height: isMobile ? 140 : 160,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: widget.messages.length,
//             itemBuilder: (context, index) {
//               final message = widget.messages[index];
//               final isSelected = _selectedMessageId == message.id;
//
//               return GestureDetector(
//                 onTap: () => _selectMessage(message),
//                 child: Container(
//                   width: isMobile ? 220 : 260,
//                   margin: const EdgeInsets.only(right: 16),
//                   decoration: BoxDecoration(
//                     color: isSelected
//                         ? AppConstants.appLight
//                         : Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: isSelected
//                           ? AppConstants.appGreen
//                           : Colors.grey.shade200,
//                       width: isSelected ? 2 : 1,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               width: 36,
//                               height: 36,
//                               decoration: BoxDecoration(
//                                 gradient: isSelected
//                                     ? AppConstants.appGradient
//                                     : LinearGradient(
//                                         colors: [
//                                           Colors.grey.shade300,
//                                           Colors.grey.shade400,
//                                         ],
//                                       ),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Icon(
//                                 Icons.message_rounded,
//                                 color: Colors.white,
//                                 size: 18,
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Text(
//                                 message.title,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: isMobile ? 14 : 16,
//                                   color: isSelected
//                                       ? AppConstants.appDarkGreen
//                                       : Colors.black87,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         Expanded(
//                           child: Text(
//                             message.content,
//                             style: TextStyle(
//                               color: isSelected
//                                   ? AppConstants.appDarkGreen.withOpacity(
//                                       0.8,
//                                     )
//                                   : Colors.grey[600],
//                               fontSize: isMobile ? 12 : 14,
//                               height: 1.4,
//                             ),
//                             maxLines: isMobile ? 3 : 4,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: isSelected
//                                     ? AppConstants.appGreen.withOpacity(
//                                         0.2,
//                                       )
//                                     : Colors.grey.shade100,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Text(
//                                 AppStrings.tapToUse,
//                                 style: TextStyle(
//                                   color: isSelected
//                                       ? AppConstants.appDarkGreen
//                                       : Colors.grey[600],
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                             if (message.usageCount > 0)
//                               Text(
//                                 'استُخدم ${message.usageCount} مرة',
//                                 style: TextStyle(
//                                   color: Colors.grey[400],
//                                   fontSize: 10,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   /// بناء قسم النصائح السريعة
//   Widget _buildQuickTipsSection(bool isMobile) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppConstants.infoBlue.withOpacity(0.2)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.lightbulb_outline,
//                 color: AppConstants.infoBlue,
//                 size: isMobile ? 20 : 24,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 'نصائح سريعة',
//                 style: TextStyle(
//                   fontSize: isMobile ? 16 : 18,
//                   fontWeight: FontWeight.bold,
//                   color: AppConstants.infoBlue,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           _buildTip('احفظ رسائلك المتكررة لاستخدامها بسرعة'),
//           _buildTip('يمكنك مسح الحقول بالضغط على أيقونة X'),
//
//         ],
//       ),
//     );
//   }
//
//   /// بناء نصيحة واحدة
//   Widget _buildTip(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(
//             Icons.check_circle_outline,
//             color: AppConstants.successGreen,
//             size: 16,
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[700],
//                 height: 1.3,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// اختيار رسالة محفوظة
//   void _selectMessage(Message message) {
//     setState(() {
//       _messageController.text = message.content;
//       _selectedMessageId = message.id;
//     });
//
//     AppUtils.showCustomSnackBar(
//       context,
//       'تم اختيار الرسالة: ${message.title}',
//       isSuccess: true,
//     );
//   }
//
//   /// معالج إرسال الرسالة
//   void _handleSendMessage() {
//     if (_formKey.currentState!.validate()) {
//       final phone = _phoneController.text;
//       final message = _messageController.text;
//
//       widget.onSendMessage(phone, message);
//
//       // تحديث عداد الاستخدام للرسالة المحددة
//       if (_selectedMessageId != null) {
//         final selectedMessage = widget.messages
//             .where((m) => m.id == _selectedMessageId)
//             .firstOrNull;
//
//         if (selectedMessage != null) {
//           final updatedMessage = selectedMessage.incrementUsage();
//           widget.onUpdateMessage(updatedMessage);
//         }
//       }
//
//       // مسح الحقول
//       // _phoneController.clear();
//       // _messageController.clear();
//       setState(() {
//         _selectedMessageId = null;
//       });
//
//       // إعادة تشغيل الرسم المتحرك
//       _animationController.reset();
//       _animationController.forward();
//     }
//   }
//
//   @override
//   void dispose() {
//     _phoneController.dispose();
//     _messageController.dispose();
//     _animationController.dispose();
//
//
//     super.dispose();
//   }
// }


import 'package:flutter/material.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/constants/app_strings.dart';
import '../../../core/helpers/responsive_helper.dart';
import '../../../core/helpers/phone_formatter.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/message.dart';

/// صفحة الإرسال السريع - تصميم محسن
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
    with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _buttonController;
  late AnimationController _cardController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _cardScaleAnimation;

  String? _selectedMessageId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startEntryAnimation();
  }

  void _initializeAnimations() {
    // الرسوم المتحركة للدخول
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // الرسوم المتحركة للزر
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // الرسوم المتحركة للبطاقات
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    _cardScaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.elasticOut,
    ));
  }

  void _startEntryAnimation() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _cardController.forward();
  }

  @override
  Widget build(BuildContext context) {
    // final padding = ResponsiveHelper.getResponsivePadding(context);
    // final padding = 8;
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF8FAFF),
            Color(0xFFF0F8FF),
            Color(0xFFE8F5E8),
          ],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // البطاقة الرئيسية
                    ScaleTransition(
                      scale: _cardScaleAnimation,
                      child: _buildEnhancedMainCard(context, isMobile),
                    ),

                    // الرسائل المحفوظة
                    if (widget.messages.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildEnhancedSavedMessagesSection(context, isMobile),
                    ],

                    const SizedBox(height: 16),

                    // النصائح السريعة
                    _buildEnhancedQuickTipsSection(isMobile),

                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// البطاقة الرئيسية المحسنة
  Widget _buildEnhancedMainCard(BuildContext context, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.appGreen,
            AppConstants.appGreen.withOpacity(0.8),
            const Color(0xFF2E7D32),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppConstants.appGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // خلفية ديكورية
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // المحتوى
            Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEnhancedCardHeader(isMobile),
                  const SizedBox(height: 16),
                  _buildEnhancedInputForm(context, isMobile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// رأس البطاقة المحسن
  Widget _buildEnhancedCardHeader(bool isMobile) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 8 : 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.rocket_launch_rounded,
            color: Colors.white,
            size: isMobile ? 32 : 36,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.quickSend,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 26 : 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.quickSendDescription,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: isMobile ? 15 : 17,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// نموذج الإدخال المحسن
  Widget _buildEnhancedInputForm(BuildContext context, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            children: [
              _buildEnhancedPhoneField(isMobile),
              const SizedBox(height: 16),
              _buildEnhancedMessageField(isMobile),
              const SizedBox(height:16),
              _buildEnhancedSendButton(isMobile),
            ],
          ),
        ),
      ),
    );
  }

  /// حقل رقم الهاتف المحسن
  Widget _buildEnhancedPhoneField(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.phoneNumber,
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w500,
          ),
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
            hintText: AppStrings.phoneHint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: isMobile ? 16 : 18,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.appGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.phone_rounded,
                color: AppConstants.appGreen,
                size: 20,
              ),
            ),
            suffixIcon: _phoneController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear_rounded, size: 20),
              onPressed: () => setState(() => _phoneController.clear()),
            )
                : null,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppConstants.appGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppConstants.errorRed, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  /// حقل الرسالة المحسن
  Widget _buildEnhancedMessageField(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.messageText,
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _messageController.text.length > AppConstants.maxMessageLength * 0.8
                    ? AppConstants.warningOrange.withOpacity(0.1)
                    : AppConstants.appGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_messageController.text.length}/${AppConstants.maxMessageLength}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _messageController.text.length > AppConstants.maxMessageLength * 0.8
                      ? AppConstants.warningOrange
                      : AppConstants.appGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _messageController,
          maxLines: isMobile ? 4 : 5,
          maxLength: AppConstants.maxMessageLength,
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
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
            hintText: AppStrings.messageContentHint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: isMobile ? 16 : 18,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.appGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.message_rounded,
                color: AppConstants.appGreen,
                size: 20,
              ),
            ),
            suffixIcon: _messageController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear_rounded, size: 20),
              onPressed: () {
                setState(() {
                  _messageController.clear();
                  _selectedMessageId = null;
                });
              },
            )
                : null,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppConstants.appGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppConstants.errorRed, width: 1),
            ),
            contentPadding: const EdgeInsets.all(16),
            counterText: '',
          ),
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  /// زر الإرسال المحسن
  Widget _buildEnhancedSendButton(bool isMobile) {
    final isValid = _phoneController.text.isNotEmpty &&
        _messageController.text.isNotEmpty &&
        !_isLoading;

    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: isValid
              ? LinearGradient(
            colors: [
              AppConstants.appGreen,
              AppConstants.appGreen.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: [
              Colors.grey[300]!,
              Colors.grey[400]!,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isValid
              ? [
            BoxShadow(
              color: AppConstants.appGreen.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isValid ? _handleSendMessage : null,
            onTapDown: isValid ? (_) => _buttonController.forward() : null,
            onTapUp: isValid ? (_) => _buttonController.reverse() : null,
            onTapCancel: isValid ? () => _buttonController.reverse() : null,
            child: Container(
              alignment: Alignment.center,
              child: _isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.openMessagingApp,
                    style: TextStyle(
                      fontSize: isMobile ? 17 : 19,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  /// قسم الرسائل المحفوظة المحسن
  Widget _buildEnhancedSavedMessagesSection(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.warningOrange.withOpacity(0.1),
                      AppConstants.warningOrange.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bookmark_rounded,
                  color: AppConstants.warningOrange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.savedMessages,
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'اضغط على أي رسالة لاستخدامها',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: isMobile ? 160 : 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: widget.messages.length,
            itemBuilder: (context, index) {
              final message = widget.messages[index];
              final isSelected = _selectedMessageId == message.id;

              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 300 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: _buildEnhancedMessageCard(message, isSelected, isMobile, index),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// بناء بطاقة الرسالة المحسنة
  Widget _buildEnhancedMessageCard(Message message, bool isSelected, bool isMobile, int index) {
    return GestureDetector(
      onTap: () => _selectMessage(message),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: isMobile ? 240 : 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [
              AppConstants.appLight,
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppConstants.appGreen
                : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppConstants.appGreen.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رأس البطاقة
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? AppConstants.appGradient
                          : LinearGradient(
                        colors: [
                          Colors.grey[300]!,
                          Colors.grey[400]!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.message_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: isMobile ? 15 : 17,
                        color: isSelected
                            ? AppConstants.appDarkGreen
                            : const Color(0xFF1A1A1A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // محتوى الرسالة
              Expanded(
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: isSelected
                        ? AppConstants.appDarkGreen.withOpacity(0.8)
                        : Colors.grey[600],
                    fontSize: isMobile ? 13 : 15,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: isMobile ? 3 : 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 12),

              // تذييل البطاقة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppConstants.appGreen.withOpacity(0.15)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      AppStrings.tapToUse,
                      style: TextStyle(
                        color: isSelected
                            ? AppConstants.appDarkGreen
                            : Colors.grey[600],
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (message.usageCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConstants.infoBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${message.usageCount}',
                        style: TextStyle(
                          color: AppConstants.infoBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// قسم النصائح السريعة المحسن
  Widget _buildEnhancedQuickTipsSection(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.infoBlue.withOpacity(0.05),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppConstants.infoBlue.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.infoBlue.withOpacity(0.1),
                      AppConstants.infoBlue.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.tips_and_updates_rounded,
                  color: AppConstants.infoBlue,
                  size: isMobile ? 24 : 28,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'نصائح سريعة',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.w700,
                  color: AppConstants.infoBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildEnhancedTip('احفظ رسائلك المتكررة لاستخدامها بسرعة', Icons.speed_rounded),
          _buildEnhancedTip('يمكنك مسح الحقول بالضغط على أيقونة X', Icons.clear_rounded),
          _buildEnhancedTip('الرسائل المحفوظة تظهر عدد مرات الاستخدام', Icons.analytics_rounded),
        ],
      ),
    );
  }

  /// بناء نصيحة واحدة محسنة
  Widget _buildEnhancedTip(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppConstants.successGreen,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// اختيار رسالة محفوظة مع رسوم متحركة
  void _selectMessage(Message message) {
    setState(() {
      _messageController.text = message.content;
      _selectedMessageId = message.id;
    });

    // رسوم متحركة للبطاقة المختارة
    _cardController.reset();
    _cardController.forward();

    AppUtils.showCustomSnackBar(
      context,
      'تم اختيار الرسالة: ${message.title}',
      isSuccess: true,
    );
  }

  /// معالج إرسال الرسالة مع حالة التحميل
  void _handleSendMessage() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // محاكاة تأخير التحميل
      await Future.delayed(const Duration(milliseconds: 500));

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

      setState(() {
        _selectedMessageId = null;
        _isLoading = false;
      });

      // إعادة تشغيل الرسوم المتحركة
      _slideController.reset();
      _fadeController.reset();
      _cardController.reset();

      _startEntryAnimation();
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _buttonController.dispose();
    _cardController.dispose();
    super.dispose();
  }
}