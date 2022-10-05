import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/bloc/todo_bloc.dart';
import 'package:todo_app/bloc/todo_event.dart';
import 'package:todo_app/bloc/todo_state.dart';
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
  late TodoBloc todoBloc;
  late TodoState initialTodoState;

  Future<void> pumpTodoPage(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: BlocProvider.value(
          value: todoBloc,
          child: const TodoPage(),
        ),
      ),
    );
  }

  group("TodoPage", () {
    setUp(() {
      todoItems = List.empty(growable: true);

      localDataSource = _MockLocalDataSource();
      when(localDataSource.getTodoItems).thenReturn(todoItems);

      todoBloc = _MockTodoBloc();
      initialTodoState = _MockTodoState();
      when(() => initialTodoState.todoItems).thenReturn(todoItems);
      whenListen(
        todoBloc,
        const Stream<TodoState>.empty(),
        initialState: initialTodoState,
      );
    });

    group("SortAction", () {
      testWidgets(
        "given todoState with showSortButton = false, "
        "when pumped, "
        "then not expects to find sort button",
        (tester) async {
          when(() => initialTodoState.showSortButton).thenReturn(false);

          await pumpTodoPage(tester);

          final finder = find.byType(SortAction);
          expect(finder, findsNothing);
        },
      );

      testWidgets(
        "given todoState with showSortButton = true, "
        "when pumped, "
        "then expects to find sort button",
        (tester) async {
          when(() => initialTodoState.showSortButton).thenReturn(true);

          await pumpTodoPage(tester);

          final finder = find.byType(SortAction);
          expect(finder, findsOneWidget);
        },
      );

      testWidgets(
        "given todoState with showSortButton = true, "
        "when sort action is tapped, "
        "then expects to add TodoSortEvent to TodoBloc",
        (tester) async {
          when(() => initialTodoState.showSortButton).thenReturn(true);

          await pumpTodoPage(tester);

          final finder = find.byType(SortAction);
          await tester.tap(finder);

          verify(
            () => todoBloc.add(TodoSortEvent()),
          ).called(1);
        },
      );
    });

    group("CopyAction", () {
      testWidgets(
        "given todoState with showCopyButton = false, "
        "when pumped, "
        "then not expects to find CopyAction",
        (tester) async {
          when(() => initialTodoState.showCopyButton).thenReturn(false);

          await pumpTodoPage(tester);

          final finder = find.byType(CopyAction);
          expect(finder, findsNothing);
        },
      );

      testWidgets(
        "given todoState with showCopyButton = true, "
        "when pumped, "
        "then expects to find CopyAction",
        (tester) async {
          when(() => initialTodoState.showCopyButton).thenReturn(true);

          await pumpTodoPage(tester);

          final finder = find.byType(CopyAction);
          expect(finder, findsOneWidget);
        },
      );

      testWidgets(
        "given todoState with showCopyButton = true, "
        "when CopyAction is tapped, "
        "then expects to add TodoCopyEvent to TodoBloc",
        (tester) async {
          when(() => initialTodoState.showCopyButton).thenReturn(true);

          await pumpTodoPage(tester);

          final finder = find.byType(CopyAction);
          await tester.tap(finder);

          verify(
            () => todoBloc.add(TodoCopyEvent()),
          ).called(1);
        },
      );
    });

    group("DeleteAllAction", () {
      testWidgets(
        "given todoState with showDeleteAllButton = false, "
        "when pumped, "
        "then not expects to find DeleteAllAction",
        (tester) async {
          when(() => initialTodoState.showDeleteAllButton).thenReturn(false);

          await pumpTodoPage(tester);

          final finder = find.byType(DeleteAllAction);
          expect(finder, findsNothing);
        },
      );

      testWidgets(
        "given todoState with showDeleteAllButton = true, "
        "when pumped, "
        "then expects to find DeleteAllAction",
        (tester) async {
          when(() => initialTodoState.showDeleteAllButton).thenReturn(true);

          await pumpTodoPage(tester);

          final finder = find.byType(DeleteAllAction);
          expect(finder, findsOneWidget);
        },
      );

      testWidgets(
        "given todoState with showDeleteAllButton = true, "
        "when delete all button is clicked, "
        "then expects to find DeleteAllConfirmationDialog",
        (tester) async {
          when(() => initialTodoState.showDeleteAllButton).thenReturn(true);

          await pumpTodoPage(tester);

          final finder = find.byType(DeleteAllAction);
          await tester.tap(finder);
          await tester.pumpAndSettle();

          final dialogFinder = find.byType(DeleteAllConfirmationDialog);
          expect(dialogFinder, findsOneWidget);
        },
      );

      testWidgets(
        "given todoState with showDeleteAllButton = true, "
        "when delete all button is clicked and then 'yes' button is clicked, "
        "then expects to add TodoDeleteAllEvent to TodoBloc",
        (tester) async {
          when(() => initialTodoState.showDeleteAllButton).thenReturn(true);

          await pumpTodoPage(tester);

          final finder = find.byType(DeleteAllAction);
          await tester.tap(finder);
          await tester.pumpAndSettle();

          await DeleteAllConfirmationDialogTester.callOnPressed(tester);

          verify(
            () => todoBloc.add(TodoDeleteAllEvent()),
          ).called(1);
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
          "then expects to add TodoReorderEvent to TodoBloc",
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
                .moveTo(tester.getBottomLeft(todoItemWidget1Finder));
            await dragGesture.up();

            await tester.pumpAndSettle();

            verify(
              () => todoBloc.add(TodoReorderEvent(oldIndex: 0, newIndex: 1)),
            ).called(1);
          },
        );

        testWidgets(
          "given todo item with id = 1 at second position, "
          "when second item is reordered to first item, "
          "then expects to add TodoReorderEvent to TodoBloc",
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
                .moveTo(tester.getTopLeft(todoItemWidget0Finder) * -1);
            await dragGesture.up();

            await tester.pumpAndSettle();

            verify(
              () => todoBloc.add(TodoReorderEvent(oldIndex: 1, newIndex: 0)),
            ).called(1);
          },
        );
      });
    });

    group("AddFloatingActionButton", () {
      testWidgets(
        "when floating action button is tapped, "
        "then expects to add TodoAddItemEvent to TodoBloc",
        (tester) async {
          todoItems.clear();

          await pumpTodoPage(tester);

          await tester.tap(find.byType(AddFloatingActionButton));
          await tester.pumpAndSettle();

          verify(
            () => todoBloc.add(TodoAddItemEvent()),
          ).called(1);
        },
      );
    });

    group("BlocListener", () {
      late TodoState newStateEmitted;

      setUp(() {
        newStateEmitted = _MockTodoState();
        when(() => newStateEmitted.lastAction).thenReturn(TodoAction.copied);
        when(() => newStateEmitted.todoItems).thenReturn(todoItems);

        whenListen(
          todoBloc,
          Stream<TodoState>.value(newStateEmitted),
          initialState: initialTodoState,
        );
      });

      testWidgets(
        "when TodoBloc emits a TodoState with lastAction == TodoAction.copied, "
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

          when(() => newStateEmitted.lastAction).thenReturn(TodoAction.copied);
          const textCopied = "text copied";
          when(() => newStateEmitted.textCopied).thenReturn(textCopied);

          await pumpTodoPage(tester);

          await tester.pump();

          expect(result, textCopied);
        },
      );

      testWidgets(
        "when TodoBloc emits a TodoState with lastAction == TodoAction.newItem, "
        "then expects to find focusNode of the last TodoItemWidget with focus",
        (tester) async {
          final fakeAsync = FakeAsync();
          fakeAsync.run((async) async {
            todoItems.add(_MockTodoItem());
            when(() => newStateEmitted.lastAction)
                .thenReturn(TodoAction.newItem);

            await pumpTodoPage(tester);

            await tester.pump();
            async.elapse(const Duration(milliseconds: 500));

            final lastTodoItemWidget = tester
                .widgetList(
                  find.byType(TodoItemWidget),
                )
                .last as TodoItemWidget;
            expect(lastTodoItemWidget.focusNode?.hasFocus, isTrue);
          });
          fakeAsync.flushMicrotasks();
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

class _MockTodoBloc extends Mock implements TodoBloc {}

class _MockTodoState extends Mock implements TodoState {
  _MockTodoState() {
    when(() => showDeleteAllButton).thenReturn(false);
    when(() => showSortButton).thenReturn(false);
    when(() => showCopyButton).thenReturn(false);
  }
}
