import 'package:equatable/equatable.dart';
import 'package:todo_app/todo_item.dart';

abstract class TodoEvent extends Equatable {}

class TodoSortEvent extends TodoEvent {
  @override
  List<Object?> get props => [];
}

class TodoDeleteAllEvent extends TodoEvent {
  @override
  List<Object?> get props => [];
}

class TodoReorderEvent extends TodoEvent {
  final int oldIndex;
  final int newIndex;

  TodoReorderEvent({
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  List<Object?> get props => [
        oldIndex,
        newIndex,
      ];
}

class TodoDescriptionUpdateEvent extends TodoEvent {
  final TodoItem todoItem;
  final int index;
  final String newDescription;

  TodoDescriptionUpdateEvent({
    required this.todoItem,
    required this.index,
    required this.newDescription,
  });

  @override
  List<Object?> get props => [
        todoItem,
        index,
        newDescription,
      ];
}

class TodoDoneUpdateEvent extends TodoEvent {
  final TodoItem todoItem;
  final int index;
  final bool newDoneValue;

  TodoDoneUpdateEvent({
    required this.todoItem,
    required this.index,
    required this.newDoneValue,
  });

  @override
  List<Object?> get props => [
        todoItem,
        index,
        newDoneValue,
      ];
}

class TodoDismissedEvent extends TodoEvent {
  final TodoItem todoItem;
  final int index;

  TodoDismissedEvent({
    required this.todoItem,
    required this.index,
  });

  @override
  List<Object?> get props => [
        todoItem,
        index,
      ];
}

class TodoUndoDismissedEvent extends TodoEvent {
  final TodoItem todoItem;
  final int index;

  TodoUndoDismissedEvent({
    required this.todoItem,
    required this.index,
  });

  @override
  List<Object?> get props => [
        todoItem,
        index,
      ];
}

class TodoAddItemEvent extends TodoEvent {
  @override
  List<Object?> get props => [];
}

class TodoCopyEvent extends TodoEvent {
  @override
  List<Object?> get props => [];
}
