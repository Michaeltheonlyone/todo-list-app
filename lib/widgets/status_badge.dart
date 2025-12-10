// lib/widgets/status_badge.dart

import 'package:flutter/material.dart';
import '../models/task.dart';

class StatusBadge extends StatelessWidget {
  final TaskStatus status;
  final bool compact;

  const StatusBadge({
    Key? key,
    required this.status,
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
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colors['dot'],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w600,
              color: colors['text'],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, Color> _getColors() {
    switch (status) {
      case TaskStatus.pending:
        return {
          'bg': Colors.grey[100]!,
          'text': Colors.grey[700]!,
          'dot': Colors.grey[400]!,
        };
      case TaskStatus.inProgress:
        return {
          'bg': Colors.blue[50]!,
          'text': Colors.blue[700]!,
          'dot': Colors.blue[500]!,
        };
      case TaskStatus.completed:
        return {
          'bg': Colors.green[50]!,
          'text': Colors.green[700]!,
          'dot': Colors.green[500]!,
        };
      case TaskStatus.cancelled:
        return {
          'bg': Colors.red[50]!,
          'text': Colors.red[700]!,
          'dot': Colors.red[500]!,
        };
    }
  }
}