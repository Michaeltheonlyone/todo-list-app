// lib/screens/add_task_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task; // Pour l'édition

  const AddTaskScreen({super.key, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  TaskPriority _selectedPriority = TaskPriority.medium;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _selectedDate = widget.task!.dueDate;
      _selectedTime = widget.task!.dueDate != null
          ? TimeOfDay.fromDateTime(widget.task!.dueDate!)
          : null;
      _selectedPriority = widget.task!.priority;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF007AFF),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF007AFF),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le titre est requis'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      DateTime? finalDateTime;
      if (_selectedDate != null && _selectedTime != null) {
        finalDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
      } else if (_selectedDate != null) {
        finalDateTime = _selectedDate;
      }

      final task = Task(
        id: widget.task?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: finalDateTime,
        priority: _selectedPriority,
        status: widget.task?.status ?? TaskStatus.pending,
      );

      if (widget.task == null) {
        await TaskService.createTask(task);
      } else {
        await TaskService.updateTask(task);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.task == null ? 'Nouvelle tâche' : 'Modifier la tâche',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTask,
            child: _isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text(
              'Enregistrer',
              style: TextStyle(
                color: Color(0xFF007AFF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _titleController,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Titre de la tâche',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
                  ),
                  maxLines: null,
                ),
              ),

              const SizedBox(height: 16),

              // Description Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Description (optionnel)',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
                  ),
                  maxLines: 4,
                ),
              ),

              const SizedBox(height: 24),

              // Date & Time Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calendar_today_outlined, color: Color(0xFF007AFF)),
                      title: const Text('Date d\'échéance'),
                      subtitle: Text(
                        _selectedDate != null
                            ? DateFormat('dd MMMM yyyy', 'fr_FR').format(_selectedDate!)
                            : 'Aucune date',
                        style: TextStyle(
                          color: _selectedDate != null ? Colors.black87 : Colors.grey,
                        ),
                      ),
                      onTap: _selectDate,
                      trailing: _selectedDate != null
                          ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () => setState(() => _selectedDate = null),
                      )
                          : null,
                    ),

                    if (_selectedDate != null) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.access_time, color: Color(0xFF007AFF)),
                        title: const Text('Heure'),
                        subtitle: Text(
                          _selectedTime != null
                              ? _selectedTime!.format(context)
                              : 'Aucune heure',
                          style: TextStyle(
                            color: _selectedTime != null ? Colors.black87 : Colors.grey,
                          ),
                        ),
                        onTap: _selectTime,
                        trailing: _selectedTime != null
                            ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => setState(() => _selectedTime = null),
                        )
                            : null,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Priority Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Row(
                        children: [
                          Icon(Icons.flag_outlined, color: Color(0xFF007AFF)),
                          SizedBox(width: 16),
                          Text(
                            'Priorité',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Row(
                        children: TaskPriority.values.map((priority) {
                          final isSelected = _selectedPriority == priority;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () => setState(() => _selectedPriority = priority),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _getPriorityColor(priority).withOpacity(0.15)
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? _getPriorityColor(priority)
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    priority.label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isSelected
                                          ? _getPriorityColor(priority)
                                          : Colors.grey[600],
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),



              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.deepOrange;
      case TaskPriority.urgent:
        return Colors.red;
    }
  }
}