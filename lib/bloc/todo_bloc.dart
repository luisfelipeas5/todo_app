import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/bloc/todo_event.dart';
import 'package:todo_app/bloc/todo_state.dart';
import 'package:todo_app/local_data_source.dart';
import 'package:todo_app/todo_item.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  TodoBloc(
    this._localDataSource,
  ) : super(_getInitialState(_localDataSource)) {
    on<TodoSortEvent>(_onSort);
    on<TodoDeleteAllEvent>(_onDeleteAll);
    on<TodoReorderEvent>(_onReorder);
    on<TodoDescriptionUpdateEvent>(_onDescriptionUpdate);
    on<TodoDoneUpdateEvent>(_onDoneUpdate);
    on<TodoDismissedEvent>(_onDismiss);
    on<TodoUndoDismissedEvent>(_onUndoDismiss);
    on<TodoAddItemEvent>(_onAddItem);
    on<TodoCopyEvent>(_onCopy);
  }

  final LocalDataSource _localDataSource;

  static TodoState _getInitialState(LocalDataSource localDataSource) {
    final todoItems = localDataSource.getTodoItems();
    return TodoState(
      todoItems: todoItems,
      textCopied: null,
      lastAction: TodoAction.none,
      showCopyButton: _getShowCopyButton(todoItems),
      showDeleteAllButton: _getShowDeleteAllButton(todoItems),
      showSortButton: _getShowSortButton(todoItems),
    );
  }

  FutureOr<void> _onSort(
    TodoSortEvent event,
    Emitter<TodoState> emit,
  ) async {
    final sortedList = state.todoItems.toList()
      ..sort((todoItem0, todoItem1) {
        if (todoItem0.done && !todoItem1.done) {
          return -1;
        }
        if (!todoItem0.done && todoItem1.done) {
          return 1;
        }
        return 0;
      });
    await _localDataSource.saveTodoItems(sortedList);
    emit(
      state.copyWith(
        todoItems: sortedList,
      ),
    );
  }

  FutureOr<void> _onDeleteAll(
    TodoDeleteAllEvent event,
    Emitter<TodoState> emit,
  ) {
    final clearedList = state.todoItems.toList()..clear();
    _localDataSource.saveTodoItems(clearedList);
    emit(
      state.copyWith(
        todoItems: clearedList,
        showCopyButton: _getShowCopyButton(clearedList),
        showDeleteAllButton: _getShowDeleteAllButton(clearedList),
        showSortButton: _getShowSortButton(clearedList),
      ),
    );
  }

  FutureOr<void> _onReorder(
    TodoReorderEvent event,
    Emitter<TodoState> emit,
  ) {
    final reorderList = state.todoItems.toList();

    final todoItem = reorderList[event.oldIndex];

    if (event.oldIndex > event.newIndex) {
      reorderList.insert(event.newIndex, todoItem);
      reorderList.removeAt(event.oldIndex + 1);
    } else {
      reorderList.insert(event.newIndex + 1, todoItem);
      reorderList.removeAt(event.oldIndex);
    }
    _localDataSource.saveTodoItems(reorderList);

    emit(
      state.copyWith(
        todoItems: reorderList,
      ),
    );
  }

  FutureOr<void> _onDescriptionUpdate(
    TodoDescriptionUpdateEvent event,
    Emitter<TodoState> emit,
  ) {
    final newItem = event.todoItem.id == TodoItem.newItemId;

    final updatedList = state.todoItems.toList();
    updatedList[event.index] = event.todoItem.copyWith(
      id: newItem ? updatedList.length - 1 : null,
      description: event.newDescription,
    );
    _localDataSource.saveTodoItems(updatedList);

    emit(state.copyWith(
      todoItems: updatedList,
    ));
  }

  FutureOr<void> _onDoneUpdate(
    TodoDoneUpdateEvent event,
    Emitter<TodoState> emit,
  ) {
    final updatedList = state.todoItems.toList();
    updatedList[event.index] = event.todoItem.copyWith(
      done: event.newDoneValue,
    );
    if (event.todoItem.id != TodoItem.newItemId) {
      _localDataSource.saveTodoItems(updatedList);
    }
    emit(state.copyWith(
      todoItems: updatedList,
      showSortButton: _getShowSortButton(updatedList),
    ));
  }

  FutureOr<void> _onDismiss(
    TodoDismissedEvent event,
    Emitter<TodoState> emit,
  ) {
    final updatedList = state.todoItems.toList();
    updatedList.removeAt(event.index);

    _localDataSource.saveTodoItems(updatedList);

    emit(state.copyWith(
      todoItems: updatedList,
      showCopyButton: _getShowCopyButton(updatedList),
      showDeleteAllButton: _getShowDeleteAllButton(updatedList),
      showSortButton: _getShowSortButton(updatedList),
    ));
  }

  FutureOr<void> _onUndoDismiss(
    TodoUndoDismissedEvent event,
    Emitter<TodoState> emit,
  ) {
    final updatedList = state.todoItems.toList();
    updatedList.insert(event.index, event.todoItem);

    _localDataSource.saveTodoItems(updatedList);

    emit(state.copyWith(
      todoItems: updatedList,
      showCopyButton: _getShowCopyButton(updatedList),
      showDeleteAllButton: _getShowDeleteAllButton(updatedList),
      showSortButton: _getShowSortButton(updatedList),
    ));
  }

  FutureOr<void> _onAddItem(
    TodoAddItemEvent event,
    Emitter<TodoState> emit,
  ) {
    final updatedList = state.todoItems.toList();
    if (updatedList.isEmpty || updatedList.last.id != TodoItem.newItemId) {
      updatedList.add(TodoItem.newItem());
      emit(state.copyWith(
        todoItems: updatedList,
        lastAction: TodoAction.newItem,
        showCopyButton: _getShowCopyButton(updatedList),
        showDeleteAllButton: _getShowDeleteAllButton(updatedList),
        showSortButton: _getShowSortButton(updatedList),
      ));
    }
  }

  FutureOr<void> _onCopy(
    TodoCopyEvent event,
    Emitter<TodoState> emit,
  ) {
    final todoItemsAsString = state.todoItems.map(
      (e) {
        if (e.done) {
          return "[X] ${e.description}";
        }
        return "[ ] ${e.description}";
      },
    ).join("\n");
    emit(state.copyWith(
      textCopied: todoItemsAsString,
      lastAction: TodoAction.copied,
    ));
  }

  static bool _getShowCopyButton(List<TodoItem> todoItems) {
    return todoItems.isNotEmpty;
  }

  static bool _getShowDeleteAllButton(List<TodoItem> todoItems) {
    return todoItems.isNotEmpty;
  }

  static bool _getShowSortButton(List<TodoItem> todoItems) {
    return todoItems.any((element) => element.done);
  }
}
