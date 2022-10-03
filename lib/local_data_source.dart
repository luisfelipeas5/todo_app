import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/todo_item.dart';

class LocalDataSource {
  static const String _todoItemsKey = "todo_items";

  final SharedPreferences _sharedPreferences;

  LocalDataSource(
    this._sharedPreferences,
  );

  List<TodoItem> getTodoItems() {
    final todoItemsAsString = _sharedPreferences.getString(_todoItemsKey);
    if (todoItemsAsString == null) return [];

    final List todoItemsDecoded = jsonDecode(todoItemsAsString);
    return todoItemsDecoded
        .map(
          (element) => TodoItem.fromJson(element),
        )
        .toList();
  }

  Future<bool> saveTodoItems(List<TodoItem> todoItems) {
    final todoItemsJson = todoItems
        .map(
          (todoItem) => todoItem.toJson(),
        )
        .toList();
    final todoItemsEncoded = jsonEncode(todoItemsJson);
    return _sharedPreferences.setString(_todoItemsKey, todoItemsEncoded);
  }
}
