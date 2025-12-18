// lib/screens/task_list_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';
import 'notifications_screen.dart';
import 'statistics_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];

  bool _isLoading = true;
  String _username = '';
  int _unreadNotifications = 0;
  String _selectedCategory = 'Aujourd\'hui';


  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final username = await AuthService.getUsername();
      final tasks = await TaskService.getTasks();
      final unreadCount = await NotificationService.getUnreadCount();

      setState(() {
        _username = username ?? 'Utilisateur';
        _tasks = tasks;
        _unreadNotifications = unreadCount;
        _isLoading = false;
      });

    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Plus besoin de _filterTasks car on filtre directement dans le build
  List<Task> get _todayTasks => _tasks.where((t) => t.isDueToday).toList();
  List<Task> get _allTasks => _tasks; // Toutes les tâches pour "Mes Tâches"

  Future<void> _addTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskScreen()),
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _openTaskDetail(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _toggleTaskStatus(Task task) async {
    try {
      final newStatus = task.status == TaskStatus.completed
          ? TaskStatus.pending
          : TaskStatus.completed;

      final updatedTask = task.copyWith(status: newStatus);
      await TaskService.updateTask(updatedTask);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Aujourd\'hui',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF007AFF),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Row(
                        children: [
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined, size: 26),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const NotificationsScreen(),
                                    ),
                                  );
                                  _loadData();
                                },
                              ),
                              if (_unreadNotifications > 0)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      _unreadNotifications > 9 ? '9+' : '$_unreadNotifications',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 26),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            onSelected: (value) {
                              if (value == 'statistics') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const StatisticsScreen(),
                                  ),
                                );
                              } else if (value == 'logout') {
                                _logout();
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'statistics',
                                child: Row(
                                  children: [
                                    Icon(Icons.bar_chart, color: Color(0xFF007AFF)),
                                    SizedBox(width: 12),
                                    Text('Statistiques'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    Icon(Icons.logout, color: Colors.red),
                                    SizedBox(width: 12),
                                    Text('Déconnexion', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Carousel (Tabs)
                        Container(
                          height: 50,
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              _buildCategoryChip('Aujourd\'hui'),
                              const SizedBox(width: 12),
                              _buildCategoryChip('Mes Tâches'),
                            ],
                          ),
                        ),

                        // Task List
                        Expanded(
                          child: _selectedCategory == 'Aujourd\'hui' && _todayTasks.isEmpty
                              ? Center(
                                  child: Text(
                                    'Rien de prévu aujourd\'hui',
                                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: _selectedCategory == 'Aujourd\'hui'
                                      ? _todayTasks.length
                                      : _allTasks.length,
                                  itemBuilder: (context, index) {
                                    final task = _selectedCategory == 'Aujourd\'hui'
                                        ? _todayTasks[index]
                                        : _allTasks[index];
                                    return _TaskItem(
                                      task: task,
                                      onTap: () => _openTaskDetail(task),
                                      onToggle: () => _toggleTaskStatus(task),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),

      // Add Reminder Bar (Samsung Style)
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _addTask,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add, color: Colors.grey[600], size: 22),
                        const SizedBox(width: 12),
                        Text(
                          'Ajouter une tâche',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Widget _buildCategoryChip(String category) {
    bool isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007AFF) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF007AFF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}



// Task Item Widget (Samsung Style - Simple)
class _TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _TaskItem({
    required this.task,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.status == TaskStatus.completed
                        ? const Color(0xFF007AFF)
                        : Colors.grey[400]!,
                    width: 2,
                  ),
                  color: task.status == TaskStatus.completed
                      ? const Color(0xFF007AFF)
                      : Colors.transparent,
                ),
                child: task.status == TaskStatus.completed
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      decoration: task.status == TaskStatus.completed
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: Colors.grey,
                    ),
                  ),
                  if (task.dueDate != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 13,
                          color: task.isOverdue ? Colors.red : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.isDueToday
                              ? 'Aujourd\'hui ${DateFormat('HH:mm').format(task.dueDate!)}'
                              : DateFormat('d MMM, HH:mm', 'fr_FR').format(task.dueDate!),
                          style: TextStyle(
                            fontSize: 12,
                            color: task.isOverdue ? Colors.red : Colors.grey[600],
                            fontWeight: task.isOverdue ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Priority indicator
            if (task.priority == TaskPriority.high || task.priority == TaskPriority.urgent)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

}

// Widget Carte pour le Carousel "Aujourd'hui"
class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const _TaskCard({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.priority == TaskPriority.high || task.priority == TaskPriority.urgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Important', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                const SizedBox(height: 8),
                Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  task.dueDate != null
                      ? DateFormat('HH:mm').format(task.dueDate!)
                      : '--:--',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}