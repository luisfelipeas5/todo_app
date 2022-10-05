import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/bloc/todo_bloc.dart';
import 'package:todo_app/bloc/todo_event.dart';
import 'package:todo_app/widgets/dialog/delete_all_confirmation_dialog.dart';

class DeleteAllAction extends StatelessWidget {
  const DeleteAllAction({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) {
            return _buildConfirmationDialog(context);
          },
        );
      },
      icon: const Icon(Icons.delete_forever),
    );
  }

  Widget _buildConfirmationDialog(BuildContext context) {
    return DeleteAllConfirmationDialog(
      onConfirmPressed: () {
        final bloc = BlocProvider.of<TodoBloc>(context);
        bloc.add(TodoDeleteAllEvent());
        Navigator.of(context).pop();
      },
    );
  }
}
