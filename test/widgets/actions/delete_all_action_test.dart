import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/bloc/todo_bloc.dart';
import 'package:todo_app/bloc/todo_event.dart';
import 'package:todo_app/bloc/todo_state.dart';
import 'package:todo_app/widgets/actions/delete_all_action.dart';
import 'package:todo_app/widgets/dialog/delete_all_confirmation_dialog.dart';

import '../dialog/delete_all_confirmation_dialog_tester.dart';

void main() {
  late TodoBloc todoBloc;

  Future<void> pumpAction(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Material(
          child: BlocProvider.value(
            value: todoBloc,
            child: const DeleteAllAction(),
          ),
        ),
      ),
    );
  }

  group("DeleteAllAction", () {
    setUp(() {
      todoBloc = _MockTodoBlox();
      whenListen(
        todoBloc,
        const Stream<TodoState>.empty(),
        initialState: _MockTodoState(),
      );
    });

    testWidgets(
      "when pumped, then expects to find Icon with icon = Icons.delete_forever",
      (tester) async {
        await pumpAction(tester);

        final icon = tester.widget(find.byType(Icon)) as Icon;
        expect(icon.icon, Icons.delete_forever);
      },
    );

    testWidgets(
      "when icon is tapped, "
      "then expects to find DeleteAllConfirmationDialog",
      (tester) async {
        await pumpAction(tester);

        final finder = find.byType(DeleteAllAction);
        await tester.tap(finder);
        await tester.pumpAndSettle();

        final dialogFinder = find.byType(DeleteAllConfirmationDialog);
        expect(dialogFinder, findsOneWidget);
      },
    );

    testWidgets(
      "when icon is tapped and then 'yes' button is clicked, "
      "then expects to add TodoDeleteAllEvent to TodoBloc",
      (tester) async {
        await pumpAction(tester);

        await tester.tap(find.byType(Icon));
        await tester.pumpAndSettle();

        await DeleteAllConfirmationDialogTester.callOnPressed(tester);

        verify(
          () => todoBloc.add(TodoDeleteAllEvent()),
        ).called(1);
      },
    );
  });
}

class _MockTodoBlox extends Mock implements TodoBloc {}

class _MockTodoState extends Mock implements TodoState {}
