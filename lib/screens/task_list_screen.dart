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

class _TaskListScreenState extends State<TaskListScreen> with SingleTickerProviderStateMixin {
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = true;
  String _username = '';
  int _unreadNotifications = 0;
  String? _selectedCategory;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          filtered = filtered.where((t) => t.isDueToday && t.status != TaskStatus.completed).toList();
          break;
        case 'scheduled':
          filtered = filtered.where((t) => t.dueDate != null && t.status != TaskStatus.completed).toList();
          break;
        case 'important':
          filtered = filtered.where((t) =>
          (t.priority == TaskPriority.high || t.priority == TaskPriority.urgent) &&
              t.status != TaskStatus.completed
          ).toList();
          break;
        case 'completed':
          filtered = filtered.where((t) => t.status == TaskStatus.completed).toList();
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
    if (result == true) _loadData();
  }

  Future<void> _openTaskDetail(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
    );
    if (result == true) _loadData();
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
        return _tasks.where((t) => t.isDueToday && t.status != TaskStatus.completed).length;
      case 'scheduled':
        return _tasks.where((t) => t.dueDate != null && t.status != TaskStatus.completed).length;
      case 'important':
        return _tasks.where((t) =>
        (t.priority == TaskPriority.high || t.priority == TaskPriority.urgent) &&
            t.status != TaskStatus.completed
        ).length;
      case 'completed':
        return _tasks.where((t) => t.status == TaskStatus.completed).length;
      default:
        return 0;
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.logout();
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayTasks = _selectedCategory == null ? _tasks.where((t) => t.status != TaskStatus.completed).toList() : _filteredTasks;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              _username.isNotEmpty ? _username[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bonjour,',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                _username,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Notifications
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.notifications_outlined, size: 24),
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
                            ),
                            if (_unreadNotifications > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF3B30),
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    _unreadNotifications > 9 ? '9+' : '$_unreadNotifications',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        // Menu
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 24),
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
                                    Icon(Icons.bar_chart_rounded, color: Color(0xFF667eea)),
                                    SizedBox(width: 12),
                                    Text('Statistiques'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    Icon(Icons.logout, color: Color(0xFFFF3B30)),
                                    SizedBox(width: 12),
                                    Text('Déconnexion'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Category Pills
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                      children: [
                        _CategoryPill(
                          icon: Icons.wb_sunny_outlined,
                          label: 'Aujourd\'hui',
                          count: _getCategoryCount('today'),
                          color: const Color(0xFFFF9500),
                          isSelected: _selectedCategory == 'today',
                          onTap: () {
                            setState(() {
                              _selectedCategory = _selectedCategory == 'today' ? null : 'today';
                            });
                            _filterTasks();
                          },
                        ),
                        _CategoryPill(
                          icon: Icons.event_outlined,
                          label: 'Planifiées',
                          count: _getCategoryCount('scheduled'),
                          color: const Color(0xFF667eea),
                          isSelected: _selectedCategory == 'scheduled',
                          onTap: () {
                            setState(() {
                              _selectedCategory = _selectedCategory == 'scheduled' ? null : 'scheduled';
                            });
                            _filterTasks();
                          },
                        ),
                        _CategoryPill(
                          icon: Icons.star_outline,
                          label: 'Important',
                          count: _getCategoryCount('important'),
                          color: const Color(0xFFFF3B30),
                          isSelected: _selectedCategory == 'important',
                          onTap: () {
                            setState(() {
                              _selectedCategory = _selectedCategory == 'important' ? null : 'important';
                            });
                            _filterTasks();
                          },
                        ),
                        _CategoryPill(
                          icon: Icons.check_circle_outline,
                          label: 'Terminées',
                          count: _getCategoryCount('completed'),
                          color: const Color(0xFF34C759),
                          isSelected: _selectedCategory == 'completed',
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
                  : displayTasks.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 60,
                        color: Colors.grey[300],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _selectedCategory == null ? 'Aucune tâche' : 'Aucune tâche ici',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Appuyez sur + pour créer une tâche',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
                  : RefreshIndicator(
                onRefresh: _loadData,
                color: const Color(0xFF667eea),
                child: ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: displayTasks.length,
                  itemBuilder: (context, index) {
                    final task = displayTasks[index];
                    return _ModernTaskCard(
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

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        backgroundColor: const Color(0xFF667eea),
        elevation: 4,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Modern Category Pill
class _CategoryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 110,
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
              colors: [color, color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.transparent : color.withOpacity(0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected ? color.withOpacity(0.3) : Colors.black.withOpacity(0.05),
                blurRadius: isSelected ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : color,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Modern Task Card
class _ModernTaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _ModernTaskCard({
    required this.task,
    required this.onTap,
    required this.onToggle,
  });

  Color _getPriorityColor() {
    switch (task.priority) {
      case TaskPriority.urgent:
        return const Color(0xFFFF3B30);
      case TaskPriority.high:
        return const Color(0xFFFF9500);
      case TaskPriority.medium:
        return const Color(0xFF667eea);
      case TaskPriority.low:
        return const Color(0xFF34C759);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: task.isOverdue && task.status != TaskStatus.completed
                ? Border.all(color: const Color(0xFFFF3B30).withOpacity(0.3), width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: task.status == TaskStatus.completed
                            ? const Color(0xFF34C759)
                            : _getPriorityColor(),
                        width: 2.5,
                      ),
                      color: task.status == TaskStatus.completed
                          ? const Color(0xFF34C759)
                          : Colors.transparent,
                    ),
                    child: task.status == TaskStatus.completed
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                ),

                const SizedBox(width: 16),

                // Priority Indicator
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: task.status == TaskStatus.completed
                              ? Colors.grey[400]
                              : const Color(0xFF1A1A1A),
                          decoration: task.status == TaskStatus.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (task.dueDate != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: task.isOverdue && task.status != TaskStatus.completed
                                  ? const Color(0xFFFF3B30)
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              task.isDueToday
                                  ? 'Aujourd\'hui ${DateFormat('HH:mm').format(task.dueDate!)}'
                                  : DateFormat('d MMM, HH:mm', 'fr_FR').format(task.dueDate!),
                              style: TextStyle(
                                fontSize: 13,
                                color: task.isOverdue && task.status != TaskStatus.completed
                                    ? const Color(0xFFFF3B30)
                                    : Colors.grey[600],
                                fontWeight: task.isOverdue && task.status != TaskStatus.completed
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}