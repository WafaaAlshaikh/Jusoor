// lib/screens/manage_children/widgets/child_card.dart
// بطاقة الطفل في القائمة - تعرض صورة/حرف أول، الحالة، آخر جلسة، عدد الجلسات القادمة (إن وُجد)
import 'package:flutter/material.dart';
import '../models/child_model.dart';
import 'package:intl/intl.dart';

class ChildCard extends StatelessWidget {
  final Child child;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ChildCard({
    super.key,
    required this.child,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  // helper لتنسيق آخر جلسة
  String get _lastSessionText {
    if (child.lastSessionDate != null) {
      return DateFormat.yMMMd().format(child.lastSessionDate!);
    }
    return 'No sessions yet';
  }

  // (اختياري) لو حابّة تضيفي عدد الجلسات القادمة، يجب أن تضيفي حقل في الـ API/Model
  String get _upcomingCountText {
    // placeholder — لو لديك عدد فعلي اجعليه جزء من Child model
    return ''; // إرجاع '' لو لا يوجد عرض
  }

  Color _conditionColor(String? condition) {
    final c = (condition ?? '').toLowerCase();
    if (c.contains('asd') || c.contains('autism')) return Colors.blue;
    if (c.contains('adhd')) return Colors.orange;
    if (c.contains('down')) return Colors.purple;
    if (c.contains('speech')) return Colors.teal;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onView,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: _conditionColor(child.condition).withOpacity(0.2),
          backgroundImage: (child.photo.isNotEmpty) ? NetworkImage(child.photo) : null,
          child: (child.photo.isEmpty) ? Text(child.fullName.isNotEmpty ? child.fullName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)) : null,
        ),
        title: Text(child.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _conditionColor(child.condition).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(child.condition ?? '-', style: TextStyle(color: _conditionColor(child.condition), fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Text(_lastSessionText, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                if (_upcomingCountText.isNotEmpty)
                  Chip(label: Text(_upcomingCountText)),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: onView, icon: const Icon(Icons.visibility, color: Colors.teal)),
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit, color: Colors.orange)),
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_forever, color: Colors.redAccent)),
          ],
        ),
      ),
    );
  }
}
