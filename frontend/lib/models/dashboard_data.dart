import 'parent.dart';
import 'child.dart';
import 'summaries.dart';

class DashboardData {
  final Parent parent;
  final List<Child> children;
  final Summaries summaries;

  DashboardData({
    required this.parent,
    required this.children,
    required this.summaries,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    var childrenJson = json['children'] as List<dynamic>? ?? [];
    List<Child> childrenList =
    childrenJson.map((c) => Child.fromJson(c)).toList();

    return DashboardData(
      parent: Parent.fromJson(json['parent'] ?? {}),
      children: childrenList,
      summaries: Summaries.fromJson(json['summaries'] ?? {}),
    );
  }
}
