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
  List<Task> _filteredTasks = [];
  bool _isLoading = true;
  String _username = '';
  int _unreadNotifications = 0;
  String? _selectedCategory;

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
      _filterTasks();
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

  void _filterTasks() {
    List<Task> filtered = _tasks;

    if (_selectedCategory != null) {
      switch (_selectedCategory) {
        case 'today':
          filtered = filtered.where((t) => t.isDueToday).toList();
          break;
        case 'scheduled':
          filtered = filtered.where((t) => t.dueDate != null).toList();
          break;
        case 'important':
          filtered = filtered.where((t) =>
          t.priority == TaskPriority.high || t.priority == TaskPriority.urgent
          ).toList();
          break;
        case 'overdue':
          filtered = filtered.where((t) => t.isOverdue).toList();
          break;
        case 'completed':
          filtered = filtered.where((t) => t.status == TaskStatus.completed).toList();
          break;
        case 'no_alert':
          filtered = filtered.where((t) => t.dueDate == null).toList();
          break;
      }
    }

    filtered.sort((a, b) {
      if (a.status == TaskStatus.completed && b.status != TaskStatus.completed) return 1;
      if (a.status != TaskStatus.completed && b.status == TaskStatus.completed) return -1;
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });

    setState(() => _filteredTasks = filtered);
  }

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

  int _getCategoryCount(String category) {
    switch (category) {
      case 'today':
        return _tasks.where((t) => t.isDueToday).length;
      case 'scheduled':
        return _tasks.where((t) => t.dueDate != null).length;
      case 'important':
        return _tasks.where((t) =>
        t.priority == TaskPriority.high || t.priority == TaskPriority.urgent
        ).length;
      case 'overdue':
        return _tasks.where((t) => t.isOverdue).length;
      case 'completed':
        return _tasks.where((t) => t.status == TaskStatus.completed).length;
      case 'no_alert':
        return _tasks.where((t) => t.dueDate == null).length;
      default:
        return 0;
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
                        'Rappel',
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

                  // Category Tiles (Samsung Style)
                  SizedBox(
                    height: 90,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _CategoryTile(
                          icon: Icons.today_outlined,
                          label: 'Aujourd\'hui',
                          count: _getCategoryCount('today'),
                          isSelected: _selectedCategory == 'today',
                          color: const Color(0xFF007AFF),
                          onTap: () {
                            setState(() {
                              _selectedCategory = _selectedCategory == 'today' ? null : 'today';
                            });
                            _filterTasks();
                          },
                        ),
                        _CategoryTile(
                          icon: Icons.calendar_month_outlined,
                          label: 'Planifiées',
                          count: _getCategoryCount('scheduled'),
                          isSelected: _selectedCategory == 'scheduled',
                          color: Colors.orange,
                          onTap: () {
                            setState(() {
                              _selectedCategory = _selectedCategory == 'scheduled' ? null : 'scheduled';
                            });
                            _filterTasks();
                          },
                        ),
                        _CategoryTile(
                          icon: Icons.star_outline,
                          label: 'Important',
                          count: _getCategoryCount('important'),
                          isSelected: _selectedCategory == 'important',
                          color: Colors.red,
                          onTap: () {
                            setState(() {
                              _selectedCategory = _selectedCategory == 'important' ? null : 'important';
                            });
                            _filterTasks();
                          },
                        ),
                        _CategoryTile(
                          icon: Icons.notifications_off_outlined,
                          label: 'Sans alerte',
                          count: _getCategoryCount('no_alert'),
                          isSelected: _selectedCategory == 'no_alert',
                          color: Colors.grey,
                          onTap: () {
                            setState(() {
                              _selectedCategory = _selectedCategory == 'no_alert' ? null : 'no_alert';
                            });
                            _filterTasks();
                          },
                        ),
                        _CategoryTile(
                          icon: Icons.check_circle_outline,
                          label: 'Terminées',
                          count: _getCategoryCount('completed'),
                          isSelected: _selectedCategory == 'completed',
                          color: Colors.green,
                          onTap: () {
                            setState(() {
                              _selectedCategory = _selectedCategory == 'completed' ? null : 'completed';
                            });
                            _filterTasks();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Task List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredTasks.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune tâche',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Appuyez sur + pour créer',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
                  : RefreshIndicator(
                onRefresh: _loadData,
                color: const Color(0xFF007AFF),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = _filteredTasks[index];
                    return _TaskItem(
                      task: task,
                      onTap: () => _openTaskDetail(task),
                      onToggle: () => _toggleTaskStatus(task),
                    );
                  },
                ),
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
                          'Ajouter un rappel',
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
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.mic, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Commande vocale à venir'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
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
}

// Category Tile Widget (Samsung Style)
class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.icon,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: color, width: 2)
                : null,
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? color : Colors.grey[700],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : Colors.grey[800],
                ),
              ),
            ],
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