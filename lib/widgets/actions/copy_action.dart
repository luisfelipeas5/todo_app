import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/bloc/todo_bloc.dart';
import 'package:todo_app/bloc/todo_event.dart';

class CopyAction extends StatelessWidget {
  const CopyAction({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        final bloc = BlocProvider.of<TodoBloc>(context);
        bloc.add(TodoCopyEvent());
      },
      icon: const Icon(Icons.copy),
    );
  }
}
