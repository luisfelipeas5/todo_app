import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/bloc/todo_bloc.dart';
import 'package:todo_app/bloc/todo_event.dart';
import 'package:todo_app/bloc/todo_state.dart';
import 'package:todo_app/not_smart_widgets/todo_item/todo_item_widget.dart';
import 'package:todo_app/todo_item.dart';
import 'package:todo_app/widgets/todo_item/todo_page_todo_item_widget.dart';

import '../../not_smart_widgets/todo_item/todo_item_widget_tester.dart';

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
            child: TodoPageTodoItemWidget(
              todoItem: todoItem,
              index: index,
              focusNode: focusNode,
            ),
          ),
        ),
      ),
    );
  }

  group("TodoPageTodoItemWidget", () {
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

    testWidgets(
      "given a todo item, "
      "when pumped, "
      "then expects to find a TodoItemWidget with todo item",
      (tester) async {
        await pumpTodoItemWidget(tester);

        final finder = find.byType(TodoItemWidget);
        final todoItemWidget = tester.widget(finder) as TodoItemWidget;
        expect(todoItemWidget.todoItem, todoItem);
      },
    );

    group("TodoDoneUpdateEvent", () {
      testWidgets(
        "given a todo item with done = false, "
        "when TodoItemWidget.onCheckedChange is called, "
        "then expects to add TodoDoneUpdateEvent to TodoBloc with newDoneValue = true",
        (tester) async {
          when(() => todoItem.done).thenReturn(false);

          await pumpTodoItemWidget(tester);
          await TodoItemWidgetTester.callOnCheckboxChanged(tester);

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
        "when TodoItemWidget.onCheckedChange is called, "
        "then expects to add TodoDoneUpdateEvent to TodoBloc with newDoneValue = false",
        (tester) async {
          when(() => todoItem.done).thenReturn(true);

          await pumpTodoItemWidget(tester);
          await TodoItemWidgetTester.callOnCheckboxChanged(tester);

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
        "given a todo item with done = false, "
        "when TodoItemWidget.onTextFieldChanged is called, "
        "then expects to add TodoDescriptionUpdateEvent to TodoBloc",
        (tester) async {
          await pumpTodoItemWidget(tester);

          const newDescription = "new mocked description";
          await TodoItemWidgetTester.callOnTextFieldChanged(
              tester, newDescription);

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
        "when TodoItemWidget.onDismissed is called, "
        "then expects to add TodoDismissedEvent to TodoBloc",
        (tester) async {
          await pumpTodoItemWidget(tester);

          await TodoItemWidgetTester.callOnDismissed(tester);

          verify(
            () => todoBloc.add(TodoDismissedEvent(
              index: index,
              todoItem: todoItem,
            )),
          ).called(1);
        },
      );

      testWidgets(
        "when TodoItemWidget.onDismissed is called and tapped on 'undo' of Snackbar, "
        "then expects to add TodoUndoDismissedEvent to TodoBloc",
        (tester) async {
          await pumpTodoItemWidget(tester);

          await TodoItemWidgetTester.callOnDismissed(tester);

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
