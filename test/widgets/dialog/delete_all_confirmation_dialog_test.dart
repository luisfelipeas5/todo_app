import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/widgets/dialog/delete_all_confirmation_dialog.dart';

void main() {
  Future<void> pumpDialog(
    WidgetTester tester, {
    VoidCallback? onConfirmPressed,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: DeleteAllConfirmationDialog(
          onConfirmPressed: onConfirmPressed ?? () {},
        ),
      ),
    );
  }

  group("DeleteAllConfirmationDialog", () {
    testWidgets(
      "when pumped, "
      "then expects to find title",
      (tester) async {
        await pumpDialog(tester);

        final titleFinder = find.text("Do you want to clear all your list?");
        expect(titleFinder, findsOneWidget);
      },
    );

    testWidgets(
      "when pumped, "
      "then expects to find description",
      (tester) async {
        await pumpDialog(tester);

        final contentFinder = find.text(
          "Pressing 'yes', all your list will be deleted and can't be restored",
        );
        expect(contentFinder, findsOneWidget);
      },
    );

    testWidgets(
      "when 'no' button is clicked, "
      "then not expects to call onConfirmPressed callback",
      (tester) async {
        final completer = Completer();
        final onConfirmPressed = completer.complete;

        await pumpDialog(
          tester,
          onConfirmPressed: onConfirmPressed,
        );

        await tester.tap(find.text('No'));

        expect(completer.isCompleted, isFalse);
      },
    );

    testWidgets(
      "when 'Yes' button is clicked, "
      "then expects to call onConfirmPressed callback",
      (tester) async {
        final completer = Completer();
        final onConfirmPressed = completer.complete;

        await pumpDialog(
          tester,
          onConfirmPressed: onConfirmPressed,
        );

        await tester.tap(find.text('Yes'));

        expect(completer.isCompleted, isTrue);
      },
    );
  });
}
