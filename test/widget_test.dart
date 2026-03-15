import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asher_adventure/app.dart';

void main() {
  testWidgets('App renders title screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const ProviderScope(child: AsherAdventureApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text("Asher's Adventure"), findsOneWidget);
  });
}
