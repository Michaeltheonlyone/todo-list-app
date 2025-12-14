import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add intl for date formatting
import '../services/api_service.dart';
import '../services/auth_service.dart';

import '../models/task.dart';
import '../widgets/task_card.dart';
import 'task_detail_screen.dart';
import 'task_edit_screen.dart';
import 'notification_screen.dart';
import '../managers/notification_manager.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];
  String searchQuery = '';
  TaskStatus? filterStatus;
  bool isLoading = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserAndTasks();
  }

  Future<void> _loadUserAndTasks() async {
    final userId = await AuthService.getUserId();
    if (userId == null) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }
    setState(() => _userId = userId);
    
    // Init Notification Sound Manager
    NotificationManager().init(userId);

    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    if (_userId == null) return;
    try {
      final fetchedTasks = await ApiService.getTasks(_userId!);
      setState(() {
        tasks = fetchedTasks;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading tasks: $e');
      setState(() => isLoading = false);
    }
  }

  List<Task> get filteredTasks {
    return tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      final matchesFilter = filterStatus == null || task.status == filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  int get completedCount => tasks.where((t) => t.status == TaskStatus.completed).length;

  Future<void> _toggleTaskStatus(String taskId) async {
    try {
      final task = tasks.firstWhere((t) => t.id == taskId);
      final newStatus = task.status == TaskStatus.completed
          ? TaskStatus.pending
          : TaskStatus.completed;

      final updatedTask = task.copyWith(status: newStatus);
      await ApiService.updateTask(updatedTask);
      await _fetchTasks();
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await ApiService.deleteTask(taskId);
      await _fetchTasks();
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  Future<void> _navigateToEdit([Task? task]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskEditScreen(task: task)),
    );

    if (result != null && result is Task) {
      try {
        if (task != null) {
          await ApiService.updateTask(result);
        } else {
          if (_userId != null) {
             await ApiService.createTask(result, _userId!);
          }
        }
        await _fetchTasks();
      } catch (e) {
        print('Error saving task: $e');
      }
    }
  }

  void _logout() async {
    NotificationManager().stop();
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Current Date for Header
    final now = DateTime.now();
    final dateString = DateFormat('EEEE d MMMM', 'fr_FR').format(now);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // 1. Modern Header
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            actions: [
              // Notification Bell
              ValueListenableBuilder<int>(
                valueListenable: NotificationManager().unreadCount,
                builder: (context, count, child) {
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87, size: 28),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotificationScreen()),
                          );
                        },
                      ),
                      if (count > 0)
                        Positioned(
                          right: 12,
                          top: 10,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF2D55),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
                          ),
                        ),
                    ],
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.black87),
                onPressed: _logout,
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              centerTitle: false,
              title: Text(
                'Mes Tâches',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              background: Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateString.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bonjour,',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w300,
                        color: Colors.black87.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Search & Filter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                children: [
                  // Glassy Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => searchQuery = value),
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Rechercher...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).primaryColor),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Animated Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'Tout',
                          count: tasks.length,
                          isSelected: filterStatus == null,
                          onTap: () => setState(() => filterStatus = null),
                        ),
                        const SizedBox(width: 12),
                        _FilterChip(
                          label: 'À faire',
                          count: tasks.where((t) => t.status != TaskStatus.completed).length,
                          isSelected: filterStatus == TaskStatus.pending,
                          onTap: () => setState(() => filterStatus = TaskStatus.pending),
                        ),
                        const SizedBox(width: 12),
                        _FilterChip(
                          label: 'Terminé',
                          count: completedCount,
                          isSelected: filterStatus == TaskStatus.completed,
                          onTap: () => setState(() => filterStatus = TaskStatus.completed),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Spacing
          const SliverPadding(padding: EdgeInsets.only(top: 10)),

          // 4. Task List
          isLoading
            ? const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            : filteredTasks.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10)),
                            ],
                          ),
                          child: Icon(Icons.task_alt_rounded, size: 60, color: Theme.of(context).primaryColor.withOpacity(0.5)),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Aucune tâche trouvée',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final task = filteredTasks[index];
                      // Add extra padding at the bottom for FAB
                      final isLast = index == filteredTasks.length - 1;
                      
                      return Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, isLast ? 100 : 16),
                        child: TaskCard(
                          task: task,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskDetailScreen(
                                  task: task,
                                  onDelete: () => _deleteTask(task.id!),
                                  onEdit: () => _navigateToEdit(task),
                                  onToggleStatus: () => _toggleTaskStatus(task.id!),
                                ),
                              ),
                            );
                            await _fetchTasks();
                          },
                          onToggleStatus: () => _toggleTaskStatus(task.id!),
                        ),
                      );
                    },
                    childCount: filteredTasks.length,
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEdit(),
        elevation: 10,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add_rounded, size: 32, color: Colors.white),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007AFF) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected 
            ? [BoxShadow(color: const Color(0xFF007AFF).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))] 
            : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
