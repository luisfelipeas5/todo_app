import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TodoItemWidgetTester {
  static Finder getDragIconFinder() {
    return find.byWidgetPredicate(
      (widget) => widget is Icon && widget.icon == Icons.menu,
    );
  }

  static Future<void> tapToChangeDone(WidgetTester tester) {
    return tester.tap(find.byType(Checkbox));
  }

  static Finder getDescriptionField() {
    return find.byType(TextField);
  }
}
