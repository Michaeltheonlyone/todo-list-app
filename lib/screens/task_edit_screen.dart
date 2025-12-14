// lib/screens/task_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskEditScreen extends StatefulWidget {
  final Task? task;

  const TaskEditScreen({Key? key, this.task}) : super(key: key);

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TaskPriority _selectedPriority;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<String> _tags = [];

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _selectedPriority = widget.task?.priority ?? TaskPriority.medium;
    _selectedDate = widget.task?.dueDate;
    if (_selectedDate != null) {
      _selectedTime = TimeOfDay.fromDateTime(_selectedDate!);
    }
    _tags = widget.task?.tags ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      DateTime? finalDateTime = _selectedDate;
      
      // Merge Date and Time if both exist
      if (_selectedDate != null && _selectedTime != null) {
        finalDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
      }

      final task = Task(
        id: widget.task?.id,
        title: _titleController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        dueDate: finalDateTime,
        priority: _selectedPriority,
        status: widget.task?.status ?? TaskStatus.pending,
        tags: _tags.isEmpty ? null : _tags,
        createdAt: widget.task?.createdAt ?? DateTime.now(),
      );

      Navigator.pop(context, task);
    }
  }

  Future<void> _selectDateTime() async {
    // 1. Pick Date
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Theme.of(context).primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      if (!mounted) return;
      // 2. Pick Time
      final time = await showTimePicker(
        context: context,
        initialTime: _selectedTime ?? TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(primary: Theme.of(context).primaryColor),
            ),
            child: child!,
          );
        },
      );

      setState(() {
        _selectedDate = date;
        _selectedTime = time;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Modifier la tâche' : 'Nouvelle tâche',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text(
              'Enregistrer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF007AFF),
              ),
            ),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Title Input
            _buildSectionTitle('TITRE'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              decoration: _buildInputDecoration('Que devez-vous faire ?', Icons.title),
              validator: (value) => value == null || value.isEmpty ? 'Le titre est requis' : null,
            ),
            const SizedBox(height: 24),

            // Description Input
            _buildSectionTitle('DESCRIPTION'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              style: const TextStyle(fontSize: 16),
              decoration: _buildInputDecoration('Ajouter des détails...', Icons.notes),
            ),
            const SizedBox(height: 24),

            // Date & Time Picker
            _buildSectionTitle('DATE ET HEURE LIMITE'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDateTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, color: Color(0xFF007AFF)),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate == null 
                        ? 'Définir une date limite' 
                        : _formatDateAndTime(_selectedDate!, _selectedTime),
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDate == null ? Colors.grey[600] : Colors.black,
                        fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedDate != null)
                      GestureDetector(
                        onTap: () => setState(() {
                          _selectedDate = null;
                          _selectedTime = null;
                        }),
                        child: Icon(Icons.cancel, color: Colors.grey[400]),
                      )
                    else 
                      const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Priority Selection
            _buildSectionTitle('PRIORITÉ'),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: TaskPriority.values.map((priority) => _buildPriorityChip(priority)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
        letterSpacing: 0.5,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: const Color(0xFFF2F2F7),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF007AFF), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    final isSelected = _selectedPriority == priority;
    return GestureDetector(
      onTap: () => setState(() => _selectedPriority = priority),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Taller pills
        decoration: BoxDecoration(
          color: isSelected ? _getPriorityColor(priority) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? _getPriorityColor(priority) : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: isSelected 
             ? [BoxShadow(color: _getPriorityColor(priority).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] 
             : null,
        ),
        child: Text(
          priority.label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low: return const Color(0xFF34C759);
      case TaskPriority.medium: return const Color(0xFFFF9500);
      case TaskPriority.high: return const Color(0xFFFF3B30);
      case TaskPriority.urgent: return const Color(0xFF5856D6);
    }
  }

  String _formatDateAndTime(DateTime date, TimeOfDay? time) {
    final dateStr = DateFormat('EEE d MMM y', 'fr_FR').format(date);
    if (time != null) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$dateStr à $hour:$minute';
    }
    return dateStr;
  }
}
