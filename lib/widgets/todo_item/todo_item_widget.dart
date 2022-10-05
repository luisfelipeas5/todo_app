import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/bloc/todo_bloc.dart';
import 'package:todo_app/bloc/todo_event.dart';
import 'package:todo_app/todo_item.dart';

class TodoItemWidget extends StatefulWidget {
  const TodoItemWidget({
    super.key,
    required this.todoItem,
    required this.index,
    this.focusNode,
  });

  final TodoItem todoItem;
  final int index;
  final FocusNode? focusNode;

  @override
  State<TodoItemWidget> createState() => _TodoItemWidgetState();
}

class _TodoItemWidgetState extends State<TodoItemWidget> {
  TodoBloc get _bloc => BlocProvider.of<TodoBloc>(context);
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textController.text = widget.todoItem.description ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key("dismissible-${widget.todoItem.id}"),
      onDismissed: _onDismissed,
      background: Container(color: Colors.red),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _buildItemCheckbox(),
            Expanded(
              child: _buildItemTextField(),
            ),
            const Icon(Icons.menu),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Checkbox _buildItemCheckbox() {
    return Checkbox(
      value: widget.todoItem.done,
      onChanged: _onCheckboxChanged,
    );
  }

  void _onCheckboxChanged(bool? value) {
    _bloc.add(TodoDoneUpdateEvent(
      todoItem: widget.todoItem,
      index: widget.index,
      newDoneValue: value ?? false,
    ));
  }

  TextField _buildItemTextField() {
    return TextField(
      focusNode: widget.focusNode,
      controller: textController,
      minLines: 1,
      maxLines: 5,
      onChanged: _onTextFieldChanged,
    );
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
