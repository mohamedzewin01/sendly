import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/constants/app_strings.dart';
import '../../../core/helpers/responsive_helper.dart';
import '../../../core/helpers/statistics_helper.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/contact.dart';
import '../../widgets/contact/contact_card.dart';
import '../../widgets/contact/contact_dialog.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/stats/stats_card.dart';

/// صفحة إدارة جهات الاتصال
class ContactsPage extends StatefulWidget {
  final List<Contact> contacts;
  final Function(Contact) onAddContact;
  final Function(Contact) onUpdateContact;
  final Function(String) onDeleteContact;
  final Function(String, String) onSendMessage;

  const ContactsPage({
    super.key,
    required this.contacts,
    required this.onAddContact,
    required this.onUpdateContact,
    required this.onDeleteContact,
    required this.onSendMessage,
  });

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _filteredContacts = [];
  String _sortBy = 'name'; // name, date, carrier
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _filteredContacts = List.from(widget.contacts);
    _searchController.addListener(_filterContacts);
  }

  @override
  void didUpdateWidget(covariant ContactsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contacts != widget.contacts) {
      setState(() {
        _filteredContacts = List.from(widget.contacts);
        _sortContacts();
      });
    }
  }

  /// تصفية جهات الاتصال
  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = widget.contacts
          .where((contact) => contact.matches(query))
          .toList();
      _sortContacts();
    });
  }

  /// ترتيب جهات الاتصال
  void _sortContacts() {
    switch (_sortBy) {
      case 'name':
        if (_sortAscending) {
          _filteredContacts = Contact.sortAlphabetically(_filteredContacts);
        } else {
          _filteredContacts = Contact.sortAlphabetically(
            _filteredContacts,
          ).reversed.toList();
        }
        break;
      case 'date':
        _filteredContacts = Contact.sortByDate(
          _filteredContacts,
          ascending: _sortAscending,
        );
        break;
      case 'carrier':
        _filteredContacts.sort((a, b) {
          final result = a.carrier.compareTo(b.carrier);
          return _sortAscending ? result : -result;
        });
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
        _sortAscending = true;
      }
      _sortContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final crossAxisCount = ResponsiveHelper.getCrossAxisCount(context);

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
          slivers:[
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildStatsSection(isMobile),
                  const SizedBox(height: 20),
                  _buildSearchAndFilters(isMobile),
                  const SizedBox(height: 20),
                  // Expanded(child: _buildContactsList(isMobile, crossAxisCount)),
                ],
              ),
            ),
            _buildContactsList(isMobile, crossAxisCount)
          ]
        ),
      ),
    );
  }

  /// بناء قسم الإحصائيات
  Widget _buildStatsSection(bool isMobile) {
    final stats = StatisticsHelper.getContactStatistics(widget.contacts);

    return StatsCard(
      title: AppStrings.contacts,
      count: stats.total.toString(),
      icon: Icons.contacts,
      color: AppConstants.appGreen,
      onTap: _showAddContactDialog,
      subtitle: 'أرقام صحيحة: ${stats.validPhones}',
    );
  }

  /// بناء قسم البحث والتصفية
  Widget _buildSearchAndFilters(bool isMobile) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'البحث في جهات الاتصال...',
            prefixIcon: const Icon(
              Icons.search,
              color: AppConstants.appGreen,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.defaultBorderRadius,
              ),
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
              _buildSortButton('name', 'الاسم', Icons.sort_by_alpha),
              const SizedBox(width: 8),
              _buildSortButton('date', 'التاريخ', Icons.date_range),
              const SizedBox(width: 8),
              _buildSortButton('carrier', 'الشركة', Icons.network_cell),
              const SizedBox(width: 8),
              // _buildFilterButton(),
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
            color: isActive ? Colors.white : AppConstants.appGreen,
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
      selectedColor: AppConstants.appGreen,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isActive ? Colors.white : AppConstants.appGreen,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// بناء زر التصفية المتقدمة
  Widget _buildFilterButton() {
    return ActionChip(
      label: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.filter_list, size: 16),
          SizedBox(width: 4),
          Text('تصفية'),
        ],
      ),
      onPressed: _showFilterDialog,
      backgroundColor: Colors.white,
      side: const BorderSide(color: AppConstants.appGreen),
    );
  }

  /// بناء قائمة جهات الاتصال
  Widget _buildContactsList(bool isMobile, int crossAxisCount) {
    if (_filteredContacts.isEmpty) {
      if (widget.contacts.isEmpty) {
        return SliverToBoxAdapter(
          child: EmptyStateWidget(
            icon: Icons.contacts_outlined,
            title: AppStrings.noContacts,
            subtitle: AppStrings.startByAddingContacts,
            actionText: AppStrings.addContact,
            onActionPressed: _showAddContactDialog,
          ),
        );
      } else {
        return SliverToBoxAdapter(
          child: const EmptyStateWidget(
            icon: Icons.search_off,
            title: 'لا توجد نتائج',
            subtitle: 'جرب تغيير كلمات البحث',
          ),
        );
      }
    }

    if (isMobile) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildContactItem(_filteredContacts[index]),
          childCount: _filteredContacts.length,
        ),

      );
    } else {
      return SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildContactItem(_filteredContacts[index]),
          childCount: _filteredContacts.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
        ),

      );
    }
  }

  /// بناء عنصر جهة اتصال
  Widget _buildContactItem(Contact contact) {
    return ContactCard(
      contact: contact,
      onEdit: () => _showEditContactDialog(contact),
      onDelete: () => _deleteContact(contact),
      onMessage: () => _sendMessageToContact(contact),
      onCall: () => _callContact(contact),
    );
  }

  /// عرض حوار إضافة جهة اتصال
  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) => ContactDialog(
        title: AppStrings.addContact,
        onSave: (name, phone, note) {
          final contact = Contact.create(name: name, phone: phone, note: note);
          widget.onAddContact(contact);
          setState(() {
            _filteredContacts.add(contact);
            _sortContacts();
          });
        },
      ),
    );
  }

  /// عرض حوار تعديل جهة اتصال
  void _showEditContactDialog(Contact contact) {
    showDialog(
      context: context,
      builder: (context) => ContactDialog(
        title: AppStrings.editContact,
        initialName: contact.name,
        initialPhone: contact.phone,
        initialNote: contact.note,
        onSave: (name, phone, note) {
          final updatedContact = contact.copyWith(
            name: name,
            phone: phone,
            note: note,
          );
          widget.onUpdateContact(updatedContact);
          setState(() {
            final index = _filteredContacts.indexWhere(
              (c) => c.id == updatedContact.id,
            );
            if (index != -1) {
              _filteredContacts[index] = updatedContact;
              _sortContacts();
            }
          });
        },
      ),
    );
  }

  /// حذف جهة اتصال
  void _deleteContact(Contact contact) async {
    final confirmed = await AppUtils.showConfirmDialog(
      context,
      AppStrings.confirmDeleteContact,
      'هل تريد حذف ${contact.name}؟',
      confirmText: AppStrings.delete,
      isDestructive: true,
      icon: Icons.delete_forever,
    );

    if (confirmed == true) {
      widget.onDeleteContact(contact.id);
      setState(() {
        _filteredContacts.removeWhere((c) => c.id == contact.id);
      });
    }
  }

  /// إرسال رسالة لجهة اتصال
  void _sendMessageToContact(Contact contact) {
    // يمكن تحسين هذا بإضافة اختيار رسالة
    const defaultMessage = 'مرحباً، كيف حالك؟';
    widget.onSendMessage(contact.phone, defaultMessage);
  }


  void _callContact(Contact contact) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: contact.phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      AppUtils.showCustomSnackBar(
        context,
        'لا يمكن إجراء الاتصال',
        isError: true,
      );
    }
  }

  /// عرض حوار التصفية المتقدمة
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفية متقدمة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('الأرقام الصحيحة فقط'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  // تطبيق التصفية
                },
              ),
            ),
            ListTile(
              title: const Text('جهات الاتصال الحديثة'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  // تطبيق التصفية
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
            onPressed: () => Navigator.pop(context),
            child: const Text('تطبيق'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
