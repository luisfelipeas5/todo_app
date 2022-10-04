import 'package:flutter/material.dart';

class CopyAction extends StatelessWidget {
  const CopyAction({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.copy),
    );
  }
}
