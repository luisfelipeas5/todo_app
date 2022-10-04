import 'package:flutter_test/flutter_test.dart';

class DeleteAllConfirmationDialogTester {
  static Future<void> callOnPressed(WidgetTester tester) {
    return tester.tap(find.text("Yes"));
  }
}
