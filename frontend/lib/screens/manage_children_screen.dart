// lib/screens/manage_children/manage_children_screen.dart
// الشاشة الرئيسية لإدارة الأطفال - تستخدم Widgets مقسمة داخل مجلد widgets/

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/child_model.dart';
import '../services/api_service.dart';
import '../widgets/child_summary_stats.dart';
import '../widgets/child_filter_bar.dart';
import '../widgets/child_card.dart';
import '../widgets/child_bottom_sheet.dart';
import '../widgets/child_form_dialog.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';

enum ChildSortOption { name, age, lastSession, registrationStatus }

class ManageChildrenScreen extends StatefulWidget {
  const ManageChildrenScreen({super.key});

  @override
  State<ManageChildrenScreen> createState() => _ManageChildrenScreenState();
}

class _ManageChildrenScreenState extends State<ManageChildrenScreen> {
  List<Child> _allChildren = [];
  List<Child> _filteredChildren = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _searchQuery = '';
  String _selectedCondition = 'All';
  String _selectedRegistrationStatus = 'All'; // ⬅️ جديد
  ChildSortOption _sortOption = ChildSortOption.name;
  final List<String> _conditions = ['All', 'ASD', 'ADHD', 'Down Syndrome', 'Speech & Language Disorder'];
  final List<String> _registrationStatuses = ['All', 'Not Registered', 'Pending', 'Approved']; // ⬅️ جديد

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }


  Future<void> _fetchChildren({int page = 1, int limit = 100}) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) throw Exception('No token');

      // تحويل sort option إلى string مناسب للـ API
      String sortStr = 'name';
      switch (_sortOption) {
        case ChildSortOption.name:
          sortStr = 'name';
          break;
        case ChildSortOption.age:
          sortStr = 'age';
          break;
        case ChildSortOption.lastSession:
          sortStr = 'lastSession';
          break;
        case ChildSortOption.registrationStatus: // ⬅️ جديد
          sortStr = 'registration_status';
          break;
      }

      final resp = await ApiService.getChildren(
        token: token,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        diagnosis: _selectedCondition == 'All' ? null : _selectedCondition,
        registrationStatus: _selectedRegistrationStatus == 'All' ? null : _selectedRegistrationStatus, // ⬅️ جديد
        sort: sortStr,
        order: 'asc',
        page: page,
        limit: limit,
      );

      // resp: { data: [...], meta: {...} }
      final List<dynamic> list = resp['data'] ?? [];
      final fetched = list.map((c) => Child.fromJson(c)).toList();

      setState(() {
        _allChildren = fetched;
        _filteredChildren = List.from(_allChildren); // لأن السيرفر فلتر لينا
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      print('Fetch children error: $e');
    }
  }

  // ⬇️⬇️⬇️ دالة الفلترة المحلية (إذا احتجناها) ⬇️⬇️⬇️
  void _applyLocalFilters() {
    _filteredChildren = _allChildren.where((child) {
      final matchesSearch = _searchQuery.isEmpty ||
          child.fullName.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCondition = _selectedCondition == 'All' ||
          (child.condition ?? '') == _selectedCondition;

      final matchesRegistrationStatus = _selectedRegistrationStatus == 'All' ||
          child.registrationStatus == _selectedRegistrationStatus;

      return matchesSearch && matchesCondition && matchesRegistrationStatus;
    }).toList();

    _sortChildren();
  }




  void _sortChildren() {
    switch (_sortOption) {
      case ChildSortOption.name:
        _filteredChildren.sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
        break;
      case ChildSortOption.age:
        _filteredChildren.sort((a, b) => (b.age ?? 0).compareTo(a.age ?? 0));
        break;
      case ChildSortOption.lastSession:
        _filteredChildren.sort((a, b) {
          final dateA = a.lastSessionDate ?? DateTime(1900);
          final dateB = b.lastSessionDate ?? DateTime(1900);
          return dateB.compareTo(dateA);
        });
        break;
      case ChildSortOption.registrationStatus: // ⬅️ جديد
        _filteredChildren.sort((a, b) => a.registrationStatus.compareTo(b.registrationStatus));
        break;
    }
  }

  void _openAddEditChild({Child? child}) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => ChildFormDialog(child: child),
    );
    if (changed == true) {
      // بعد إضافة/تعديل، نعيد جلب البيانات
      await _fetchChildren();
    }
  }

  void _confirmDelete(Child child) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion', style: TextStyle(color: Colors.red)),
        content: Text('Are you sure you want to permanently delete ${child.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token') ?? '';
        await ApiService.deleteChild(token, child.id);
        // تحديث القائمة محلياً باستخدام الدالة الصحيحة
        setState(() {
          _allChildren.removeWhere((c) => c.id == child.id);
          _applyLocalFilters(); // ⬅️ غير من _applyFilters إلى _applyLocalFilters
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${child.fullName} deleted')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }
  @override
// ⬇️⬇️⬇️ تحديث الـ build method ⬇️⬇️⬇️
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Children'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.maybePop(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _fetchChildren,
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              // إعدادات إضافية
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'settings', child: Text('Settings')),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
        elevation: 1,
      ),
      body: Column(
        children: [
          // Summary stats
          ChildSummaryStats(childrenList: _allChildren),

          // Filter bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: ChildFilterBar(
              conditions: _conditions,
              registrationStatuses: _registrationStatuses, // ⬅️ جديد
              selectedCondition: _selectedCondition,
              selectedRegistrationStatus: _selectedRegistrationStatus, // ⬅️ جديد
              onConditionChanged: (val) {
                setState(() => _selectedCondition = val);
                _fetchChildren();
              },
              onRegistrationStatusChanged: (val) { // ⬅️ جديد
                setState(() => _selectedRegistrationStatus = val);
                _fetchChildren();
              },
              onSearchChanged: (q) {
                setState(() => _searchQuery = q);
                _fetchChildren();
              },
              sortOption: _sortOption, // ⬅️ تأكد من إضافة هذا الـ parameter
              onSortChanged: (opt) {
                setState(() => _sortOption = opt);
                _fetchChildren();
              },
            ),
          ),

          const Divider(height: 1),

          // المحتوى
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                ? ErrorStateWidget(onRetry: _fetchChildren)
                : _filteredChildren.isEmpty
                ? EmptyStateWidget(onAdd: () => _openAddEditChild())
                : RefreshIndicator(
              onRefresh: _fetchChildren,
              color: Theme.of(context).primaryColor,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _filteredChildren.length,
                itemBuilder: (ctx, idx) {
                  final child = _filteredChildren[idx];
                  return ChildCard(
                    child: child,
                    onView: () => ChildBottomSheet.show(context, child: child),
                    onEdit: () => _openAddEditChild(child: child),
                    onDelete: () => _confirmDelete(child),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEditChild(),
        icon: const Icon(Icons.add),
        label: const Text('Add New Child'),
      ),
    );
  }
}
