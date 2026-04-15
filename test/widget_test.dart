import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_class/widgets/task_card_widget.dart';

void main() {
  testWidgets('TaskCardWidget shows title, subtitle, and delete button', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TaskCardWidget(
            title: 'Task 1',
            subtitle: 'This is a Firestore-backed task',
          ),
        ),
      ),
    );

    expect(find.text('Task 1'), findsOneWidget);
    expect(find.text('This is a Firestore-backed task'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });
}
