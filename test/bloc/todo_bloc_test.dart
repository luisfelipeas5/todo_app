import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/bloc/todo_bloc.dart';
import 'package:todo_app/bloc/todo_event.dart';
import 'package:todo_app/bloc/todo_state.dart';
import 'package:todo_app/local_data_source.dart';
import 'package:todo_app/todo_item.dart';

void main() {
  late TodoBloc bloc;

  late LocalDataSource localDataSource;
  late List<TodoItem> todoItems;

  group("TodoBloc", () {
    setUp(() {
      todoItems = List.empty(growable: true);

      localDataSource = _MockLocalDataSource();
      when(localDataSource.getTodoItems).thenReturn(todoItems);
      when(() => localDataSource.saveTodoItems(todoItems))
          .thenAnswer((_) async => true);

      bloc = TodoBloc(localDataSource);
    });

    group("TodoSortEvent", () {
      late TodoItem doneTodoItem;
      late TodoItem undoneTodoItem;

      setUp(() {
        doneTodoItem = _MockTodoItem();
        when(() => doneTodoItem.done).thenReturn(true);

        undoneTodoItem = _MockTodoItem();
        when(() => undoneTodoItem.done).thenReturn(false);

        when(
          () => localDataSource.saveTodoItems([
            doneTodoItem,
            undoneTodoItem,
          ]),
        ).thenAnswer((_) async => true);
      });

      blocTest(
        "given a todo list with one undone item at first and a done item at second, "
        "when TodoSortEvent is added, "
        "then expects to emit a TodoState done item at first on list",
        build: () => bloc,
        setUp: () {
          todoItems.add(undoneTodoItem);
          todoItems.add(doneTodoItem);
        },
        act: (bloc) => bloc.add(TodoSortEvent()),
        expect: () => [
          TodoState(
            todoItems: [
              doneTodoItem,
              undoneTodoItem,
            ],
            lastAction: TodoAction.none,
            textCopied: null,
            showSortButton: false,
            showDeleteAllButton: false,
            showCopyButton: false,
          ),
        ],
      );

      blocTest(
        "given a todo list with one done item at first and a undone item at second, "
        "when TodoSortEvent is added, "
        "then expects to emit a TodoState done item at first on list",
        build: () => bloc,
        setUp: () {
          todoItems.add(doneTodoItem);
          todoItems.add(undoneTodoItem);
        },
        act: (bloc) => bloc.add(TodoSortEvent()),
        expect: () => [
          TodoState(
            todoItems: [
              doneTodoItem,
              undoneTodoItem,
            ],
            lastAction: TodoAction.none,
            textCopied: null,
            showSortButton: false,
            showDeleteAllButton: false,
            showCopyButton: false,
          ),
        ],
      );

      blocTest(
        "given a todo list with one undone item at first and a done item at second, "
        "when TodoSortEvent is added, "
        "then expects to call localDataSource.saveTodoList()",
        build: () => bloc,
        setUp: () {
          todoItems.add(undoneTodoItem);
          todoItems.add(doneTodoItem);
        },
        act: (bloc) => bloc.add(TodoSortEvent()),
        verify: (_) {
          verify(
            () => localDataSource.saveTodoItems([doneTodoItem, undoneTodoItem]),
          ).called(1);
        },
      );
    });

    group("TodoDeleteAllEvent", () {
      setUp(() {
        todoItems.add(_MockTodoItem());

        when(
          () => localDataSource.saveTodoItems([]),
        ).thenAnswer((invocation) async => true);
      });

      blocTest(
        "when TodoDeleteAllEvent is added, "
        "then expects to emit TodoState with an empty todo list",
        build: () => bloc,
        act: (bloc) => bloc.add(TodoDeleteAllEvent()),
        expect: () => [
          const TodoState(
            todoItems: [],
            lastAction: TodoAction.none,
            textCopied: null,
            showSortButton: false,
            showDeleteAllButton: false,
            showCopyButton: false,
          ),
        ],
      );

      blocTest(
        "when TodoDeleteAllEvent is added, "
        "then expects to call localDataSource.saveTodoList() passing a empty list",
        build: () => bloc,
        act: (bloc) => bloc.add(TodoDeleteAllEvent()),
        verify: (_) {
          verify(
            () => localDataSource.saveTodoItems([]),
          ).called(1);
        },
      );
    });

    group("TodoReorderEvent", () {
      late TodoItem todoItem0;
      late TodoItem todoItem1;
      late TodoItem todoItem2;

      setUp(() {
        todoItem0 = _MockTodoItem();
        when(() => todoItem0.id).thenReturn(0);
        todoItems.add(todoItem0);

        todoItem1 = _MockTodoItem();
        when(() => todoItem1.id).thenReturn(1);
        todoItems.add(todoItem1);

        todoItem2 = _MockTodoItem();
        when(() => todoItem2.id).thenReturn(2);
        todoItems.add(todoItem2);
      });

      blocTest(
        "given a todo list, "
        "when TodoReorderEvent is added with oldIndex smaller than newIndex, "
        "then expects to emit a TodoState with reordered items",
        build: () => bloc,
        setUp: () {
          when(
            () => localDataSource.saveTodoItems([
              todoItem1,
              todoItem2,
              todoItem0,
            ]),
          ).thenAnswer((invocation) async => true);
        },
        act: (bloc) => bloc.add(TodoReorderEvent(
          oldIndex: 0,
          newIndex: 2,
        )),
        expect: () => [
          TodoState(
            todoItems: [
              todoItem1,
              todoItem2,
              todoItem0,
            ],
            lastAction: TodoAction.none,
            textCopied: null,
            showSortButton: false,
            showDeleteAllButton: false,
            showCopyButton: false,
          ),
        ],
      );

      blocTest(
        "given a todo list, "
        "when TodoReorderEvent is added with newIndex smaller than oldIndex, "
        "then expects to emit a TodoState with reordered items",
        build: () => bloc,
        setUp: () {
          when(
            () => localDataSource.saveTodoItems([
              todoItem2,
              todoItem0,
              todoItem1,
            ]),
          ).thenAnswer((invocation) async => true);
        },
        act: (bloc) => bloc.add(TodoReorderEvent(
          oldIndex: 2,
          newIndex: 0,
        )),
        expect: () => [
          TodoState(
            todoItems: [
              todoItem2,
              todoItem0,
              todoItem1,
            ],
            lastAction: TodoAction.none,
            textCopied: null,
            showSortButton: false,
            showDeleteAllButton: false,
            showCopyButton: false,
          ),
        ],
      );
    });

    group("TodoDescriptionUpdateEvent", () {
      late TodoItem todoItem;

      setUp(() {
        todoItem = const TodoItem(
          id: 0,
          done: false,
          description: "description",
        );
        todoItems.add(todoItem);
      });

      blocTest(
        "given a todo item, "
        "when TodoDescriptionUpdateEvent is added, "
        "then expects to emit TodoState with item with updated description",
        build: () => bloc,
        setUp: () {
          when(
            () => localDataSource.saveTodoItems(
              const [
                TodoItem(
                  id: 0,
                  description: "new description",
                  done: false,
                )
              ],
            ),
          ).thenAnswer((invocation) async => true);
        },
        act: (bloc) => bloc.add(
          TodoDescriptionUpdateEvent(
            todoItem: todoItem,
            index: 0,
            newDescription: "new description",
          ),
        ),
        expect: () => const [
          TodoState(
            todoItems: [
              TodoItem(
                id: 0,
                description: "new description",
                done: false,
              ),
            ],
            lastAction: TodoAction.none,
            textCopied: null,
            showSortButton: false,
            showDeleteAllButton: false,
            showCopyButton: false,
          ),
        ],
      );

      blocTest(
        "given a todo item with new item id, "
        "when TodoDescriptionUpdateEvent is added, "
        "then expects to emit TodoState with item with updated description"
        " and a new id",
        build: () => bloc,
        setUp: () {
          todoItem = const TodoItem(
            id: TodoItem.newItemId,
            description: "new item description",
            done: true,
          );
          todoItems.add(todoItem);

          when(
            () => localDataSource.saveTodoItems(
              const [
                TodoItem(
                  id: 0,
                  description: "description",
                  done: false,
                ),
                TodoItem(
                  id: 1,
                  description: "new description",
                  done: true,
                ),
              ],
            ),
          ).thenAnswer((invocation) async => true);
        },
        act: (bloc) => bloc.add(
          TodoDescriptionUpdateEvent(
            todoItem: todoItems[1],
            index: 1,
            newDescription: "new description",
          ),
        ),
        expect: () => const [
          TodoState(
            todoItems: [
              TodoItem(
                id: 0,
                description: "description",
                done: false,
              ),
              TodoItem(
                id: 1,
                description: "new description",
                done: true,
              ),
            ],
            lastAction: TodoAction.none,
            textCopied: null,
            showSortButton: false,
            showDeleteAllButton: false,
            showCopyButton: false,
          ),
        ],
      );

      blocTest(
        "given a todo item, "
        "when TodoDescriptionUpdateEvent is added, "
        "then expects to verify localDataSource.saveTodoItems with item with updated description",
        build: () => bloc,
        setUp: () {
          when(
            () => localDataSource.saveTodoItems(
              const [
                TodoItem(
                  id: 0,
                  description: "new description",
                  done: false,
                )
              ],
            ),
          ).thenAnswer((invocation) async => true);
        },
        act: (bloc) => bloc.add(
          TodoDescriptionUpdateEvent(
            todoItem: todoItem,
            index: 0,
            newDescription: "new description",
          ),
        ),
        verify: (bloc) {
          verify(
            () => localDataSource.saveTodoItems(
              const [
                TodoItem(
                  id: 0,
                  description: "new description",
                  done: false,
                )
              ],
            ),
          ).called(1);
        },
      );
    });

    group("TodoDoneUpdateEvent", () {
      late TodoItem todoItem;

      setUp(() {
        todoItem = const TodoItem(
          id: 0,
          description: "description",
          done: false,
        );
        todoItems.add(todoItem);
      });

      blocTest(
        "given a todo item with done = false, "
        "when TodoDoneUpdateEvent is added, "
        "then expects to emit TodoState with item with done = true",
        build: () => bloc,
        setUp: () {
          when(
            () => localDataSource.saveTodoItems(
              [
                todoItem.copyWith(
                  done: true,
                )
              ],
            ),
          ).thenAnswer((invocation) async => true);
        },
        act: (bloc) => bloc.add(
          TodoDoneUpdateEvent(
            todoItem: todoItem,
            index: 0,
            newDoneValue: true,
          ),
        ),
        expect: () => [
          TodoState(
            todoItems: [
              todoItem.copyWith(
                done: true,
              ),
            ],
            lastAction: TodoAction.none,
            textCopied: null,
            showSortButton: true,
            showDeleteAllButton: false,
            showCopyButton: false,
          ),
        ],
      );

      blocTest(
        "given a todo item with done = true, "
        "when TodoDoneUpdateEvent is added, "
        "then expects to emit TodoState with item with done = false",
        build: () => bloc,
        setUp: () {
          todoItem = const TodoItem(
            id: TodoItem.newItemId,
            description: "description",
            done: true,
          );
          todoItems.add(todoItem);

          when(
            () => localDataSource.saveTodoItems(
              [
                todoItem.copyWith(
                  done: false,
                )
              ],
            ),
          ).thenAnswer((invocation) async => true);
        },
        act: (bloc) => bloc.add(
          TodoDoneUpdateEvent(
            todoItem: todoItem,
            index: 1,
            newDoneValue: false,
          ),
        ),
        expect: () => const [
          TodoState(
            todoItems: [
              TodoItem(
                id: 0,
                description: "description",
                done: false,
              ),
              TodoItem(
                id: TodoItem.newItemId,
                description: "description",
                done: false,
              ),
            ],
            lastAction: TodoAction.none,
            textCopied: null,
            showSortButton: false,
            showDeleteAllButton: false,
            showCopyButton: false,
          ),
        ],
      );

      blocTest(
        "given a todo item, "
        "when TodoDoneUpdateEvent is added, "
        "then expects to verify localDataSource.saveTodoItems with item with updated done",
        build: () => bloc,
        setUp: () {
          when(
            () => localDataSource.saveTodoItems(
              const [
                TodoItem(
                  id: 0,
                  description: "description",
                  done: true,
                )
              ],
            ),
          ).thenAnswer((invocation) async => true);
        },
        act: (bloc) => bloc.add(
          TodoDoneUpdateEvent(
            todoItem: todoItem,
            index: 0,
            newDoneValue: true,
          ),
        ),
        verify: (bloc) {
          verify(
            () => localDataSource.saveTodoItems(
              const [
                TodoItem(
                  id: 0,
                  description: "description",
                  done: true,
                )
              ],
            ),
          ).called(1);
        },
      );

      blocTest(
        "given a todo item with new item id, "
        "when TodoDoneUpdateEvent is added, "
        "then not expects to verify localDataSource.saveTodoItems with item with updated done",
        build: () => bloc,
        setUp: () {
          todoItem = const TodoItem(
            id: TodoItem.newItemId,
            description: "description",
            done: true,
          );
          todoItems.add(todoItem);
        },
        act: (bloc) => bloc.add(
          TodoDoneUpdateEvent(
            todoItem: todoItems[1],
            index: 1,
            newDoneValue: false,
          ),
        ),
        verify: (bloc) {
          registerFallbackValue(_MockTodoItem());
          verifyNever(
            () => localDataSource.saveTodoItems(captureAny()),
          );
        },
      );
    });

    group("TodoDismissedEvent", () {
      late TodoItem todoItem;

      setUp(() {
        todoItem = _MockTodoItem();
        when(() => todoItem.done).thenReturn(false);
        todoItems.add(todoItem);
      });

      blocTest(
        "when TodoDismissedEvent is added, "
        "then expect to emit TodoState without item removed",
        setUp: () {
          when(
            () => localDataSource.saveTodoItems([]),
          ).thenAnswer((invocation) async => true);
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          TodoDismissedEvent(
            todoItem: todoItem,
            index: 0,
          ),
        ),
        expect: () => const [
          TodoState(
            todoItems: [],
            lastAction: TodoAction.none,
            textCopied: null,
            showSortButton: false,
            showDeleteAllButton: false,
            showCopyButton: false,
          ),
        ],
      );

      blocTest(
        "when TodoDismissedEvent is added, "
        "then expect to verify localDataSource.saveTodoItems with "
        "the list without deleted item",
        setUp: () {
          final todoItem0 = _MockTodoItem();
          when(() => todoItem0.done).thenReturn(false);
          todoItems.add(todoItem0);

          when(
            () => localDataSource.saveTodoItems([todoItem]),
          ).thenAnswer((invocation) async => true);
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          TodoDismissedEvent(
            todoItem: todoItems[1],
            index: 1,
          ),
        ),
        verify: (bloc) {
          verify(
            () => localDataSource.saveTodoItems([todoItem]),
          ).called(1);
        },
      );
    });

    group("TodoUndoDismissedEvent", () {
      late TodoItem todoItem;

      setUp(() {
        todoItem = _MockTodoItem();
        when(() => todoItem.done).thenReturn(false);
      });

      blocTest(
        "when TodoUndoDismissedEvent is added, "
        "then expects to emit TodoState with the item re-inserted",
        build: () => bloc,
        setUp: () {
          when(
            () => localDataSource.saveTodoItems([todoItem]),
          ).thenAnswer((invocation) async => true);
        },
        act: (bloc) => bloc.add(
          TodoUndoDismissedEvent(
            todoItem: todoItem,
            index: 0,
          ),
        ),
        expect: () => [
          TodoState(
            todoItems: [todoItem],
            lastAction: TodoAction.none,
            textCopied: null,
            showSortButton: false,
            showDeleteAllButton: true,
            showCopyButton: true,
          ),
        ],
      );
    });

    group("TodoAddItemEvent", () {
      late TodoItem todoItem;

      setUp(() {
        todoItem = _MockTodoItem();
        when(() => todoItem.id).thenReturn(0);
        when(() => todoItem.done).thenReturn(false);
      });

      blocTest(
        "given a empty todo list, "
        "when TodoAddItemEvent is added, "
        "then expects to emit TodoState with the new item",
        build: () => bloc,
        setUp: () {
          todoItems.clear();
        },
        act: (bloc) => bloc.add(TodoAddItemEvent()),
        expect: () => const [
          TodoState(
            todoItems: [
              TodoItem(
                id: TodoItem.newItemId,
                description: null,
                done: false,
              ),
            ],
            lastAction: TodoAction.newItem,
            textCopied: null,
            showSortButton: false,
            showDeleteAllButton: true,
            showCopyButton: true,
          ),
        ],
      );

      blocTest(
        "given a not empty todo list, "
        "when TodoAddItemEvent is added, "
        "then expects to emit TodoState with the new item",
        build: () => bloc,
        setUp: () {
          todoItems.add(todoItem);
        },
        act: (bloc) => bloc.add(TodoAddItemEvent()),
        expect: () => [
          TodoState(
            todoItems: [
              todoItem,
              const TodoItem(
                id: TodoItem.newItemId,
                description: null,
                done: false,
              ),
            ],
            lastAction: TodoAction.newItem,
            textCopied: null,
            showSortButton: false,
            showDeleteAllButton: true,
            showCopyButton: true,
          ),
        ],
      );

      blocTest(
        "given a empty todo list, "
        "when TodoAddItemEvent is added, "
        "then not expects to verify localDataSource.saveTodoItems",
        build: () => bloc,
        setUp: () {
          todoItems.clear();
        },
        act: (bloc) => bloc.add(TodoAddItemEvent()),
        verify: (bloc) {
          registerFallbackValue(_FakeTodoItem());
          verifyNever(
            () => localDataSource.saveTodoItems(captureAny()),
          );
        },
      );
    });

    group("TodoCopyEvent", () {
      setUp(() {
        const todoItem0 = TodoItem(
          id: 0,
          description: "description 0",
          done: false,
        );
        todoItems.add(todoItem0);

        const todoItem1 = TodoItem(
          id: 1,
          description: "description 1",
          done: true,
        );
        todoItems.add(todoItem1);
      });

      blocTest(
        "when TodoCopyEvent is added, "
        "then expects to emit TodoState with text to copy",
        build: () => bloc,
        act: (bloc) => bloc.add(TodoCopyEvent()),
        expect: () => [
          TodoState(
            todoItems: todoItems,
            lastAction: TodoAction.copied,
            textCopied: "[ ] description 0\n[X] description 1",
            showSortButton: false,
            showDeleteAllButton: false,
            showCopyButton: false,
          ),
        ],
      );
    });
  });
}

class _MockLocalDataSource extends Mock implements LocalDataSource {}

class _MockTodoItem extends Mock implements TodoItem {}

class _FakeTodoItem extends Fake implements TodoItem {}
