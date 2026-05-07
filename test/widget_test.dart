import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcmus_seminar/app.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DrawingApp());
    expect(find.text('Drawing App'), findsWidgets);
    expect(find.byType(AppBar), findsOneWidget);
  });
}
