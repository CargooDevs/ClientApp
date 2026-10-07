// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cargoo_client/main.dart';

void main() {
  testWidgets('exibe a tela inicial da Cargoo', (WidgetTester tester) async {
    await tester.pumpWidget(const CargooClientApp());

    expect(find.byType(Image), findsOneWidget);
    expect(
        find.text('Carga, corrida ou aluguer — à sua espera'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo de volta'), findsOneWidget);
  });
}
