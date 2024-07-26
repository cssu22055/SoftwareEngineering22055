import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final DateTime actualDeadline;
  final int priority;
  final List<String> tags;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.actualDeadline,
    required this.priority,
    required this.tags,
    this.isCompleted = false,
  });
}

class TaskModel extends ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => _tasks.where((task) => !task.isCompleted).toList();
  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();

  void addTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required DateTime actualDeadline,
    required int priority,
    required List<String> tags,
  }) {
    final task = Task(
      id: Uuid().v4(),
      title: title,
      description: description,
      dueDate: dueDate,
      actualDeadline: actualDeadline,
      priority: priority,
      tags: tags,
    );
    _tasks.add(task);
    notifyListeners();
  }

  void updateTask(
      String id, {
        required String title,
        required String description,
        required DateTime dueDate,
        required DateTime actualDeadline,
        required int priority,
        required List<String> tags,
      }) {
    final taskIndex = _tasks.indexWhere((task) => task.id == id);
    if (taskIndex != -1) {
      _tasks[taskIndex] = Task(
        id: id,
        title: title,
        description: description,
        dueDate: dueDate,
        actualDeadline: actualDeadline,
        priority: priority,
        tags: tags,
        isCompleted: _tasks[taskIndex].isCompleted,
      );
      notifyListeners();
    }
  }

  void toggleTaskCompletion(String id) {
    final taskIndex = _tasks.indexWhere((task) => task.id == id);
    if (taskIndex != -1) {
      _tasks[taskIndex].isCompleted = !_tasks[taskIndex].isCompleted;
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }
}