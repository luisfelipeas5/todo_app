import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/not_smart_widgets/todo_item/todo_item_widget.dart';
import 'package:todo_app/todo_item.dart';

void main() {
  late TodoItem todoItem;

  Future<void> pumpTodoItemWidget(
    WidgetTester tester, {
    FocusNode? focusNode,
    DismissDirectionCallback? onDismissed,
    ValueChanged<bool?>? onCheckboxChanged,
    ValueChanged<String>? onTextFieldChanged,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Material(
          child: TodoItemWidget(
            todoItem: todoItem,
            onCheckboxChanged: onCheckboxChanged ?? (_) {},
            onDismissed: onDismissed ?? (_) {},
            onTextFieldChanged: onTextFieldChanged ?? (_) {},
            focusNode: focusNode,
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
        "then expects to call onCheckboxChanged callback with true",
        (tester) async {
          when(() => todoItem.done).thenReturn(false);

          bool? result;
          onCheckboxChanged(changed) {
            result = changed;
          }

          await pumpTodoItemWidget(
            tester,
            onCheckboxChanged: onCheckboxChanged,
          );
          await tester.tap(find.byType(Checkbox));

          expect(result, isTrue);
        },
      );

      testWidgets(
        "given a todo item with done = true, "
        "when checkbox is tapped, "
        "then expects to call onCheckboxChanged callback with false",
        (tester) async {
          when(() => todoItem.done).thenReturn(true);

          bool? result;
          onCheckboxChanged(changed) {
            result = changed;
          }

          await pumpTodoItemWidget(
            tester,
            onCheckboxChanged: onCheckboxChanged,
          );
          await tester.tap(find.byType(Checkbox));

          expect(result, isFalse);
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
        "then expects to call onCheckboxChanged callback with true",
        (tester) async {
          String? result;
          onTextFieldChanged(description) {
            result = description;
          }

          await pumpTodoItemWidget(
            tester,
            onTextFieldChanged: onTextFieldChanged,
          );

          const newDescription = "new mocked description";
          await tester.enterText(
            find.byType(TextField),
            newDescription,
          );

          expect(result, newDescription);
        },
      );
    });

    group("Dismissible", () {
      testWidgets(
        "when drag icon widget and swiped to left, "
        "then expects to call onDismissed",
        (tester) async {
          final completer = Completer();
          onDismissed(direction) {
            completer.complete();
          }

          await pumpTodoItemWidget(
            tester,
            onDismissed: onDismissed,
          );

          final dragIconFinder = find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.menu,
          );
          await tester.drag(
            dragIconFinder,
            const Offset(-1000, 0),
          );
          await tester.pumpAndSettle();

          expect(completer.isCompleted, isTrue);
        },
      );
    });
  });
}

class _MockTodoItem extends Mock implements TodoItem {}
