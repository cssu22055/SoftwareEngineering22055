import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'task_model.dart';
import 'task_list.dart';
import 'task_form.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskModel(),
      child: MaterialApp(
        title: 'Task Manager',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SignInDemo(),
      ),
    );
  }
}

class SignInDemo extends StatefulWidget {
  @override
  State createState() => SignInDemoState();
}

class SignInDemoState extends State<SignInDemo> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      gmail.GmailApi.gmailReadonlyScope,
    ],
  );

  GoogleSignInAccount? _currentUser;
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;
  String _taskSearchQuery = '';
  bool _showCompletedTasks = false;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() async {
    await _googleSignIn.disconnect();
  }

  Future<void> _fetchTasksFromGmail() async {
    if (_currentUser == null) return;

    final authHeaders = await _currentUser!.authHeaders;
    final authenticatedClient = GoogleHttpClient(authHeaders);
    final gmailApi = gmail.GmailApi(authenticatedClient);

    final List<gmail.Message> messages = [];

    // final query = _searchQuery;
    String query = _searchQuery;
    if (_startDate != null) {
      query += ' after:${_startDate!.millisecondsSinceEpoch ~/ 1000}';
    }
    if (_endDate != null) {
      query += ' before:${_endDate!.millisecondsSinceEpoch ~/ 1000}';
    }
    final messagesList = await gmailApi.users.messages.list(
      'me',
      q: query,
      maxResults: 100,
    );

    if (messagesList.messages != null) {
      for (var message in messagesList.messages!) {
        final msg = await gmailApi.users.messages.get('me', message.id!);
        messages.add(msg);
      }
    }

    final taskModel = Provider.of<TaskModel>(context, listen: false);
    for (var message in messages) {
      final subject = message.payload?.headers
          ?.firstWhere((header) => header.name == 'Subject')
          .value;
      if (subject != null) {
        taskModel.addTask(
          title: subject,
          description: message.snippet ?? '',
          dueDate: DateTime.now().add(Duration(days: 7)),
          actualDeadline: DateTime.now().add(Duration(days: 7)),
          priority: 1,
          tags: [],
        );
      }
    }
  }

  void _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _searchTasks() {
    setState(() {});
  }

  Widget _buildBody() {
    if (_currentUser != null) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(labelText: 'Gmail検索クエリ'),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          ListTile(
            title: Text(
                '開始日: ${_startDate != null ? _startDate!.toLocal().toString().split(' ')[0] : ''}'),
            trailing: Icon(Icons.calendar_today),
            onTap: _selectStartDate,
          ),
          ListTile(
            title: Text(
                '終了日: ${_endDate != null ? _endDate!.toLocal().toString().split(' ')[0] : ''}'),
            trailing: Icon(Icons.calendar_today),
            onTap: _selectEndDate,
          ),
          ElevatedButton(
            onPressed: _fetchTasksFromGmail,
            child: Text('Gmailからタスクを取得'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(labelText: 'タスク検索クエリ'),
              onChanged: (value) {
                setState(() {
                  _taskSearchQuery = value;
                });
              },
            ),
          ),
         // ElevatedButton(
           // onPressed: _searchTasks,
            //child: Text('タスク検索'),
          //),
          Expanded(
            child: TaskList(
              showCompleted: _showCompletedTasks,
              searchQuery: _taskSearchQuery,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _showCompletedTasks = !_showCompletedTasks;
              });
            },
            child: Text(_showCompletedTasks ? '未完了タスクを表示' : '完了タスクを表示'),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("サインインしていません。"),
          ElevatedButton(
            onPressed: _handleSignIn,
            child: Text("サインイン"),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('タスク管理'),
        actions: _currentUser != null
            ? [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _handleSignOut,
          )
        ]
            : null,
      ),
      body: _buildBody(),
      floatingActionButton: _currentUser != null
          ? FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TaskForm(),
            ),
          );
        },
        child: Icon(Icons.add),
      )
          : null,
    );
  }
}

class GoogleHttpClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleHttpClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}