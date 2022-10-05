import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/bloc/todo_bloc.dart';
import 'package:todo_app/bloc/todo_event.dart';
import 'package:todo_app/not_smart_widgets/todo_item/todo_item_widget.dart';
import 'package:todo_app/todo_item.dart';

class TodoPageTodoItemWidget extends StatefulWidget {
  const TodoPageTodoItemWidget({
    super.key,
    required this.todoItem,
    required this.index,
    this.focusNode,
  });

  final TodoItem todoItem;
  final int index;
  final FocusNode? focusNode;

  @override
  State<TodoPageTodoItemWidget> createState() => _TodoPageTodoItemWidgetState();
}

class _TodoPageTodoItemWidgetState extends State<TodoPageTodoItemWidget> {
  TodoBloc get _bloc => BlocProvider.of<TodoBloc>(context);
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textController.text = widget.todoItem.description ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return TodoItemWidget(
      todoItem: widget.todoItem,
      focusNode: widget.focusNode,
      onDismissed: _onDismissed,
      onCheckboxChanged: _onCheckboxChanged,
      onTextFieldChanged: _onTextFieldChanged,
    );
  }

  void _onCheckboxChanged(bool? value) {
    _bloc.add(TodoDoneUpdateEvent(
      todoItem: widget.todoItem,
      index: widget.index,
      newDoneValue: value ?? false,
    ));
  }

  void _onTextFieldChanged(String value) {
    _bloc.add(TodoDescriptionUpdateEvent(
      todoItem: widget.todoItem,
      index: widget.index,
      newDescription: value,
    ));
  }

  void _onDismissed(DismissDirection direction) {
    _bloc.add(TodoDismissedEvent(
      todoItem: widget.todoItem,
      index: widget.index,
    ));

    _showUndoSnackbar();
  }

  void _showUndoSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Removed item'),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            _bloc.add(TodoUndoDismissedEvent(
              todoItem: widget.todoItem,
              index: widget.index,
            ));
          },
        ),
      ),
    );
  }
}
