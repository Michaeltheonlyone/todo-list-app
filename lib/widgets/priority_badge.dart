// lib/widgets/priority_badge.dart

import 'package:flutter/material.dart';
import '../models/task.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final bool compact;

  const PriorityBadge({
    Key? key,
    required this.priority,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: colors['bg'],
        border: Border.all(color: colors['border']!),
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
      ),
      child: Text(
        priority.label,
        style: TextStyle(
          fontSize: compact ? 12 : 13,
          fontWeight: FontWeight.w600,
          color: colors['text'],
        ),
      ),
    );
  }

  Map<String, Color> _getColors() {
    switch (priority) {
      case TaskPriority.low:
        return {
          'bg': Colors.blue[50]!,
          'border': Colors.blue[200]!,
          'text': Colors.blue[700]!,
        };
      case TaskPriority.medium:
        return {
          'bg': Colors.yellow[50]!,
          'border': Colors.yellow[200]!,
          'text': Colors.yellow[800]!,
        };
      case TaskPriority.high:
        return {
          'bg': Colors.orange[50]!,
          'border': Colors.orange[200]!,
          'text': Colors.orange[700]!,
        };
      case TaskPriority.urgent:
        return {
          'bg': Colors.red[50]!,
          'border': Colors.red[200]!,
          'text': Colors.red[700]!,
        };
    }
  }
}