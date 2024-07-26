import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_model.dart';

class TaskSearchDelegate extends SearchDelegate<Task?> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final taskModel = Provider.of<TaskModel>(context, listen: false);
    final results = taskModel.tasks.where((task) => task.title.contains(query)).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final task = results[index];
        return ListTile(
          title: Text(task.title),
          subtitle: Text(task.description),
          onTap: () {
            close(context, task);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final taskModel = Provider.of<TaskModel>(context, listen: false);
    final suggestions = taskModel.tasks.where((task) => task.title.contains(query)).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final task = suggestions[index];
        return ListTile(
          title: Text(task.title),
          subtitle: Text(task.description),
          onTap: () {
            query = task.title;
            showResults(context);
          },
        );
      },
    );
  }
}