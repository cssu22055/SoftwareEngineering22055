import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_model.dart';
import 'task_form.dart';

class TaskList extends StatelessWidget {
  final bool showCompleted;
  final String searchQuery;

  TaskList({required this.showCompleted, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskModel>(
      builder: (context, taskModel, child) {
        final tasks = showCompleted
            ? taskModel.completedTasks.where((task) {
          return task.title.contains(searchQuery) ||
              task.description.contains(searchQuery);
        }).toList()
            : taskModel.tasks.where((task) {
          return task.title.contains(searchQuery) ||
              task.description.contains(searchQuery);
        }).toList();
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return ListTile(
              title: Text(task.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('説明: ${task.description}'),
                  Text('期限日: ${task.dueDate.toLocal().toString().split(' ')[0]}'),
                  Text('実際の期限日: ${task.actualDeadline.toLocal().toString().split(' ')[0]}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () {
                      Provider.of<TaskModel>(context, listen: false)
                          .toggleTaskCompletion(task.id);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      Provider.of<TaskModel>(context, listen: false)
                          .deleteTask(task.id);
                    },
                  ),
                ],
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TaskForm(task: task),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}