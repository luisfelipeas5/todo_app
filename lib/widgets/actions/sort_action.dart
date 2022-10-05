import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/bloc/todo_bloc.dart';
import 'package:todo_app/bloc/todo_event.dart';

class SortAction extends StatelessWidget {
  const SortAction({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        final bloc = BlocProvider.of<TodoBloc>(context);
        bloc.add(TodoSortEvent());
      },
      icon: const Icon(Icons.sort),
    );
  }
}
