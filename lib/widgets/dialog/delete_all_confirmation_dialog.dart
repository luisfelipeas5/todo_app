import 'package:flutter/material.dart';

class DeleteAllConfirmationDialog extends StatelessWidget {
  const DeleteAllConfirmationDialog({
    super.key,
    required this.onConfirmPressed,
  });

  final VoidCallback onConfirmPressed;

  @override
  Widget build(BuildContext context) {
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
        _buildDeleteAllConfirmButton(context),
      ],
    );
  }

  TextButton _buildDeleteAllConfirmButton(BuildContext context) {
    return TextButton(
      onPressed: onConfirmPressed,
      child: Text(
        "Yes",
        style: Theme.of(context).textTheme.button?.copyWith(
              color: Colors.red,
            ),
      ),
    );
  }
}
