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

  // ⬇️⬇️⬇️ أضف دالة للحصول على لون حالة التسجيل ⬇️⬇️⬇️
  Color _registrationStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Not Registered':
      default:
        return Colors.grey;
    }
  }

  // ⬇️⬇️⬇️ أضف دالة للحصول على أيقونة حالة التسجيل ⬇️⬇️⬇️
  IconData _registrationStatusIcon(String status) {
    switch (status) {
      case 'Approved':
        return Icons.check_circle;
      case 'Pending':
        return Icons.pending;
      case 'Not Registered':
      default:
        return Icons.person_outline;
    }
  }
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
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: _conditionColor(child.condition).withOpacity(0.2),
              backgroundImage: (child.photo.isNotEmpty) ? NetworkImage(child.photo) : null,
              child: (child.photo.isEmpty) ? Text(
                child.fullName.isNotEmpty ? child.fullName[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              ) : null,
            ),
            // ⬇️⬇️⬇️ أيقونة صغيرة لحالة التسجيل ⬇️⬇️⬇️
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: _registrationStatusColor(child.registrationStatus), width: 2),
                ),
                child: Icon(
                  _registrationStatusIcon(child.registrationStatus),
                  color: _registrationStatusColor(child.registrationStatus),
                  size: 12,
                ),
              ),
            ),
          ],
        ),
        title: Text(child.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                // حالة التشخيص
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _conditionColor(child.condition).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    child.condition ?? '-',
                    style: TextStyle(color: _conditionColor(child.condition), fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),

                // ⬇️⬇️⬇️ حالة التسجيل ⬇️⬇️⬇️
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _registrationStatusColor(child.registrationStatus).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    child.registrationStatus,
                    style: TextStyle(
                      color: _registrationStatusColor(child.registrationStatus),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _lastSessionText,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
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

