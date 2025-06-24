import 'package:flutter/material.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/constants/app_strings.dart';
import '../../../core/helpers/responsive_helper.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/contact.dart';
import '../../widgets/common/empty_state_widget.dart';

/// صفحة الإرسال الجماعي
class BulkSendPage extends StatefulWidget {
  final List<Contact> contacts;
  final Function(List<Contact>, String) onSendBulkMessage;

  const BulkSendPage({
    super.key,
    required this.contacts,
    required this.onSendBulkMessage,
  });

  @override
  State<BulkSendPage> createState() => _BulkSendPageState();
}

class _BulkSendPageState extends State<BulkSendPage>
    with SingleTickerProviderStateMixin {

  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  List<Contact> _selectedContacts = [];
  List<Contact> _filteredContacts = [];
  bool _selectAll = false;
  String _filterBy = 'all'; // all, valid, invalid

  @override
  void initState() {
    super.initState();
    _filteredContacts = List.from(widget.contacts);
    _searchController.addListener(_filterContacts);
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: AppConstants.normalAnimation,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(BulkSendPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contacts != widget.contacts) {
      _filteredContacts = List.from(widget.contacts);
      _selectedContacts.clear();
      _selectAll = false;
      _filterContacts();
    }
  }

  /// تصفية جهات الاتصال
  void _filterContacts() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredContacts = widget.contacts.where((contact) {
        final matchesQuery = contact.matches(query);
        final matchesFilter = _filterBy == 'all' ||
            (_filterBy == 'valid' && contact.hasValidPhone) ||
            (_filterBy == 'invalid' && !contact.hasValidPhone);

        return matchesQuery && matchesFilter;
      }).toList();

      // إزالة جهات الاتصال المحددة التي لم تعد في القائمة المصفاة
      _selectedContacts.removeWhere(
            (selected) => !_filteredContacts.contains(selected),
      );

      _updateSelectAllState();
    });
  }

  /// تحديث حالة "اختيار الكل"
  void _updateSelectAllState() {
    _selectAll = _filteredContacts.isNotEmpty &&
        _selectedContacts.length == _filteredContacts.length;
  }

  /// تبديل اختيار جهة اتصال
  void _toggleContactSelection(Contact contact) {
    setState(() {
      if (_selectedContacts.contains(contact)) {
        _selectedContacts.remove(contact);
      } else {
        _selectedContacts.add(contact);
      }
      _updateSelectAllState();
    });
  }

  /// تبديل اختيار الكل
  void _toggleSelectAll() {
    setState(() {
      if (_selectAll) {
        _selectedContacts.clear();
        _selectAll = false;
      } else {
        _selectedContacts = List.from(_filteredContacts);
        _selectAll = true;
      }
    });
  }

  /// تغيير نوع التصفية
  void _changeFilter(String filterBy) {
    setState(() {
      _filterBy = filterBy;
      _filterContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF8F9FA), Color(0xFFE8F5E8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildMainCard(context, isMobile),
                    const SizedBox(height: 20),
                    if (widget.contacts.isEmpty)
                      _buildEmptyState()
                    else ...[
                      _buildSearchAndFilters(isMobile),
                      const SizedBox(height: 20),
                      _buildContactsList(context, isMobile),
                    ],
                  ],
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
      padding: EdgeInsets.all(isMobile ? 20 : 24),
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
      ),
      child: Column(
        children: [
          _buildCardHeader(isMobile),
          const SizedBox(height: 20),
          _buildMessageInput(isMobile),
          if (_selectedContacts.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSelectionInfo(isMobile),
          ],
          const SizedBox(height: 20),
          _buildActionButtons(isMobile),
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
            gradient: AppConstants.whatsappGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.group,
            color: Colors.white,
            size: isMobile ? 24 : 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.bulkSend,
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.bulkSendDescription,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
            ],
          ),
        ),
        if (widget.contacts.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppConstants.whatsappGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppConstants.whatsappGreen.withOpacity(0.3),
              ),
            ),
            child: Text(
              '${_selectedContacts.length}/${widget.contacts.length}',
              style: const TextStyle(
                color: AppConstants.whatsappGreen,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  /// بناء حقل إدخال الرسالة
  Widget _buildMessageInput(bool isMobile) {
    return TextFormField(
      controller: _messageController,
      maxLines: isMobile ? 4 : 5,
      maxLength: AppConstants.maxMessageLength,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppStrings.fieldRequired;
        }
        if (value.length < 10) {
          return 'الرسالة قصيرة جداً';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: AppStrings.bulkMessageHint,
        hintText: 'اكتب الرسالة التي تريد إرسالها لجميع جهات الاتصال المحددة',
        prefixIcon: const Icon(Icons.message, color: AppConstants.whatsappGreen),
        suffixIcon: _messageController.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => _messageController.clear(),
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[50],
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
        helperText: 'عدد الأحرف: ${_messageController.text.length}',
      ),
      onChanged: (value) => setState(() {}),
    );
  }

  /// بناء معلومات الاختيار
  Widget _buildSelectionInfo(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConstants.whatsappGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppConstants.whatsappGreen.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppConstants.whatsappGreen,
            size: isMobile ? 20 : 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'سيتم إرسال الرسالة إلى ${_selectedContacts.length} جهة اتصال',
              style: TextStyle(
                color: AppConstants.whatsappDarkGreen,
                fontWeight: FontWeight.w600,
                fontSize: isMobile ? 14 : 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedContacts.clear();
                _selectAll = false;
              });
            },
            child: const Text(
              'إلغاء الاختيار',
              style: TextStyle(color: AppConstants.whatsappGreen),
            ),
          ),
        ],
      ),
    );
  }

  /// بناء أزرار العمل
  Widget _buildActionButtons(bool isMobile) {
    final canSend = _selectedContacts.isNotEmpty &&
        _messageController.text.isNotEmpty;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: canSend ? _handleBulkSend : null,
              icon: const Icon(Icons.send, size: 20),
              label: Text(
                AppStrings.sendToSelected,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.whatsappGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: canSend ? 4 : 0,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: widget.contacts.isNotEmpty ? _toggleSelectAll : null,
              icon: Icon(
                _selectAll ? Icons.clear_all : Icons.select_all,
                size: 20,
              ),
              label: Text(
                _selectAll ? 'إلغاء الكل' : 'اختيار الكل',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppConstants.whatsappGreen,
                side: const BorderSide(color: AppConstants.whatsappGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// بناء قسم البحث والتصفية
  Widget _buildSearchAndFilters(bool isMobile) {
    return Column(
      children: [
        // شريط البحث
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'البحث في جهات الاتصال...',
            prefixIcon: const Icon(Icons.search, color: AppConstants.whatsappGreen),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => _searchController.clear(),
            )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),

        // مرشحات التصفية
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('all', 'الكل', widget.contacts.length),
              const SizedBox(width: 8),
              _buildFilterChip(
                'valid',
                'أرقام صحيحة',
                widget.contacts.where((c) => c.hasValidPhone).length,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'invalid',
                'أرقام غير صحيحة',
                widget.contacts.where((c) => !c.hasValidPhone).length,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// بناء رقاقة التصفية
  Widget _buildFilterChip(String filterKey, String label, int count) {
    final isActive = _filterBy == filterKey;

    return FilterChip(
      label: Text('$label ($count)'),
      selected: isActive,
      onSelected: (_) => _changeFilter(filterKey),
      selectedColor: AppConstants.whatsappGreen.withOpacity(0.2),
      checkmarkColor: AppConstants.whatsappGreen,
      labelStyle: TextStyle(
        color: isActive ? AppConstants.whatsappGreen : Colors.grey[700],
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isActive ? AppConstants.whatsappGreen : Colors.grey[300]!,
      ),
    );
  }

  /// بناء قائمة جهات الاتصال
  Widget _buildContactsList(BuildContext context, bool isMobile) {
    return Container(
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
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: AppConstants.whatsappGreen.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.largeBorderRadius),
                topRight: Radius.circular(AppConstants.largeBorderRadius),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.contacts, color: AppConstants.whatsappGreen),
                const SizedBox(width: 12),
                Text(
                  'جهات الاتصال (${_filteredContacts.length})',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.whatsappGreen,
                  ),
                ),
              ],
            ),
          ),

          if (_filteredContacts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد نتائج',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'جرب تغيير كلمات البحث أو المرشح',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredContacts.length,
              itemBuilder: (context, index) {
                return _buildContactItem(_filteredContacts[index]);
              },
            ),
        ],
      ),
    );
  }

  /// بناء عنصر جهة اتصال
  Widget _buildContactItem(Contact contact) {
    final isSelected = _selectedContacts.contains(contact);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? AppConstants.whatsappGreen.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: AppConstants.whatsappGreen, width: 1)
            : null,
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (bool? value) => _toggleContactSelection(contact),
        title: Text(
          contact.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? AppConstants.whatsappGreen : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contact.displayPhone,
              style: TextStyle(
                color: isSelected
                    ? AppConstants.whatsappGreen.withOpacity(0.8)
                    : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  contact.hasValidPhone ? Icons.check_circle : Icons.error,
                  size: 14,
                  color: contact.hasValidPhone
                      ? AppConstants.successGreen
                      : AppConstants.errorRed,
                ),
                const SizedBox(width: 4),
                Text(
                  contact.hasValidPhone ? contact.carrier : 'رقم غير صحيح',
                  style: TextStyle(
                    fontSize: 12,
                    color: contact.hasValidPhone
                        ? AppConstants.successGreen
                        : AppConstants.errorRed,
                  ),
                ),
              ],
            ),
          ],
        ),
        secondary: CircleAvatar(
          backgroundColor: isSelected
              ? AppConstants.whatsappGreen
              : Colors.grey[400],
          child: Text(
            contact.initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        activeColor: AppConstants.whatsappGreen,
        checkColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
    );
  }

  /// بناء حالة فارغة
  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: Icons.group_off,
      title: AppStrings.noContacts,
      subtitle: AppStrings.startByAddingContacts,
      actionText: 'انتقل إلى جهات الاتصال',
      onActionPressed: () {
        // يمكن إضافة منطق للانتقال لتبويب جهات الاتصال
        AppUtils.showCustomSnackBar(
          context,
          'انتقل إلى تبويب "الجهات" لإضافة جهات اتصال',
          isWarning: true,
        );
      },
    );
  }

  /// معالج الإرسال الجماعي
  void _handleBulkSend() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedContacts.isEmpty) {
      AppUtils.showCustomSnackBar(
        context,
        AppStrings.noContactsSelected,
        isError: true,
      );
      return;
    }

    // التحقق من وجود أرقام غير صحيحة
    final invalidContacts = _selectedContacts
        .where((contact) => !contact.hasValidPhone)
        .toList();

    if (invalidContacts.isNotEmpty) {
      final confirmed = await AppUtils.showConfirmDialog(
        context,
        'أرقام غير صحيحة',
        'يوجد ${invalidContacts.length} جهة اتصال بأرقام غير صحيحة. هل تريد المتابعة مع الأرقام الصحيحة فقط؟',
        confirmText: 'متابعة',
        icon: Icons.warning,
      );

      if (confirmed != true) return;

      // إرسال للأرقام الصحيحة فقط
      final validContacts = _selectedContacts
          .where((contact) => contact.hasValidPhone)
          .toList();

      if (validContacts.isEmpty) {
        AppUtils.showCustomSnackBar(
          context,
          'لا توجد أرقام صحيحة للإرسال',
          isError: true,
        );
        return;
      }

      _performBulkSend(validContacts);
    } else {
      _performBulkSend(_selectedContacts);
    }
  }

  /// تنفيذ الإرسال الجماعي
  void _performBulkSend(List<Contact> contacts) {
    // عرض تأكيد أخير
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإرسال'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('سيتم إرسال الرسالة إلى ${contacts.length} جهة اتصال:'),
            const SizedBox(height: 12),
            Container(
              height: 150,
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppConstants.whatsappGreen,
                      child: Text(
                        contact.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      contact.name,
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      contact.displayPhone,
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onSendBulkMessage(contacts, _messageController.text);
              _resetForm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.whatsappGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  /// إعادة تعيين النموذج
  void _resetForm() {
    setState(() {
      _messageController.clear();
      _selectedContacts.clear();
      _selectAll = false;
    });

    // إعادة تشغيل الرسم المتحرك
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}