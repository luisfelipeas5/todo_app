import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/local_data_source.dart';
import 'package:todo_app/todo_item.dart';
import 'package:todo_app/todo_page.dart';
import 'package:todo_app/widgets/actions/add_floating_action_button.dart';
import 'package:todo_app/widgets/actions/copy_action.dart';
import 'package:todo_app/widgets/actions/delete_all_action.dart';
import 'package:todo_app/widgets/actions/sort_action.dart';
import 'package:todo_app/widgets/dialog/delete_all_confirmation_dialog.dart';
import 'package:todo_app/widgets/todo_item/todo_item_widget.dart';

import 'widgets/dialog/delete_all_confirmation_dialog_tester.dart';
import 'widgets/todo_item/todo_item_widget_tester.dart';

void main() {
  late LocalDataSource localDataSource;
  late List<TodoItem> todoItems;

  Future<void> pumpTodoPage(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: TodoPage(
          localDataSource: localDataSource,
        ),
      ),
    );
  }

  group("TodoPage", () {
    setUp(() {
      todoItems = List.empty(growable: true);

      localDataSource = _MockLocalDataSource();
      when(localDataSource.getTodoItems).thenReturn(todoItems);
    });

    group("SortAction", () {
      testWidgets(
        "given an empty todo list, "
        "when pumped,"
        " then not expects to find sort button",
        (tester) async {
          todoItems.clear();

          await pumpTodoPage(tester);

          final finder = find.byType(SortAction);
          expect(finder, findsNothing);
        },
      );

      testWidgets(
        "given a todo list with no done items, "
        "when pumped,"
        " then not expects to find sort button",
        (tester) async {
          final mockTodoItem = _MockTodoItem();
          when(() => mockTodoItem.done).thenReturn(false);
          todoItems.add(mockTodoItem);

          await pumpTodoPage(tester);

          final finder = find.byType(SortAction);
          expect(finder, findsNothing);
        },
      );

      testWidgets(
        "given a todo list with one done item, "
        "when pumped, "
        " then expects to find sort button",
        (tester) async {
          final mockTodoItem0 = _MockTodoItem();
          when(() => mockTodoItem0.done).thenReturn(true);
          todoItems.add(mockTodoItem0);

          final mockTodoItem1 = _MockTodoItem();
          when(() => mockTodoItem1.done).thenReturn(false);
          todoItems.add(mockTodoItem1);

          await pumpTodoPage(tester);

          final finder = find.byType(SortAction);
          expect(finder, findsOneWidget);
        },
      );

      testWidgets(
        "given a todo list with one undone item at first and a done item at second, "
        "when sort button is clicked, "
        "then expects to find done item at first on list",
        (tester) async {
          final notDoneTodoItem = _MockTodoItem();
          when(() => notDoneTodoItem.done).thenReturn(false);
          todoItems.add(notDoneTodoItem);

          final doneTodoItem = _MockTodoItem();
          when(() => doneTodoItem.done).thenReturn(true);
          todoItems.add(doneTodoItem);

          await pumpTodoPage(tester);

          final finder = find.byType(SortAction);
          await tester.tap(finder);

          expect(todoItems, [doneTodoItem, notDoneTodoItem]);
        },
      );

      testWidgets(
        "given a todo list with first item with done = true, "
        "when sort button is clicked,"
        " then expects to find done item at first on list",
        (tester) async {
          final doneTodoItem = _MockTodoItem();
          when(() => doneTodoItem.done).thenReturn(true);
          todoItems.add(doneTodoItem);

          final notDoneTodoItem = _MockTodoItem();
          when(() => notDoneTodoItem.done).thenReturn(false);
          todoItems.add(notDoneTodoItem);

          await pumpTodoPage(tester);

          final finder = find.byType(SortAction);
          await tester.tap(finder);

          expect(todoItems, [doneTodoItem, notDoneTodoItem]);
        },
      );
    });

    group("CopyAction", () {
      testWidgets(
        "given an empty todo list item, "
        "when pumped, "
        "then not expects to find copy button",
        (tester) async {
          todoItems.clear();

          await pumpTodoPage(tester);

          final finder = find.byType(CopyAction);
          expect(finder, findsNothing);
        },
      );

      testWidgets(
        "given one item not done and another done"
        "when copy button is clicked, "
        "then expects to call flutter/platform - Clipboard.setData' with formatted text",
        (tester) async {
          String? result;
          tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            const OptionalMethodChannel('flutter/platform', JSONMethodCodec()),
            (message) async {
              if (message.method == 'Clipboard.setData') {
                result = message.arguments['text'];
              }
              return;
            },
          );

          final notDoneTodoItem = _MockTodoItem();
          when(() => notDoneTodoItem.done).thenReturn(false);
          when(() => notDoneTodoItem.description).thenReturn("not done");
          todoItems.add(notDoneTodoItem);

          final doneTodoItem = _MockTodoItem();
          when(() => doneTodoItem.done).thenReturn(true);
          when(() => doneTodoItem.description).thenReturn("done");
          todoItems.add(doneTodoItem);

          await pumpTodoPage(tester);

          final finder = find.byType(CopyAction);
          await tester.tap(finder);

          expect(result, "[ ] not done\n[X] done");
        },
      );
    });

    group("DeleteAllAction", () {
      testWidgets(
        "given an empty todo list item, "
        "when pumped, "
        "then not expects to find delete all button",
        (tester) async {
          todoItems.clear();

          await pumpTodoPage(tester);

          final finder = find.byType(DeleteAllAction);
          expect(finder, findsNothing);
        },
      );

      testWidgets(
        "given a todo list item, "
        "when delete all button is clicked, "
        "then expects to find DeleteAllConfirmationDialog",
        (tester) async {
          todoItems.add(_MockTodoItem());
          todoItems.add(_MockTodoItem());

          await pumpTodoPage(tester);

          final finder = find.byType(DeleteAllAction);
          await tester.tap(finder);
          await tester.pumpAndSettle();

          final dialogFinder = find.byType(DeleteAllConfirmationDialog);
          expect(dialogFinder, findsOneWidget);
        },
      );

      testWidgets(
        "given a todo list item, "
        "when delete all button is clicked and then 'yes' button is clicked, "
        "then expects to find the same items on the list",
        (tester) async {
          todoItems.add(_MockTodoItem());
          todoItems.add(_MockTodoItem());
          when(
            () => localDataSource.saveTodoItems(todoItems),
          ).thenAnswer((_) async {
            return true;
          });

          await pumpTodoPage(tester);

          final finder = find.byType(DeleteAllAction);
          await tester.tap(finder);
          await tester.pumpAndSettle();

          await DeleteAllConfirmationDialogTester.callOnPressed(tester);

          expect(todoItems.isEmpty, isTrue);
        },
      );
    });

    group("ReorderableListView", () {
      setUp(() {
        when(
          () => localDataSource.saveTodoItems(todoItems),
        ).thenAnswer((_) async {
          return true;
        });
      });

      group("Reorder", () {
        testWidgets(
          "given todo item with id = 0 at first position, "
          "when first item is reordered to second item, "
          "then expects to find todo item with id = 0 at the second position",
          (tester) async {
            final todoItem0 = _MockTodoItem();
            when(() => todoItem0.id).thenReturn(0);
            todoItems.add(todoItem0);

            final todoItem1 = _MockTodoItem();
            when(() => todoItem1.id).thenReturn(1);
            todoItems.add(todoItem1);

            await pumpTodoPage(tester);

            final dragWidgetFinder0 = find.descendant(
              of: find.byKey(const Key("todo-item-0")),
              matching: TodoItemWidgetTester.getDragIconFinder(),
            );
            final dragGesture = await tester.startGesture(
              tester.getCenter(dragWidgetFinder0),
            );
            await tester.pump(kLongPressTimeout + kPressTimeout);

            final todoItemWidget1Finder = find.byKey(const Key("todo-item-1"));
            await dragGesture
                .moveTo(tester.getBottomLeft(todoItemWidget1Finder) * 2);
            await dragGesture.up();

            await tester.pumpAndSettle();

            expect(todoItems, [todoItem1, todoItem0]);
          },
        );

        testWidgets(
          "given todo item with id = 1 at second position, "
          "when second item is reordered to first item, "
          "then expects to find todo item with id = 1 at the first position",
          (tester) async {
            final todoItem0 = _MockTodoItem();
            when(() => todoItem0.id).thenReturn(0);
            todoItems.add(todoItem0);

            final todoItem1 = _MockTodoItem();
            when(() => todoItem1.id).thenReturn(1);
            todoItems.add(todoItem1);

            await pumpTodoPage(tester);

            final dragWidgetFinder1 = find.descendant(
              of: find.byKey(const Key("todo-item-1")),
              matching: TodoItemWidgetTester.getDragIconFinder(),
            );
            final dragGesture = await tester.startGesture(
              tester.getCenter(dragWidgetFinder1),
            );
            await tester.pump(kLongPressTimeout + kPressTimeout);

            final todoItemWidget0Finder = find.byKey(const Key("todo-item-0"));
            await dragGesture
                .moveTo(tester.getTopLeft(todoItemWidget0Finder) * -2);
            await dragGesture.up();

            await tester.pumpAndSettle();

            expect(todoItems, [todoItem1, todoItem0]);
          },
        );
      });

      group("Delete item", () {
        testWidgets(
          "given a todo list item, "
          "when first item is swiped to left, "
          "then not expects to find this item on the list",
          (tester) async {
            final todoItem0 = _MockTodoItem();
            when(() => todoItem0.id).thenReturn(0);
            todoItems.add(todoItem0);

            final todoItem1 = _MockTodoItem();
            todoItems.add(todoItem1);

            await pumpTodoPage(tester);

            final dragWidgetFinder0 = find.descendant(
              of: find.byKey(const Key("todo-item-0")),
              matching: TodoItemWidgetTester.getDragIconFinder(),
            );
            await tester.drag(
              dragWidgetFinder0,
              const Offset(-500, 0),
            );
            await tester.pumpAndSettle();

            expect(todoItems, [todoItem1]);
          },
        );

        testWidgets(
          "given a todo list item, "
          "when first item is swiped to left and tapped on 'undo' of Snackbar, "
          "then expects to find this item on the list yet",
          (tester) async {
            final todoItem0 = _MockTodoItem();
            when(() => todoItem0.id).thenReturn(0);
            todoItems.add(todoItem0);

            final todoItem1 = _MockTodoItem();
            todoItems.add(todoItem1);

            await pumpTodoPage(tester);

            final dragWidgetFinder0 = find.descendant(
              of: find.byKey(const Key("todo-item-0")),
              matching: TodoItemWidgetTester.getDragIconFinder(),
            );
            await tester.drag(
              dragWidgetFinder0,
              const Offset(-500, 0),
            );
            await tester.pumpAndSettle();

            await tester.tap(find.text("Undo"));

            expect(todoItems, [todoItem0, todoItem1]);
          },
        );
      });

      group("Update done", () {
        testWidgets(
          "given a todo list item with done = false, "
          "when checkbox of the item is tapped, "
          "then expects to find item with done = true",
          (tester) async {
            const todoItem0 = TodoItem(
              id: 0,
              description: "",
              done: false,
            );
            todoItems.add(todoItem0);

            await pumpTodoPage(tester);

            await TodoItemWidgetTester.tapToChangeDone(tester);

            verify(
              () => localDataSource.saveTodoItems(
                const [
                  TodoItem(
                    id: 0,
                    description: "",
                    done: true,
                  )
                ],
              ),
            ).called(1);
          },
        );

        testWidgets(
          "given a todo list item with done = true, "
          "when checkbox of the item is tapped, "
          "then expects to find item with done = false",
          (tester) async {
            const todoItem0 = TodoItem(
              id: 0,
              description: "",
              done: true,
            );
            todoItems.add(todoItem0);

            await pumpTodoPage(tester);

            await TodoItemWidgetTester.tapToChangeDone(tester);

            verify(
              () => localDataSource.saveTodoItems(
                const [
                  TodoItem(
                    id: 0,
                    description: "",
                    done: false,
                  )
                ],
              ),
            ).called(1);
          },
        );
      });

      group("Update description", () {
        testWidgets(
          "given a todo list item, "
          "when text field is editted, "
          "then expects to find item with updated description",
          (tester) async {
            const oldDescription = "mock description";
            const todoItem0 = TodoItem(
              id: 0,
              description: oldDescription,
              done: false,
            );
            todoItems.add(todoItem0);

            await pumpTodoPage(tester);

            const newDescription = "new mock description";
            await tester.enterText(
              find.descendant(
                of: find.byKey(const Key("todo-item-0")),
                matching: TodoItemWidgetTester.getDescriptionField(),
              ),
              newDescription,
            );

            verify(
              () => localDataSource.saveTodoItems(
                const [
                  TodoItem(
                    id: 0,
                    description: newDescription,
                    done: false,
                  )
                ],
              ),
            ).called(1);
          },
        );
      });
    });

    group("AddFloatingActionButton", () {
      testWidgets(
        "given a empty todo list, "
        "when floating action button is tapped, "
        "then expects to find TodoItemWidget with a new TodoItem",
        (tester) async {
          todoItems.clear();

          await pumpTodoPage(tester);

          await tester.tap(find.byType(AddFloatingActionButton));
          await tester.pumpAndSettle();

          final finder = find.byType(TodoItemWidget);
          final todoItemWidget = tester.widget(finder) as TodoItemWidget;
          expect(todoItemWidget.todoItem.id, TodoItem.newItemId);
          expect(todoItemWidget.todoItem.description, isNull);
          expect(todoItemWidget.todoItem.done, isFalse);

          await tester.pumpAndSettle();
        },
      );

      testWidgets(
        "given a empty todo list, "
        "when floating action button is tapped, "
        "then expects to find new item on todo items",
        (tester) async {
          todoItems.clear();

          await pumpTodoPage(tester);

          await tester.tap(find.byType(AddFloatingActionButton));
          await tester.pumpAndSettle();

          expect(todoItems.isNotEmpty, isTrue);
          expect(todoItems.first.id, TodoItem.newItemId);

          await tester.pumpAndSettle();
        },
      );

      testWidgets(
        "when floating action button is tapped, "
        "then not call localDataSource.saveTodoItems",
        (tester) async {
          todoItems.clear();

          await pumpTodoPage(tester);

          await tester.tap(find.byType(AddFloatingActionButton));
          await tester.pumpAndSettle();

          registerFallbackValue(_FakeTodoItem());
          verifyNever(() => localDataSource.saveTodoItems(captureAny()));

          await tester.pumpAndSettle();
        },
      );

      testWidgets(
        "given an empty todo list, "
        "when floating action button is tapped twice, "
        "then expect to find one new item on the list",
        (tester) async {
          todoItems.clear();

          await pumpTodoPage(tester);

          await tester.tap(find.byType(AddFloatingActionButton));
          await tester.tap(find.byType(AddFloatingActionButton));
          await tester.pumpAndSettle();

          expect(todoItems.length, 1);

          await tester.pumpAndSettle();
        },
      );

      testWidgets(
        "given a empty todo list, "
        "when floating action button is tapped and an text is entered to text field, "
        "then expects to find the new item with a valid id",
        (tester) async {
          when(
            () => localDataSource.saveTodoItems(captureAny()),
          ).thenAnswer((_) async => true);
          todoItems.clear();

          await pumpTodoPage(tester);

          await tester.tap(find.byType(AddFloatingActionButton));
          await tester.pumpAndSettle();

          const description = "mock description";
          await tester.enterText(
            TodoItemWidgetTester.getDescriptionField(),
            description,
          );

          verify(
            () => localDataSource.saveTodoItems(
              const [
                TodoItem(
                  id: 1,
                  description: description,
                  done: false,
                )
              ],
            ),
          ).called(1);

          await tester.pumpAndSettle();
        },
      );
    });
  });
}

class _MockLocalDataSource extends Mock implements LocalDataSource {}

class _MockTodoItem extends Mock implements TodoItem {
  _MockTodoItem() {
    when(() => id).thenReturn(Random().nextInt(10000));
    when(() => done).thenReturn(false);
    when(() => description).thenReturn("mocked description");
  }
}

class _FakeTodoItem extends Fake implements TodoItem {}
