import 'package:flutter/material.dart';
import 'package:todo_app/todo_item.dart';

class TodoItemWidget extends StatefulWidget {
  const TodoItemWidget({
    super.key,
    required this.todoItem,
    this.focusNode,
    required this.onDismissed,
    required this.onCheckboxChanged,
    required this.onTextFieldChanged,
  });

  final TodoItem todoItem;
  final FocusNode? focusNode;
  final DismissDirectionCallback onDismissed;
  final ValueChanged<bool?> onCheckboxChanged;
  final ValueChanged<String> onTextFieldChanged;

  @override
  State<TodoItemWidget> createState() => _TodoItemWidgetState();
}

class _TodoItemWidgetState extends State<TodoItemWidget> {
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
      onDismissed: widget.onDismissed,
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
      onChanged: widget.onCheckboxChanged,
    );
  }

  TextField _buildItemTextField() {
    return TextField(
      focusNode: widget.focusNode,
      controller: textController,
      minLines: 1,
      maxLines: 5,
      onChanged: widget.onTextFieldChanged,
    );
  }
}
