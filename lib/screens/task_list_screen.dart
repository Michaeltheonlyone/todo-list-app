import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';
import 'task_detail_screen.dart';
import 'task_edit_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      final fetchedTasks = await ApiService.getTasks();
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

  int get completedCount =>
      tasks.where((t) => t.status == TaskStatus.completed).length;

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
          await ApiService.createTask(result);
        }
        await _fetchTasks();
      } catch (e) {
        print('Error saving task: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF9333EA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mes Tâches',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${tasks.length} tâches • $completedCount terminées',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFFE0E7FF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Rechercher une tâche...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Toutes',
                        isSelected: filterStatus == null,
                        onTap: () => setState(() => filterStatus = null),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'En attente',
                        isSelected: filterStatus == TaskStatus.pending,
                        onTap: () =>
                            setState(() => filterStatus = TaskStatus.pending),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Terminées',
                        isSelected: filterStatus == TaskStatus.completed,
                        onTap: () =>
                            setState(() => filterStatus = TaskStatus.completed),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                  )
                : filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune tâche trouvée',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
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
                                  onToggleStatus: () =>
                                      _toggleTaskStatus(task.id!),
                                ),
                              ),
                            );
                            await _fetchTasks();
                          },
                          onToggleStatus: () => _toggleTaskStatus(task.id!),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEdit(),
        backgroundColor: const Color(0xFF4F46E5),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
