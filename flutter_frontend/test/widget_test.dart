// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_web_app/main.dart';
import 'package:ecommerce_web_app/screens/auth_screen.dart';

  
void main() {
  testWidgets('App builds and shows Auth/Login or Home', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    // Check for either Auth/Login screen or Home/MainScreen
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(AuthScreen), findsWidgets);
    // Optionally, if you want to check for MainScreen if already logged in:
    // expect(find.byType(MainScreen), findsWidgets);
  });
}
