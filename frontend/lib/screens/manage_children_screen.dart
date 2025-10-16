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

enum ChildSortOption { name, age, lastSession }

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
  ChildSortOption _sortOption = ChildSortOption.name;
  final List<String> _conditions = ['All', 'ASD', 'ADHD', 'Down Syndrome', 'Speech & Language Disorder'];

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final fetched = await ApiService.getChildren(token); // يرجع List<Child> كما في ApiService
      setState(() {
        _allChildren = fetched;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      // خطأ في الشبكة أو عند ال API
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _applyFilters() {
    _filteredChildren = _allChildren.where((child) {
      final matchesSearch = child.fullName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCondition = _selectedCondition == 'All' || (child.condition ?? '') == _selectedCondition;
      return matchesSearch && matchesCondition;
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
        // تحدث القائمة محليًا
        setState(() {
          _allChildren.removeWhere((c) => c.id == child.id);
          _applyFilters();
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${child.fullName} deleted')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Children'), // العنوان مطابق للمطلوب
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.maybePop(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _fetchChildren,
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              // مستقبلًا: ستضيفي إعدادات خاصة بالأطفال
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
          // 2. Summary stats
          ChildSummaryStats(childrenList: _allChildren),
          // 3. Filter bar (search + dropdown + sort)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: ChildFilterBar(
              conditions: _conditions,
              selectedCondition: _selectedCondition,
              onConditionChanged: (val) {
                setState(() {
                  _selectedCondition = val;
                  _applyFilters();
                });
              },
              onSearchChanged: (q) {
                setState(() {
                  _searchQuery = q;
                  _applyFilters();
                });
              },
              sortOption: _sortOption,
              onSortChanged: (opt) {
                setState(() {
                  _sortOption = opt;
                  _applyFilters();
                });
              },
            ),
          ),
          const Divider(height: 1),
          // المحتوى: Loading / Error / Empty / List
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
