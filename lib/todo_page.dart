import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_app/local_data_source.dart';
import 'package:todo_app/todo_item.dart';
import 'package:todo_app/widgets/actions/copy_action.dart';
import 'package:todo_app/widgets/actions/delete_all_action.dart';
import 'package:todo_app/widgets/actions/sort_action.dart';
import 'package:todo_app/widgets/dialog/delete_all_confirmation_dialog.dart';
import 'package:todo_app/widgets/todo_item/todo_item_widget.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({
    super.key,
    required this.localDataSource,
  });

  final LocalDataSource localDataSource;

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  LocalDataSource get _localDataSource => widget.localDataSource;
  List<TodoItem> _todoItems = List.empty(growable: true);
  FocusNode? _lastFocusNode;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    setState(() {
      _todoItems = _localDataSource.getTodoItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TODO"),
        actions: [
          if (_todoItems.any((element) => element.done)) _buildSortButton(),
          if (_todoItems.isNotEmpty) _buildCopyMethod(),
          if (_todoItems.isNotEmpty) _buildDeleteAllButton(),
        ],
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.only(
          bottom: 56,
        ),
        itemCount: _todoItems.length,
        onReorder: _onReorder,
        itemBuilder: _itemBuilder,
      ),
      floatingActionButton: _buildAddButton(),
    );
  }

  //Não vale a pena transformar esse componente em um not-smart widget
  Widget _buildSortButton() {
    return SortAction(
      onPressed: () {
        setState(() {
          _todoItems.sort((todoItem0, todoItem1) {
            if (todoItem0.done && !todoItem1.done) {
              return -1;
            }
            if (!todoItem0.done && todoItem1.done) {
              return 1;
            }
            return 0;
          });
        });
      },
    );
  }

  //Não vale a pena transformar esse componente em um not-smart widget
  Widget _buildCopyMethod() {
    return CopyAction(
      onPressed: () async {
        final todoItemsAsString = _todoItems.map(
          (e) {
            if (e.done) {
              return "[X] ${e.description}";
            }
            return "[ ] ${e.description}";
          },
        ).join("\n");
        await Clipboard.setData(
          ClipboardData(text: todoItemsAsString),
        );
      },
    );
  }

  //Não vale a pena transformar esse componente em um not-smart widget
  Widget _buildDeleteAllButton() {
    return DeleteAllAction(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return _buildConfirmationDialog();
          },
        );
      },
    );
  }

  Widget _buildConfirmationDialog() {
    return DeleteAllConfirmationDialog(
      onConfirmPressed: () {
        setState(() {
          _todoItems.clear();
          _localDataSource.saveTodoItems(_todoItems);
          Navigator.of(context).pop();
        });
      },
    );
  }

  void _onReorder(oldIndex, newIndex) {
    setState(() {
      final todoItem = _todoItems[oldIndex];
      _todoItems.insert(newIndex, todoItem);
      if (oldIndex > newIndex) {
        _todoItems.removeAt(oldIndex + 1);
      } else {
        _todoItems.removeAt(oldIndex);
      }
      _localDataSource.saveTodoItems(_todoItems);
    });
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final todoItem = _todoItems[index];
    final lastItem = index == _todoItems.length - 1;
    final focusNode = lastItem ? FocusNode() : null;
    if (lastItem) _lastFocusNode = focusNode;
    return TodoItemWidget(
      todoItem: todoItem,
      focusNode: focusNode,
      onDismissed: (direction) => _onDismissed(index, context, todoItem),
      onCheckboxChanged: (value) => _onCheckboxChanged(index, todoItem, value),
      onTextFieldChanged: (value) =>
          _onTextFieldChanged(todoItem, index, value),
    );
  }

  void _onTextFieldChanged(TodoItem todoItem, int index, String value) {
    final newItem = todoItem.id == TodoItem.newItemId;

    _todoItems[index] = todoItem.copyWith(
      id: newItem ? _todoItems.length : null,
      description: value,
    );
    _localDataSource.saveTodoItems(_todoItems);
  }

  void _onCheckboxChanged(int index, TodoItem todoItem, bool? value) {
    setState(() {
      _todoItems[index] = todoItem.copyWith(
        done: value,
      );
      if (todoItem.id != TodoItem.newItemId) {
        _localDataSource.saveTodoItems(_todoItems);
      }
    });
  }

  void _onDismissed(
    int index,
    BuildContext context,
    TodoItem todoItem,
  ) {
    setState(() {
      _todoItems.removeAt(index);
      _localDataSource.saveTodoItems(_todoItems);
    });

    _showUndoSnackbar(context, index, todoItem);
  }

  void _showUndoSnackbar(
    BuildContext context,
    int index,
    TodoItem todoItem,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Removed item'),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            setState(() {
              _todoItems.insert(index, todoItem);
              _localDataSource.saveTodoItems(_todoItems);
            });
          },
        ),
      ),
    );
  }

  //Não vale a pena transformar esse componente em um not-smart widget
  FloatingActionButton _buildAddButton() {
    return FloatingActionButton(
      onPressed: () async {
        if (_todoItems.isEmpty || _todoItems.last.id != TodoItem.newItemId) {
          setState(() {
            _todoItems.add(TodoItem.newItem());
          });
          await Future.delayed(const Duration(milliseconds: 500));
        }
        _lastFocusNode?.requestFocus();
      },
      child: const Icon(Icons.add),
    );
  }
}
