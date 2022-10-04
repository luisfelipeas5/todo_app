import 'package:flutter/material.dart';

class DeleteAllAction extends StatelessWidget {
  const DeleteAllAction({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.delete_forever),
    );
  }
}
