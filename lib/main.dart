import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/local_data_source.dart';
import 'package:todo_app/todo_page.dart';

void main() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  final localDataSource = LocalDataSource(sharedPreferences);

  runApp(MyApp(
    localDataSource: localDataSource,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.localDataSource,
  });

  final LocalDataSource localDataSource;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoPage(
        localDataSource: localDataSource,
      ),
    );
  }
}
