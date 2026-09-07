import 'package:flutter_test/flutter_test.dart';
import 'package:warung_menu_app/main.dart';

void main() {
  testWidgets('WarungApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WarungApp());
    expect(find.text('Warung Selera Nusantara'), findsOneWidget);
  });
}
