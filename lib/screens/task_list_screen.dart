// lib/screens/task_list_screen.dart

import 'package:flutter/material.dart';
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
  List<Task> tasks = [
    Task(
      id: '1',
      title: 'Finaliser la présentation client',
      description: 'Préparer les slides et répéter la démo',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      priority: TaskPriority.high,
      status: TaskStatus.inProgress,
      tags: ['Travail', 'Urgent'],
    ),
    Task(
      id: '2',
      title: 'Faire les courses',
      description: 'Liste : pain, lait, fruits',
      dueDate: DateTime.now(),
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      tags: ['Personnel'],
    ),
    Task(
      id: '3',
      title: 'Rendez-vous dentiste',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      tags: ['Santé'],
    ),
  ];

  String searchQuery = '';
  TaskStatus? filterStatus;

  List<Task> get filteredTasks {
    return tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesFilter = filterStatus == null || task.status == filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  int get completedCount => tasks.where((t) => t.status == TaskStatus.completed).length;

  void _toggleTaskStatus(String taskId) {
    setState(() {
      final index = tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        tasks[index] = tasks[index].copyWith(
          status: tasks[index].status == TaskStatus.completed
              ? TaskStatus.pending
              : TaskStatus.completed,
        );
      }
    });
  }

  void _deleteTask(String taskId) {
    setState(() {
      tasks.removeWhere((t) => t.id == taskId);
    });
  }

  Future<void> _navigateToEdit([Task? task]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskEditScreen(task: task),
      ),
    );

    if (result != null && result is Task) {
      setState(() {
        if (task != null) {
          final index = tasks.indexWhere((t) => t.id == task.id);
          if (index != -1) tasks[index] = result;
        } else {
          tasks.add(result);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header avec gradient
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

          // Barre de recherche et filtres
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Recherche
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

                // Filtres
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
                        onTap: () => setState(() => filterStatus = TaskStatus.pending),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'En cours',
                        isSelected: filterStatus == TaskStatus.inProgress,
                        onTap: () => setState(() => filterStatus = TaskStatus.inProgress),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Terminées',
                        isSelected: filterStatus == TaskStatus.completed,
                        onTap: () => setState(() => filterStatus = TaskStatus.completed),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Liste des tâches
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune tâche trouvée',
                    style: TextStyle(fontSize: 16, color: Colors.grey[400]),
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
                            onToggleStatus: () => _toggleTaskStatus(task.id!),
                          ),
                        ),
                      );
                      setState(() {});
                    },
                    onToggleStatus: () => _toggleTaskStatus(task.id!),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Bouton flottant
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEdit(),
        backgroundColor: const Color(0xFF4F46E5),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

// Widget pour les filtres
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