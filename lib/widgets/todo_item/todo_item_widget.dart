import 'package:flutter/material.dart';
import 'package:todo_app/todo_item.dart';

class TodoItemWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(todoItem.id),
      onDismissed: onDismissed,
      background: Container(color: Colors.red),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _buildItemCheckbox(),
            Expanded(
              child: _buildItemTextField(),
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

  Checkbox _buildItemCheckbox() {
    return Checkbox(
      value: todoItem.done,
      onChanged: onCheckboxChanged,
    );
  }

  TextField _buildItemTextField() {
    return TextField(
      focusNode: focusNode,
      controller: TextEditingController(
        text: todoItem.description,
      ),
      minLines: 1,
      maxLines: 5,
      onChanged: onTextFieldChanged,
    );
  }
}
