import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awrad/main.dart';

void main() {
  testWidgets('Arabic homepage identifies the app and review state', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(AwradApp(preferences: prefs));
    expect(find.text('أوراد'), findsWidgets);
    expect(find.textContaining('إصدار تجريبي'), findsOneWidget);
  });
}
