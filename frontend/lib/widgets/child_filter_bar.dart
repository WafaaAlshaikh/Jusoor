// lib/screens/manage_children/widgets/child_filter_bar.dart
// Search field + Condition dropdown + Sort dropdown
import 'package:flutter/material.dart';
import '../screens/manage_children_screen.dart'; // for ChildSortOption

class ChildFilterBar extends StatelessWidget {
  final List<String> conditions;
  final String selectedCondition;
  final ValueChanged<String> onConditionChanged;
  final ValueChanged<String> onSearchChanged;
  final ChildSortOption sortOption;
  final ValueChanged<ChildSortOption> onSortChanged;

  const ChildFilterBar({
    super.key,
    required this.conditions,
    required this.selectedCondition,
    required this.onConditionChanged,
    required this.onSearchChanged,
    required this.sortOption,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search
        Expanded(
          flex: 3,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by name',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: onSearchChanged,
          ),
        ),
        const SizedBox(width: 8),
        // Condition dropdown
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCondition,
                items: conditions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) {
                  if (v != null) onConditionChanged(v);
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Sort dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ChildSortOption>(
              value: sortOption,
              items: const [
                DropdownMenuItem(value: ChildSortOption.name, child: Text('Sort: Name')),
                DropdownMenuItem(value: ChildSortOption.age, child: Text('Sort: Age')),
                DropdownMenuItem(value: ChildSortOption.lastSession, child: Text('Sort: Last Session')),
              ],
              onChanged: (val) {
                if (val != null) onSortChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}
