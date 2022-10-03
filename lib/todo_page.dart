import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_app/local_data_source.dart';
import 'package:todo_app/todo_item.dart';

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

  IconButton _buildSortButton() {
    return IconButton(
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
      icon: const Icon(Icons.sort),
    );
  }

  IconButton _buildCopyMethod() {
    return IconButton(
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
      icon: const Icon(Icons.copy),
    );
  }

  IconButton _buildDeleteAllButton() {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return _buildConfirmationDialog();
          },
        );
      },
      icon: const Icon(Icons.delete_forever),
    );
  }

  AlertDialog _buildConfirmationDialog() {
    return AlertDialog(
      title: const Text("Do you want to clear all your list?"),
      content: const Text(
        "Pressing 'yes', all your list will be deleted and can't be restored",
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text("No"),
        ),
        _buildDeleteAllConfirmButton(),
      ],
    );
  }

  TextButton _buildDeleteAllConfirmButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          _todoItems.clear();
          _localDataSource.saveTodoItems(_todoItems);
          Navigator.of(context).pop();
        });
      },
      child: Text(
        "Yes",
        style: Theme.of(context).textTheme.button?.copyWith(
              color: Colors.red,
            ),
      ),
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

  Widget _itemBuilder(context, index) {
    final todoItem = _todoItems[index];
    final lastItem = index == _todoItems.length - 1;
    final focusNode = lastItem ? FocusNode() : null;
    if (lastItem) _lastFocusNode = focusNode;
    return Dismissible(
      key: ValueKey(todoItem.id),
      onDismissed: (direction) => _onDismissed(index, context, todoItem),
      background: Container(color: Colors.red),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _buildItemCheckbox(todoItem, index),
            Expanded(
              child: _buildItemTextField(focusNode, todoItem, index),
            ),
            Icon(
              Icons.menu,
              key: ValueKey("drag-icon-${todoItem.id}"),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  TextField _buildItemTextField(
    FocusNode? focusNode,
    TodoItem todoItem,
    int index,
  ) {
    return TextField(
      focusNode: focusNode,
      controller: TextEditingController(
        text: todoItem.description,
      ),
      minLines: 1,
      maxLines: 5,
      onChanged: (value) {
        final newItem = todoItem.id == TodoItem.newItemId;

        _todoItems[index] = todoItem.copyWith(
          id: newItem ? _todoItems.length : null,
          description: value,
        );
        _localDataSource.saveTodoItems(_todoItems);
      },
    );
  }

  Checkbox _buildItemCheckbox(
    TodoItem todoItem,
    int index,
  ) {
    return Checkbox(
      value: todoItem.done,
      onChanged: (value) {
        setState(() {
          _todoItems[index] = todoItem.copyWith(
            done: value,
          );
          if (todoItem.id != TodoItem.newItemId) {
            _localDataSource.saveTodoItems(_todoItems);
          }
        });
      },
    );
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
