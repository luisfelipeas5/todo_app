import 'package:equatable/equatable.dart';
import 'package:todo_app/todo_item.dart';

enum TodoAction {
  none,
  newItem,
  copied,
}

class TodoState extends Equatable {
  final List<TodoItem> todoItems;
  final TodoAction lastAction;
  final String? textCopied;
  final bool showSortButton;
  final bool showDeleteAllButton;
  final bool showCopyButton;

  const TodoState({
    required this.todoItems,
    required this.lastAction,
    required this.textCopied,
    required this.showSortButton,
    required this.showDeleteAllButton,
    required this.showCopyButton,
  });

  @override
  List<Object?> get props => [
        todoItems,
        lastAction,
        textCopied,
        showSortButton,
        showDeleteAllButton,
        showCopyButton,
      ];

  TodoState copyWith({
    List<TodoItem>? todoItems,
    TodoAction? lastAction,
    String? textCopied,
    bool? showSortButton,
    bool? showDeleteAllButton,
    bool? showCopyButton,
  }) {
    return TodoState(
      todoItems: todoItems ?? this.todoItems,
      lastAction: lastAction ?? this.lastAction,
      textCopied: textCopied ?? this.textCopied,
      showSortButton: showSortButton ?? this.showSortButton,
      showDeleteAllButton: showDeleteAllButton ?? this.showDeleteAllButton,
      showCopyButton: showCopyButton ?? this.showCopyButton,
    );
  }
}
