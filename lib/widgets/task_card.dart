// lib/widgets/task_card.dart

import 'package:flutter/material.dart';
import '../models/task.dart';
import 'priority_badge.dart';

// lib/widgets/task_card.dart

import 'package:flutter/material.dart';
import '../models/task.dart';
import 'priority_badge.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggleStatus;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onTap,
    required this.onToggleStatus,
  }) : super(key: key);

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    _scaleController.reverse();
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.task.status == TaskStatus.completed;
    final isOverdue = widget.task.isOverdue;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF007AFF).withOpacity(isCompleted ? 0.0 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: _getPriorityColor(widget.task.priority),
                    width: 6,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Animated Checkbox
                  GestureDetector(
                    onTap: widget.onToggleStatus,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCompleted ? const Color(0xFF007AFF) : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted ? const Color(0xFF007AFF) : const Color(0xFFC7C7CC),
                          width: 2.5,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.task.title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: isCompleted ? const Color(0xFFaeaeb2) : Colors.black,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            decorationColor: const Color(0xFFaeaeb2),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.task.description != null && widget.task.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.task.description!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8E8E93),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        
                        const SizedBox(height: 10),
                        
                        // Metadata Row
                        Row(
                          children: [
                            if (widget.task.dueDate != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isOverdue 
                                      ? const Color(0xFFFF3B30).withOpacity(0.1) 
                                      : const Color(0xFFF2F2F7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 12,
                                      color: isOverdue ? const Color(0xFFFF3B30) : const Color(0xFF8E8E93),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDate(widget.task.dueDate!),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isOverdue ? const Color(0xFFFF3B30) : const Color(0xFF8E8E93),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            
                            // Priority Pill
                            if (widget.task.priority != TaskPriority.low)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(widget.task.priority).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.task.priority.label.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: _getPriorityColor(widget.task.priority),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return const Color(0xFF34C759); // Green
      case TaskPriority.medium:
        return const Color(0xFFFF9500); // Orange
      case TaskPriority.high:
        return const Color(0xFFFF3B30); // Red
      case TaskPriority.urgent:
        return const Color(0xFF5856D6); // Purple
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return "Aujourd'hui";
    } else if (dateOnly == tomorrow) {
      return 'Demain';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}