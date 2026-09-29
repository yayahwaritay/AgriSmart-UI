import 'package:agrismart/core/theme/app_theme.dart';
import 'package:agrismart/features/fertilizer/domain/entities/fertilizer_result.dart';
import 'package:agrismart/features/fertilizer/presentation/widgets/fertilizer_result_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fertilizer_fixtures.dart';

FertilizerResult _result(void Function(Map<String, dynamic> json) edit) {
  final json = decode(calculateResponseJson);
  edit(json);
  return FertilizerResult.fromJson(json);
}

Future<void> _pump(WidgetTester tester, FertilizerResult result, {ValueChanged<ProductQuantity>? onAddPrice}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: SingleChildScrollView(child: FertilizerResultView(result: result, onAddPrice: onAddPrice)),
      ),
    ),
  );
}

void main() {
  testWidgets('shows bags, kg, cost and the disclaimer; no warnings banner', (tester) async {
    await _pump(tester, _result((_) {}));

    expect(find.text('3½'), findsOneWidget);
    // Once in the shopping list, once under "When to apply".
    expect(find.text('171.4 kg'), findsNWidgets(2));
    expect(find.text('4,675 SLE'), findsOneWidget);
    expect(find.byType(WarningsBanner), findsNothing);
    expect(find.textContaining('general guidelines'), findsOneWidget);
    expect(find.text('Add price'), findsNothing);
  });

  testWidgets('warnings banner appears with icon and text', (tester) async {
    const warning = 'No potassium source selected — K2O deficit of 50 kg. Add MOP (Muriate of Potash).';
    await _pump(tester, _result((json) => json['warnings'] = [warning]));

    expect(find.byType(WarningsBanner), findsOneWidget);
    expect(find.text(warning), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });

  testWidgets('missing price shows "Add price" and a partial total', (tester) async {
    final result = _result((json) {
      final urea = (json['products'] as List<dynamic>)[1] as Map<String, dynamic>;
      urea['hasPrice'] = false;
      urea['pricePerBag'] = 0;
      urea['estimatedCost'] = 0;
      json['totalEstimatedCost'] = 3325.0;
      json['costComplete'] = false;
    });
    ProductQuantity? tapped;
    await _pump(tester, result, onAddPrice: (p) => tapped = p);

    expect(find.text('Add price'), findsOneWidget);
    expect(find.text('Partial: some prices missing'), findsOneWidget);
    expect(find.text('3,325 SLE'), findsOneWidget);

    await tester.ensureVisible(find.text('Add price'));
    await tester.tap(find.text('Add price'));
    expect(tapped?.productId, 'urea');
  });

  testWidgets('shows the per-plant hint prominently', (tester) async {
    await _pump(tester, _result((_) {}));

    expect(find.text('About 1.5 level bottle caps per plant (1 cap ≈ 5 g)'), findsOneWidget);
    expect(find.text('About 0.5 level bottle cap per plant (1 cap ≈ 5 g)'), findsOneWidget);
    expect(find.text('Day 35'), findsOneWidget);
  });

  testWidgets('empty products shows "No fertilizer needed"', (tester) async {
    const reason = 'Your soil already supplies enough nutrients for this crop — no fertilizer is needed.';
    final result = _result((json) {
      json['products'] = <dynamic>[];
      json['totalEstimatedCost'] = 0;
      json['notes'] = [reason, 'These rates are general guidelines.'];
    });
    await _pump(tester, result);

    expect(find.text('No fertilizer needed'), findsOneWidget);
    expect(find.text(reason), findsOneWidget);
    expect(find.text('What to buy'), findsNothing);
    expect(find.text('When to apply'), findsNothing);
    expect(find.text('These rates are general guidelines.'), findsOneWidget);
  });
}
