import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/bloc/todo_bloc.dart';
import 'package:todo_app/bloc/todo_event.dart';
import 'package:todo_app/bloc/todo_state.dart';
import 'package:todo_app/widgets/actions/copy_action.dart';

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
            child: const CopyAction(),
          ),
        ),
      ),
    );
  }

  group("CopyAction", () {
    setUp(() {
      todoBloc = _MockTodoBlox();
      whenListen(
        todoBloc,
        const Stream<TodoState>.empty(),
        initialState: _MockTodoState(),
      );
    });

    testWidgets(
      "when pumped, then expects to find Icon with icon = Icons.copy",
      (tester) async {
        await pumpAction(tester);

        final icon = tester.widget(find.byType(Icon)) as Icon;
        expect(icon.icon, Icons.copy);
      },
    );

    testWidgets(
      "when icon is tapped."
      " then expects to add TodoCopyEvent to TodoBloc",
      (tester) async {
        await pumpAction(tester);

        await tester.tap(find.byType(Icon));

        verify(() => todoBloc.add(TodoCopyEvent())).called(1);
      },
    );
  });
}

class _MockTodoBlox extends Mock implements TodoBloc {}

class _MockTodoState extends Mock implements TodoState {}