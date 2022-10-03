import 'package:equatable/equatable.dart';

class TodoItem extends Equatable {
  static const int newItemId = -1;

  final int id;
  final String? description;
  final bool done;

  const TodoItem({
    required this.id,
    required this.description,
    required this.done,
  });

  factory TodoItem.newItem() {
    return const TodoItem(
      id: newItemId,
      description: null,
      done: false,
    );
  }

  TodoItem copyWith({
    int? id,
    String? description,
    bool? done,
  }) {
    return TodoItem(
      id: id ?? this.id,
      description: description ?? this.description,
      done: done ?? this.done,
    );
  }

  factory TodoItem.fromJson(Map<String, dynamic> data) {
    return TodoItem(
      id: data["id"] as int,
      description: data["description"] as String?,
      done: data["done"] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "description": description,
      "done": done,
    };
  }

  @override
  List<Object?> get props => [
        id,
        description,
        done,
      ];
}
