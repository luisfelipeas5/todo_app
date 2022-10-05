import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/bloc/todo_bloc.dart';
import 'package:todo_app/bloc/todo_event.dart';
import 'package:todo_app/bloc/todo_state.dart';
import 'package:todo_app/todo_item.dart';
import 'package:todo_app/widgets/todo_item/todo_item_widget.dart';

void main() {
  late TodoItem todoItem;
  late TodoBloc todoBloc;

  const index = 198;

  Future<void> pumpTodoItemWidget(
    WidgetTester tester, {
    FocusNode? focusNode,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          body: BlocProvider.value(
            value: todoBloc,
            child: TodoItemWidget(
              todoItem: todoItem,
              index: index,
              focusNode: focusNode,
            ),
          ),
        ),
      ),
    );
  }

  group("TodoItemWidget", () {
    setUp(() {
      todoItem = _MockTodoItem();
      when(() => todoItem.id).thenReturn(0);
      when(() => todoItem.done).thenReturn(false);
      when(() => todoItem.description).thenReturn("");

      todoBloc = _MockTodoBloc();
      whenListen(
        todoBloc,
        const Stream<TodoState>.empty(),
        initialState: _MockTodoState(),
      );
    });

    group("Checkbox", () {
      testWidgets(
        "given a todo item with done = false, "
        "when pumped, "
        "then expects to find a checkbox not checked",
        (tester) async {
          when(() => todoItem.done).thenReturn(false);

          await pumpTodoItemWidget(tester);

          final finder = find.byType(Checkbox);
          final checkbox = tester.widget(finder) as Checkbox;
          expect(checkbox.value, isFalse);
        },
      );

      testWidgets(
        "given a todo item with done = true, "
        "when pumped, "
        "then expects to find a checkbox checked",
        (tester) async {
          when(() => todoItem.done).thenReturn(true);

          await pumpTodoItemWidget(tester);

          final finder = find.byType(Checkbox);
          final checkbox = tester.widget(finder) as Checkbox;
          expect(checkbox.value, isTrue);
        },
      );

      testWidgets(
        "given a todo item with done = false, "
        "when checkbox is tapped, "
        "then expects to add TodoDoneUpdateEvent to TodoBloc with newDoneValue = true",
        (tester) async {
          when(() => todoItem.done).thenReturn(false);

          await pumpTodoItemWidget(tester);
          await tester.tap(find.byType(Checkbox));

          verify(
            () => todoBloc.add(TodoDoneUpdateEvent(
              index: index,
              todoItem: todoItem,
              newDoneValue: true,
            )),
          ).called(1);
        },
      );

      testWidgets(
        "given a todo item with done = true, "
        "when checkbox is tapped, "
        "then expects to add TodoDoneUpdateEvent to TodoBloc with newDoneValue = false",
        (tester) async {
          when(() => todoItem.done).thenReturn(true);

          await pumpTodoItemWidget(tester);
          await tester.tap(find.byType(Checkbox));

          verify(
            () => todoBloc.add(TodoDoneUpdateEvent(
              index: index,
              todoItem: todoItem,
              newDoneValue: false,
            )),
          ).called(1);
        },
      );
    });

    group("TextField", () {
      testWidgets(
        "given a todo list item with a description, "
        "when pumped, "
        "then expects to find a text field with that description",
        (tester) async {
          const description = "mock description";
          when(() => todoItem.description).thenReturn(description);

          await pumpTodoItemWidget(tester);

          final finder = find.byType(TextField);
          final textField = tester.widget(finder) as TextField;
          expect(textField.controller?.text, description);
        },
      );

      testWidgets(
        "given a todo item with done = false, "
        "when checkbox is tapped, "
        "then expects to add TodoDescriptionUpdateEvent to TodoBloc",
        (tester) async {
          await pumpTodoItemWidget(tester);

          const newDescription = "new mocked description";
          await tester.enterText(
            find.byType(TextField),
            newDescription,
          );

          verify(
            () => todoBloc.add(TodoDescriptionUpdateEvent(
              index: index,
              todoItem: todoItem,
              newDescription: newDescription,
            )),
          ).called(1);
        },
      );
    });

    group("Dismissible", () {
      testWidgets(
        "when drag icon widget and swiped to left, "
        "then expects to add TodoDismissedEvent to TodoBloc",
        (tester) async {
          await pumpTodoItemWidget(tester);

          final dragIconFinder = find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.menu,
          );
          await tester.drag(
            dragIconFinder,
            const Offset(-1000, 0),
          );
          await tester.pumpAndSettle();

          verify(
            () => todoBloc.add(TodoDismissedEvent(
              index: index,
              todoItem: todoItem,
            )),
          ).called(1);
        },
      );

      testWidgets(
        "when drag icon widget and swiped to left and tapped on 'undo' of Snackbar, "
        "then expects to add TodoUndoDismissedEvent to TodoBloc",
        (tester) async {
          await pumpTodoItemWidget(tester);

          final dragIconFinder = find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.menu,
          );
          await tester.drag(
            dragIconFinder,
            const Offset(-1000, 0),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text("Undo"));

          verify(
            () => todoBloc.add(TodoUndoDismissedEvent(
              index: index,
              todoItem: todoItem,
            )),
          ).called(1);
        },
      );
    });
  });
}

class _MockTodoItem extends Mock implements TodoItem {}

class _MockTodoBloc extends Mock implements TodoBloc {}

class _MockTodoState extends Mock implements TodoState {
  _MockTodoState() {
    when(() => showDeleteAllButton).thenReturn(false);
    when(() => showSortButton).thenReturn(false);
    when(() => showCopyButton).thenReturn(false);
  }
}
