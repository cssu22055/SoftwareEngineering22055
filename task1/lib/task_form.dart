import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_model.dart';

class TaskForm extends StatefulWidget {
  final Task? task;

  TaskForm({this.task});

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late DateTime _dueDate;
  late DateTime _actualDeadline;
  late int _priority;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title = widget.task!.title;
      _description = widget.task!.description;
      _dueDate = widget.task!.dueDate;
      _actualDeadline = widget.task!.actualDeadline;
      _priority = widget.task!.priority;
      _tags = widget.task!.tags;
    } else {
      _title = '';
      _description = '';
      _dueDate = DateTime.now();
      _actualDeadline = DateTime.now();
      _priority = 3;
      _tags = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.task == null ? 'タスク追加' : 'タスク編集'),
        ),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
    child: Form(
    key: _formKey,
    child: ListView(
    children: <Widget>[
    TextFormField(
    initialValue: _title,
    decoration: InputDecoration(labelText: 'タイトル'),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'タイトルを入力してください';
    }
    return null;
    },
    onSaved: (value) {
    _title = value!;
    },
    ),
      TextFormField(
        initialValue: _description,
        decoration: InputDecoration(labelText: '説明'),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '説明を入力してください';
          }
          return null;
        },
        onSaved: (value) {
          _description = value!;
        },
      ),
      ListTile(
        title: Text('期限日: ${_dueDate.toLocal()}'.split(' ')[0]),
        trailing: Icon(Icons.calendar_today),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _dueDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (picked != null && picked != _dueDate) {
            setState(() {
              _dueDate = picked;
            });
          }
        },
      ),
      ListTile(
        title: Text('実際期限日: ${_actualDeadline.toLocal()}'.split(' ')[0]),
        trailing: Icon(Icons.calendar_today),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _actualDeadline,
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (picked != null && picked != _actualDeadline) {
            setState(() {
              _actualDeadline = picked;
            });
          }
        },
      ),
      DropdownButtonFormField<int>(
        value: _priority,
        decoration: InputDecoration(labelText: '優先度'),
        items: [
          DropdownMenuItem(value: 1, child: Text('高')),
          DropdownMenuItem(value: 2, child: Text('中')),
          DropdownMenuItem(value: 3, child: Text('低')),
        ],
        onChanged: (value) {
          setState(() {
            _priority = value!;
          });
        },
      ),
      TextFormField(
        initialValue: _tags.join(', '),
        decoration: InputDecoration(labelText: 'タグ'),
        onSaved: (value) {
          _tags = value!.split(', ');
        },
      ),
      SizedBox(height: 20),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            if (widget.task == null) {
              Provider.of<TaskModel>(context, listen: false).addTask(
                title: _title,
                description: _description,
                dueDate: _dueDate,
                actualDeadline: _actualDeadline,
                priority: _priority,
                tags: _tags,
              );
            } else {
              Provider.of<TaskModel>(context, listen: false).updateTask(
                widget.task!.id,
                title: _title,
                description: _description,
                dueDate: _dueDate,
                actualDeadline: _actualDeadline,
                priority: _priority,
                tags: _tags,
              );
            }
            Navigator.pop(context);
          }
        },
        child: Text(widget.task == null ? 'タスクを追加' : 'タスクを更新'),
      ),
    ],
    ),
    ),
        ),
    );
  }
}
