import 'package:agrismart/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots to the Home dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AgriSmartApp()));
    await tester.pumpAndSettle();

    expect(find.text('Your fields, at a glance'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Scan'), findsAtLeastNWidgets(1));
    expect(find.text('History'), findsNothing);
    expect(find.text('Market'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Fresh from the market'), findsOneWidget);
  });
}
