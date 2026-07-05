// Basic smoke test: the ERP boots and renders its shell.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hair_again_erp/core/widgets/app_root.dart';

void main() {
  testWidgets('App boots and shows the sidebar brand', (WidgetTester tester) async {
    await tester.pumpWidget(const HairAgainApp());
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('HAIR AGAIN'), findsWidgets);
  });
}
