import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TodoItemWidgetTester {
  static Finder getDragIconFinder() {
    return find.byWidgetPredicate(
      (widget) => widget is Icon && widget.icon == Icons.menu,
    );
  }

  static Future<void> callOnCheckboxChanged(WidgetTester tester) {
    return tester.tap(find.byType(Checkbox));
  }

  static Future<void> callOnTextFieldChanged(
    WidgetTester tester,
    String description,
  ) {
    return tester.enterText(
      find.byType(TextField),
      description,
    );
  }

  static Future<void> callOnDismissed(WidgetTester tester) async {
    final dragIconFinder = find.byWidgetPredicate(
      (widget) => widget is Icon && widget.icon == Icons.menu,
    );
    await tester.drag(
      dragIconFinder,
      const Offset(-1000, 0),
    );
    await tester.pumpAndSettle();
  }
}
