// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:geora/main.dart';

void main() {
  testWidgets('SplashScreen smoke test and navigation to LoginPage', (WidgetTester tester) async {
    await tester.pumpWidget(const GeoraApp());
    expect(find.text('smkn8malang.sch.id'), findsOneWidget);

    // Fast-forward past the 5-second timer and fade transition
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Verify LoginPage is displayed
    expect(find.text('Selamat datang'), findsOneWidget);
    expect(find.text('Masuk ke Absensi'), findsOneWidget);
  });
}
