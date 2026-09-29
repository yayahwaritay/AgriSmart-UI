import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/agri_badge.dart';
import '../../../../core/widgets/neu_card.dart';
import '../../domain/entities/fertilizer_enums.dart';
import '../../domain/entities/fertilizer_result.dart';
import '../../domain/entities/nutrient_amounts.dart';
import '../fertilizer_format.dart';

/// The calculator's answer, in README.fertilizer.mobile.md's priority
/// order: warnings, shopping list, total cost, when to apply, good
/// practice, details. Used right after calculating and when reopening a
/// saved recommendation. [onAddPrice] shows an "Add price" action on
/// unpriced products; leave it null where recalculating isn't possible.
class FertilizerResultView extends StatelessWidget {
  const FertilizerResultView({super.key, required this.result, this.onAddPrice});

  final FertilizerResult result;
  final ValueChanged<ProductQuantity>? onAddPrice;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final noFertilizer = result.products.isEmpty;
    final stages = result.schedule.where((s) => s.products.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(result.crop, style: context.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'For ${formatNumber(result.areaHectares, decimals: 2)} ha'
          '${result.plantCount > 0 ? ' · about ${formatMoney(result.plantCount.toDouble())} plants' : ''}',
          style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
        ),
        if (result.warnings.isNotEmpty) ...[
          const SizedBox(height: 16),
          WarningsBanner(warnings: result.warnings),
        ],
        const SizedBox(height: 20),
        if (noFertilizer)
          _NoFertilizerNeeded(reason: result.notes.isEmpty ? null : result.notes.first)
        else ...[
          const _SectionTitle(icon: Icons.shopping_bag_rounded, title: 'What to buy'),
          const SizedBox(height: 10),
          for (final product in result.products) ...[
            _ShoppingCard(
              product: product,
              currency: result.currency,
              onAddPrice: onAddPrice == null ? null : () => onAddPrice!(product),
            ),
            const SizedBox(height: 12),
          ],
          _TotalCost(result: result, canAddPrice: onAddPrice != null),
          if (stages.isNotEmpty) ...[
            const SizedBox(height: 24),
            const _SectionTitle(icon: Icons.event_rounded, title: 'When to apply'),
            const SizedBox(height: 10),
            for (var i = 0; i < stages.length; i++)
              _TimelineStep(stage: stages[i], isLast: i == stages.length - 1),
          ],
        ],
        if (result.notes.isNotEmpty) ...[
          const SizedBox(height: 16),
          _GoodPractice(notes: result.notes),
        ],
        const SizedBox(height: 16),
        _Details(result: result),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: context.agriColors.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: context.textTheme.titleLarge)),
      ],
    );
  }
}

/// `warnings[]` — icon plus text, never colour alone.
class WarningsBanner extends StatelessWidget {
  const WarningsBanner({super.key, required this.warnings});

  final List<String> warnings;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    return NeuCard(
      color: colors.warning.withValues(alpha: 0.35),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: colors.textPrimary),
              const SizedBox(width: 8),
              Expanded(child: Text('Check this first', style: context.textTheme.titleSmall)),
            ],
          ),
          for (final warning in warnings) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.error_outline_rounded, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(warning, style: context.textTheme.bodyMedium)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _NoFertilizerNeeded extends StatelessWidget {
  const _NoFertilizerNeeded({required this.reason});

  final String? reason;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    return NeuCard(
      child: Column(
        children: [
          Icon(Icons.check_circle_rounded, size: 48, color: colors.primary),
          const SizedBox(height: 12),
          Text('No fertilizer needed', style: context.textTheme.titleLarge, textAlign: TextAlign.center),
          if (reason != null) ...[
            const SizedBox(height: 8),
            Text(
              reason!,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _ShoppingCard extends StatelessWidget {
  const _ShoppingCard({required this.product, required this.currency, required this.onAddPrice});

  final ProductQuantity product;
  final String currency;
  final VoidCallback? onAddPrice;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final bags = formatBags(product.bags50Kg);

    return NeuCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.name, style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          Semantics(
            label: '$bags ${bagNoun(product.bags50Kg)} of 50 kilograms',
            excludeSemantics: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_rounded, size: 36, color: colors.primary),
                const SizedBox(width: 6),
                Text('×', style: context.textTheme.titleLarge?.copyWith(color: colors.textSecondary)),
                const SizedBox(width: 6),
                Flexible(child: Text(bags, style: AppTheme.dataReadout(colors, fontSize: 34))),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '${bagNoun(product.bags50Kg)} (50 kg)',
                    style: context.textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text('${formatNumber(product.quantityKg)} kg', style: context.textTheme.bodyMedium),
          if (product.hasNonStandardBag)
            Text(
              'or ${formatBags(product.bags)} × ${formatNumber(product.bagSizeKg)} kg bags',
              style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
            ),
          const SizedBox(height: 10),
          if (product.hasPrice)
            Row(
              children: [
                Icon(Icons.payments_rounded, size: 20, color: colors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${formatMoney(product.estimatedCost)} $currency'
                    '  (${formatMoney(product.pricePerBag)} $currency per bag)',
                    style: context.textTheme.bodyMedium,
                  ),
                ),
              ],
            )
          else if (onAddPrice != null)
            TextButton.icon(
              style: TextButton.styleFrom(minimumSize: const Size(48, 48), padding: EdgeInsets.zero),
              onPressed: onAddPrice,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add price'),
            )
          else
            Text('No price', style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary)),
        ],
      ),
    );
  }
}

class _TotalCost extends StatelessWidget {
  const _TotalCost({required this.result, required this.canAddPrice});

  final FertilizerResult result;
  final bool canAddPrice;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    if (result.totalEstimatedCost <= 0) {
      if (!canAddPrice) return const SizedBox.shrink();
      return Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: colors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Add prices to see the total cost.',
              style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
            ),
          ),
        ],
      );
    }

    return NeuCard(
      inset: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payments_rounded, color: colors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text('Total cost', style: context.textTheme.titleSmall)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${formatMoney(result.totalEstimatedCost)} ${result.currency}',
            style: AppTheme.dataReadout(colors, fontSize: 26),
          ),
          if (!result.costComplete) ...[
            const SizedBox(height: 8),
            const AgriBadge(
              label: 'Partial: some prices missing',
              icon: Icons.info_outline_rounded,
              variant: AgriBadgeVariant.alert,
            ),
          ],
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.stage, required this.isLast});

  final ScheduleStage stage;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                const SizedBox(height: 18),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: colors.primary.withValues(alpha: 0.3))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeuCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(stage.stage, style: context.textTheme.titleMedium),
                        AgriBadge(label: 'Day ${stage.daysAfterPlanting}', icon: Icons.today_rounded),
                      ],
                    ),
                    if (stage.timing.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        stage.timing,
                        style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                      ),
                    ],
                    for (final product in stage.products) ...[
                      const SizedBox(height: 12),
                      _ScheduleProductRow(product: product),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleProductRow extends StatelessWidget {
  const _ScheduleProductRow({required this.product});

  final ScheduleProduct product;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.shopping_bag_outlined, size: 20, color: colors.textSecondary),
            const SizedBox(width: 8),
            Expanded(child: Text(product.name, style: context.textTheme.titleSmall)),
            Text('${formatNumber(product.quantityKg)} kg', style: AppTheme.dataReadout(colors, fontSize: 15)),
          ],
        ),
        if (product.perPlantHint.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.radio_button_checked_rounded, size: 22, color: colors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _capitalize(product.perPlantHint),
                    style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  static String _capitalize(String text) => text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}

/// A tappable header that shows/hides its [child]; 48 dp tall at minimum.
class _Collapsible extends StatefulWidget {
  const _Collapsible({required this.icon, required this.title, required this.child});

  final IconData icon;
  final String title;
  final Widget child;

  @override
  State<_Collapsible> createState() => _CollapsibleState();
}

class _CollapsibleState extends State<_Collapsible> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: _expanded,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Row(
                children: [
                  Icon(widget.icon, color: colors.primary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(widget.title, style: context.textTheme.titleMedium)),
                  Icon(
                    _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_expanded) ...[const SizedBox(height: 8), widget.child],
      ],
    );
  }
}

/// `notes[]` — the last note is always the disclaimer and stays visible.
class _GoodPractice extends StatelessWidget {
  const _GoodPractice({required this.notes});

  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final advice = notes.sublist(0, notes.length - 1);
    final disclaimer = notes.last;

    return NeuCard(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (advice.isNotEmpty)
            _Collapsible(
              icon: Icons.tips_and_updates_rounded,
              title: 'Good practice (${advice.length})',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final note in advice)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(Icons.check_rounded, size: 18, color: colors.primary),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(note, style: context.textTheme.bodyMedium)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: colors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(disclaimer, style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// For extension officers: nutrient maths, soil classes, target yield.
class _Details extends StatelessWidget {
  const _Details({required this.result});

  final FertilizerResult result;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final soil = result.soilAdjustment;
    final required_ = result.nutrientRequirementKg;
    final supplied = result.nutrientsSupplied;
    final balance = result.nutrientBalanceKg;
    final secondary = context.textTheme.bodySmall?.copyWith(color: colors.textSecondary);

    return NeuCard(
      inset: true,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: _Collapsible(
        icon: Icons.analytics_rounded,
        title: 'Details',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (result.selectionMode == SelectionMode.automatic)
                  const AgriBadge(label: 'Chosen for you', icon: Icons.auto_awesome_rounded),
                AgriBadge(
                  label: 'Target ${formatNumber(result.targetYieldTPerHa)} t/ha'
                      '${result.yieldBasis.isEmpty ? '' : ' ${result.yieldBasis}'}',
                  icon: Icons.flag_rounded,
                  variant: AgriBadgeVariant.neutral,
                ),
                if (result.targetYieldCapped)
                  const AgriBadge(label: 'Capped', icon: Icons.vertical_align_top_rounded, variant: AgriBadgeVariant.alert),
              ],
            ),
            const SizedBox(height: 16),
            Text('Nutrients needed vs supplied (kg)', style: context.textTheme.titleSmall),
            const SizedBox(height: 8),
            _NutrientBars(label: 'N', required_: required_.n, supplied: supplied.n, balance: balance.n),
            _NutrientBars(label: 'P₂O₅', required_: required_.p2o5, supplied: supplied.p2o5, balance: balance.p2o5),
            _NutrientBars(label: 'K₂O', required_: required_.k2o, supplied: supplied.k2o, balance: balance.k2o),
            Text('Balance: + means extra, − means short.', style: secondary),
            const SizedBox(height: 16),
            Text(
              soil.mode == SoilMode.soilTest ? 'Soil (from test report)' : 'Soil',
              style: context.textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Nitrogen: ${soil.nitrogenClass.label} · '
              'Phosphorus: ${soil.phosphorusClass.label} · '
              'Potassium: ${soil.potassiumClass.label}',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Per hectare: ${_perHa(result.nutrientRequirementPerHaKg)}',
              style: secondary,
            ),
          ],
        ),
      ),
    );
  }

  String _perHa(NutrientAmounts n) =>
      'N ${formatNumber(n.n)} · P₂O₅ ${formatNumber(n.p2o5)} · K₂O ${formatNumber(n.k2o)} kg';
}

/// A labelled pair of bars (needed, supplied) with the numbers written out.
class _NutrientBars extends StatelessWidget {
  const _NutrientBars({required this.label, required this.required_, required this.supplied, required this.balance});

  final String label;
  final double required_;
  final double supplied;
  final double balance;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final scale = [required_, supplied, 1.0].reduce((a, b) => a > b ? a : b);
    final small = context.textTheme.labelSmall;

    Widget bar(String name, double value, Color color) {
      return Row(
        children: [
          SizedBox(width: 64, child: Text(name, style: small)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (value / scale).clamp(0, 1).toDouble(),
                minHeight: 8,
                color: color,
                backgroundColor: colors.divider,
              ),
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(formatNumber(value), textAlign: TextAlign.end, style: small),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(formatBalance(balance), style: context.textTheme.labelMedium),
            ],
          ),
          const SizedBox(height: 4),
          bar('Needed', required_, colors.textSecondary),
          const SizedBox(height: 4),
          bar('Supplied', supplied, colors.primary),
        ],
      ),
    );
  }
}
