import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/local_data_source.dart';
import 'package:todo_app/todo_item.dart';
import 'package:todo_app/todo_page.dart';

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

    group("Sort button", () {
      testWidgets(
        "given an empty todo list, "
        "when pumped,"
        " then not expects to find sort button",
        (tester) async {
          todoItems.clear();

          await pumpTodoPage(tester);

          final finder = find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.sort,
          );
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

          final finder = find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.sort,
          );
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

          final finder = find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.sort,
          );
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

          final finder = find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.sort,
          );
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

          final finder = find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.sort,
          );
          await tester.tap(finder);

          expect(todoItems, [doneTodoItem, notDoneTodoItem]);
        },
      );
    });

    group("Copy button", () {
      testWidgets(
        "given an empty todo list item, "
        "when pumped, "
        "then not expects to find copy button",
        (tester) async {
          todoItems.clear();

          await pumpTodoPage(tester);

          final finder = find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.copy,
          );
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

          final finder = find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.copy,
          );
          await tester.tap(finder);

          expect(result, "[ ] not done\n[X] done");
        },
      );
    });

    group("Delete all button", () {
      testWidgets(
        "given an empty todo list item, "
        "when pumped, "
        "then not expects to find delete all button",
        (tester) async {
          todoItems.clear();

          await pumpTodoPage(tester);

          final finder = find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.delete_forever,
          );
          expect(finder, findsNothing);
        },
      );

      testWidgets(
        "given a todo list item, "
        "when delete all button is clicked, "
        "then expects to find the confirmation dialog",
        (tester) async {
          todoItems.add(_MockTodoItem());
          todoItems.add(_MockTodoItem());

          await pumpTodoPage(tester);

          final finder = find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.delete_forever,
          );
          await tester.tap(finder);
          await tester.pumpAndSettle();

          final titleFinder = find.text("Do you want to clear all your list?");
          expect(titleFinder, findsOneWidget);

          final contentFinder = find.text(
            "Pressing 'yes', all your list will be deleted and can't be restored",
          );
          expect(contentFinder, findsOneWidget);
        },
      );

      testWidgets(
        "given a todo list item, "
        "when delete all button is clicked and then 'no' button is clicked, "
        "then expects to find the same items on the list",
        (tester) async {
          todoItems.add(_MockTodoItem());
          todoItems.add(_MockTodoItem());

          await pumpTodoPage(tester);

          final finder = find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.delete_forever,
          );
          await tester.tap(finder);
          await tester.pumpAndSettle();

          await tester.tap(find.text("No"));

          expect(todoItems.length, 2);
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

          final finder = find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.delete_forever,
          );
          await tester.tap(finder);
          await tester.pumpAndSettle();

          await tester.tap(find.text("Yes"));

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

            final dragWidgetFinder0 = find.byKey(const ValueKey("drag-icon-0"));
            final dragGesture = await tester.startGesture(
              tester.getCenter(dragWidgetFinder0),
            );
            await tester.pump(kLongPressTimeout + kPressTimeout);

            final dragWidgetFinder1 = find.byKey(const ValueKey("drag-icon-1"));
            await dragGesture
                .moveTo(tester.getBottomLeft(dragWidgetFinder1) * 2);
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

            final dragWidgetFinder1 = find.byKey(const ValueKey("drag-icon-1"));
            final dragGesture = await tester.startGesture(
              tester.getCenter(dragWidgetFinder1),
            );
            await tester.pump(kLongPressTimeout + kPressTimeout);

            final dragWidgetFinder0 = find.byKey(const ValueKey("drag-icon-0"));
            await dragGesture.moveTo(tester.getTopLeft(dragWidgetFinder0) * -2);
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

            final dragWidgetFinder0 = find.byKey(const ValueKey("drag-icon-0"));
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

            final dragWidgetFinder0 = find.byKey(const ValueKey("drag-icon-0"));
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

      group("Checkbox", () {
        testWidgets(
          "given a todo list item with done = false, "
          "when pumped, "
          "then expects to find a checkbox not checked",
          (tester) async {
            final todoItem0 = _MockTodoItem();
            when(() => todoItem0.done).thenReturn(false);
            todoItems.add(todoItem0);

            await pumpTodoPage(tester);

            final finder = find.byType(Checkbox);
            final checkbox = tester.widget(finder) as Checkbox;
            expect(checkbox.value, isFalse);
          },
        );

        testWidgets(
          "given a todo list item with done = true, "
          "when pumped, "
          "then expects to find a checked checkbox",
          (tester) async {
            final todoItem0 = _MockTodoItem();
            when(() => todoItem0.done).thenReturn(true);
            todoItems.add(todoItem0);

            await pumpTodoPage(tester);

            final finder = find.byType(Checkbox);
            final checkbox = tester.widget(finder) as Checkbox;
            expect(checkbox.value, isTrue);
          },
        );

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

            await tester.tap(find.byType(Checkbox));

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

            await tester.tap(find.byType(Checkbox));

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

      group("TextField", () {
        testWidgets(
          "given a todo list item with a description, "
          "when pumped, "
          "then expects to find a text field with that description",
          (tester) async {
            const description = "mock description";

            final todoItem0 = _MockTodoItem();
            when(() => todoItem0.description).thenReturn(description);
            todoItems.add(todoItem0);

            await pumpTodoPage(tester);

            final finder = find.byType(TextField);
            final textField = tester.widget(finder) as TextField;
            expect(textField.controller?.text, description);
          },
        );

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
              find.byType(TextField),
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

    group("FloatingActionButton", () {
      testWidgets(
        "given a empty todo list, "
        "when floating action button is tapped, "
        "then expects to find a checkbox unchecked",
        (tester) async {
          todoItems.clear();

          await pumpTodoPage(tester);

          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();

          final finder = find.byType(Checkbox);
          final checkbox = tester.widget(finder) as Checkbox;
          expect(checkbox.value, isFalse);

          await tester.pumpAndSettle();
        },
      );

      testWidgets(
        "given a empty todo list, "
        "when floating action button is tapped, "
        "then expects to find a empty text field",
        (tester) async {
          todoItems.clear();

          await pumpTodoPage(tester);

          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();

          final finder = find.byType(TextField);
          final textField = tester.widget(finder) as TextField;
          expect(textField.controller?.text, isEmpty);

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

          await tester.tap(find.byType(FloatingActionButton));
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

          await tester.tap(find.byType(FloatingActionButton));
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

          await tester.tap(find.byType(FloatingActionButton));
          await tester.tap(find.byType(FloatingActionButton));
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

          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();

          const description = "mock description";
          await tester.enterText(
            find.byType(TextField),
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
