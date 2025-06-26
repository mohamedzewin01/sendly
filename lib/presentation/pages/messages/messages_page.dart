import 'package:flutter/material.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/constants/app_strings.dart';
import '../../../core/helpers/responsive_helper.dart';
import '../../../core/helpers/statistics_helper.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/contact.dart';
import '../../../data/models/message.dart';
import '../../widgets/message/message_card.dart';
import '../../widgets/message/message_dialog.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/stats/stats_card.dart';

/// صفحة إدارة الرسائل المحفوظة
class MessagesPage extends StatefulWidget {
  final List<Message> messages;
  final List<Contact> contacts;
  final Function(Message) onAddMessage;
  final Function(Message) onUpdateMessage;
  final Function(String) onDeleteMessage;
  final Function(String, String) onSendMessage;

  const MessagesPage({
    super.key,
    required this.messages,
    required this.contacts,
    required this.onAddMessage,
    required this.onUpdateMessage,
    required this.onDeleteMessage,
    required this.onSendMessage,
  });

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Message> _filteredMessages = [];
  String _sortBy = 'date'; // date, title, usage, length
  bool _sortAscending = false;
  MessageCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _filteredMessages = List.from(widget.messages);
    _searchController.addListener(_filterMessages);
    _sortMessages();
  }

  @override
  void didUpdateWidget(MessagesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messages != widget.messages) {
      setState(() {
        _filteredMessages = List.from(widget.messages);
        _sortMessages();
      });
    }
  }

  /// تصفية الرسائل
  void _filterMessages() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMessages = widget.messages.where((message) {
        final matchesQuery = message.matches(query);
        final matchesCategory = _selectedCategory == null ||
            message.category == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
      _sortMessages();
    });
  }

  /// ترتيب الرسائل
  void _sortMessages() {
    switch (_sortBy) {
      case 'date':
        _filteredMessages = Message.sortByDate(_filteredMessages, ascending: _sortAscending);
        break;
      case 'title':
        _filteredMessages = Message.sortAlphabetically(_filteredMessages);
        if (!_sortAscending) {
          _filteredMessages = _filteredMessages.reversed.toList();
        }
        break;
      case 'usage':
        _filteredMessages = Message.sortByUsage(_filteredMessages, ascending: _sortAscending);
        break;
      case 'length':
        _filteredMessages = Message.sortByLength(_filteredMessages, ascending: _sortAscending);
        break;
    }
  }

  /// تغيير طريقة الترتيب
  void _changeSorting(String sortBy) {
    setState(() {
      if (_sortBy == sortBy) {
        _sortAscending = !_sortAscending;
      } else {
        _sortBy = sortBy;
        _sortAscending = sortBy == 'date' ? false : true;
      }
      _sortMessages();
    });
  }

  /// تغيير تصنيف التصفية
  void _changeCategory(MessageCategory? category) {
    setState(() {
      _selectedCategory = category;
      _filterMessages();
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
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildStatsSection(isMobile),
                  const SizedBox(height: 20),
                  _buildSearchAndFilters(isMobile),
                  const SizedBox(height: 20),
                  _buildCategoryFilters(),
                  const SizedBox(height: 20),
                  // Expanded(
                  //   child: _buildMessagesList(isMobile),
                  // ),
                ],
              ),
            ),
            _buildMessagesList(isMobile)
          ],

        ),
      ),
    );
  }

  /// بناء قسم الإحصائيات
  Widget _buildStatsSection(bool isMobile) {
    final stats = StatisticsHelper.getMessageStatistics(widget.messages);

    return StatsCard(
      title: AppStrings.savedMessages,
      count: stats.total.toString(),
      icon: Icons.message,
      color: AppConstants.warningOrange,
      onTap: _showAddMessageDialog,
      subtitle: 'متوسط الطول: ${stats.averageLength} حرف',
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
            hintText: 'البحث في الرسائل...',
            prefixIcon: const Icon(Icons.search, color: AppConstants.warningOrange),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
              },
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

        // أزرار الترتيب
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSortButton('date', 'التاريخ', Icons.date_range),
              const SizedBox(width: 8),
              _buildSortButton('title', 'الاسم', Icons.sort_by_alpha),
              const SizedBox(width: 8),
              _buildSortButton('usage', 'الاستخدام', Icons.trending_up),
              const SizedBox(width: 8),
              _buildSortButton('length', 'الطول', Icons.text_fields),
            ],
          ),
        ),
      ],
    );
  }

  /// بناء زر الترتيب
  Widget _buildSortButton(String sortKey, String label, IconData icon) {
    final isActive = _sortBy == sortKey;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isActive ? Colors.white : AppConstants.warningOrange,
          ),
          const SizedBox(width: 4),
          Text(label),
          if (isActive) ...[
            const SizedBox(width: 4),
            Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
              color: Colors.white,
            ),
          ],
        ],
      ),
      selected: isActive,
      onSelected: (_) => _changeSorting(sortKey),
      selectedColor: AppConstants.warningOrange,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isActive ? Colors.white : AppConstants.warningOrange,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// بناء مرشحات التصنيف
  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip(null, 'الكل'),
          const SizedBox(width: 8),
          ...MessageCategory.values.map((category) =>
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildCategoryChip(category, category.displayName),
              ),
          ),
        ],
      ),
    );
  }

  /// بناء رقاقة التصنيف
  Widget _buildCategoryChip(MessageCategory? category, String label) {
    final isSelected = _selectedCategory == category;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _changeCategory(category),
      selectedColor: AppConstants.whatsappGreen.withOpacity(0.2),
      checkmarkColor: AppConstants.whatsappGreen,
      labelStyle: TextStyle(
        color: isSelected ? AppConstants.whatsappGreen : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppConstants.whatsappGreen : Colors.grey[300]!,
      ),
    );
  }

  /// بناء قائمة الرسائل
  Widget _buildMessagesList(bool isMobile) {
    if (_filteredMessages.isEmpty) {
      if (widget.messages.isEmpty) {
        return SliverToBoxAdapter(
          child: EmptyStateWidget(
            icon: Icons.message_outlined,
            title: AppStrings.noMessages,
            subtitle: AppStrings.startByAddingMessages,
            actionText: AppStrings.addMessage,
            onActionPressed: _showAddMessageDialog,
          ),
        );
      } else {
        return SliverToBoxAdapter(
          child: const EmptyStateWidget(
            icon: Icons.search_off,
            title: 'لا توجد نتائج',
            subtitle: 'جرب تغيير كلمات البحث أو التصنيف',
          ),
        );
      }
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildMessageItem(_filteredMessages[index]),
        childCount: _filteredMessages.length,
      ),
    );
    //   itemCount: _filteredMessages.length,
    //   itemBuilder: (context, index) {
    //     return _buildMessageItem(_filteredMessages[index]);
    //   },
    // );
  }

  /// بناء عنصر رسالة
  Widget _buildMessageItem(Message message) {
    return MessageCard(
      message: message,
      onEdit: () => _showEditMessageDialog(message),
      onDelete: () => _deleteMessage(message),
      onSend: () => _sendMessageToContact(message),
      onUse: () => _useMessage(message),
    );
  }

  /// عرض حوار إضافة رسالة
  void _showAddMessageDialog() {
    showDialog(
      context: context,
      builder: (context) => MessageDialog(
        title: AppStrings.addMessage,
        onSave: (title, content, category) {
          final message = Message.create(
            title: title,
            content: content,
            category: category,
          );
          widget.onAddMessage(message);
          setState(() {
            _filteredMessages.add(message);
            _sortMessages();
          });

        },
      ),
    );
  }

  /// عرض حوار تعديل رسالة
  void _showEditMessageDialog(Message message) {
    showDialog(
      context: context,
      builder: (context) => MessageDialog(
        title: AppStrings.editMessage,
        initialTitle: message.title,
        initialContent: message.content,
        initialCategory: message.category,
        onSave: (title, content, category) {
          final updatedMessage = message.copyWith(
            title: title,
            content: content,
            category: category,
          );
          widget.onUpdateMessage(updatedMessage);
          setState(() {
            final index = _filteredMessages.indexWhere((m) => m.id == updatedMessage.id);
            if (index != -1) {
              _filteredMessages[index] = updatedMessage;
              _sortMessages();
            }
          });

        },
      ),
    );
  }

  /// حذف رسالة
  void _deleteMessage(Message message) async {
    final confirmed = await AppUtils.showConfirmDialog(
      context,
      AppStrings.confirmDeleteMessage,
      'هل تريد حذف "${message.title}"؟',
      confirmText: AppStrings.delete,
      isDestructive: true,
      icon: Icons.delete_forever,
    );

    if (confirmed == true) {
      // استدعاء الدالة الخارجية للحذف من المصدر
      widget.onDeleteMessage(message.id);

      // حذف فوري من القائمة المعروضة
      setState(() {
        _filteredMessages.removeWhere((m) => m.id == message.id);
      });
    }
  }


  /// إرسال رسالة لجهة اتصال
  void _sendMessageToContact(Message message) {
    if (widget.contacts.isEmpty) {
      AppUtils.showCustomSnackBar(
        context,
        'لا توجد جهات اتصال لإرسال الرسالة إليها',
        isError: true,
      );
      return;
    }

    _showContactSelectionDialog(message);
  }

  /// عرض حوار اختيار جهة الاتصال
  void _showContactSelectionDialog(Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر جهة الاتصال'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: widget.contacts.length,
            itemBuilder: (context, index) {
              final contact = widget.contacts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppConstants.whatsappGreen,
                  child: Text(
                    contact.initials,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(contact.name),
                subtitle: Text(contact.displayPhone),
                onTap: () {
                  Navigator.pop(context);
                  widget.onSendMessage(contact.phone, message.content);

                  // زيادة عداد الاستخدام
                  final updatedMessage = message.incrementUsage();
                  widget.onUpdateMessage(updatedMessage);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  /// استخدام رسالة (نسخ إلى الحافظة)
  void _useMessage(Message message) {
    AppUtils.copyToClipboard(context, message.content);

    // زيادة عداد الاستخدام
    final updatedMessage = message.incrementUsage();
    widget.onUpdateMessage(updatedMessage);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}