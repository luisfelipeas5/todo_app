import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/bloc/todo_bloc.dart';
import 'package:todo_app/bloc/todo_event.dart';
import 'package:todo_app/bloc/todo_state.dart';
import 'package:todo_app/todo_item.dart';
import 'package:todo_app/widgets/actions/add_floating_action_button.dart';
import 'package:todo_app/widgets/actions/copy_action.dart';
import 'package:todo_app/widgets/actions/delete_all_action.dart';
import 'package:todo_app/widgets/actions/sort_action.dart';
import 'package:todo_app/widgets/todo_item/todo_page_todo_item_widget.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({
    super.key,
  });

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  TodoBloc get _bloc => BlocProvider.of<TodoBloc>(context);

  List<TodoItem> get _todoItems => _bloc.state.todoItems;
  FocusNode? _lastFocusNode;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodoBloc, TodoState>(
      listener: _todoBlocListener,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("TODO"),
            actions: [
              if (state.showSortButton) const SortAction(),
              if (state.showCopyButton) const CopyAction(),
              if (state.showDeleteAllButton) const DeleteAllAction(),
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
          floatingActionButton: const AddFloatingActionButton(),
        );
      },
    );
  }

  void _todoBlocListener(context, state) async {
    switch (state.lastAction) {
      case TodoAction.newItem:
        return _focusOnLastNodeWithDelay();
      case TodoAction.copied:
        await Clipboard.setData(ClipboardData(text: state.textCopied));
        break;
      default:
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    _bloc.add(TodoReorderEvent(
      oldIndex: oldIndex,
      newIndex: newIndex,
    ));
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final todoItem = _todoItems[index];
    final lastItem = index == _todoItems.length - 1;
    final focusNode = lastItem ? FocusNode() : null;
    if (lastItem) _lastFocusNode = focusNode;
    return TodoPageTodoItemWidget(
      key: Key("todo-item-${todoItem.id}"),
      todoItem: todoItem,
      focusNode: focusNode,
      index: index,
    );
  }

  void _focusOnLastNodeWithDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _lastFocusNode?.requestFocus();
  }
}
