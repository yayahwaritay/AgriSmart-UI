import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/neu_card.dart';
import '../../application/fertilizer_providers.dart';
import '../../domain/entities/fertilizer_enums.dart';
import '../../domain/entities/fertilizer_product.dart';
import 'fertilizer_form_parts.dart';

IconData productTypeIcon(ProductType type) => switch (type) {
      ProductType.compound => Icons.blur_on_rounded,
      ProductType.straight => Icons.science_rounded,
      ProductType.organic => Icons.eco_rounded,
    };

/// "Which fertilizers do you have?" — "Choose for me" (the default, sends no
/// product ids) or product chips grouped by type, each with an optional
/// price per bag.
class ProductSection extends ConsumerWidget {
  const ProductSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.agriColors;
    final products = ref.watch(fertilizerProductsProvider);
    final state = ref.watch(fertilizerCalculatorControllerProvider);
    final controller = ref.read(fertilizerCalculatorControllerProvider.notifier);

    return NeuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FormSectionHeader(
            icon: Icons.shopping_bag_rounded,
            title: 'Which fertilizers do you have?',
            subtitle: 'Optional. We can choose for you.',
          ),
          const SizedBox(height: 12),
          SelectChip(
            label: 'Choose for me',
            icon: Icons.auto_awesome_rounded,
            selected: state.chooseForMe,
            onTap: controller.chooseForMe,
          ),
          if (state.chooseForMe)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'We will use NPK 15-15-15 and Urea, plus TSP or MOP only if your crop needs it.',
                style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
              ),
            ),
          const SizedBox(height: 12),
          products.when(
            data: (items) => _ProductChips(products: items, state: state, controller: controller),
            loading: () => const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Row(
              children: [
                Icon(Icons.error_outline_rounded, color: colors.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Could not load fertilizers', style: TextStyle(color: colors.accent)),
                ),
                TextButton(
                  onPressed: () => ref.invalidate(fertilizerProductsProvider),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
          InlineFieldError(state.fieldErrors[FertilizerField.products]),
        ],
      ),
    );
  }
}

class _ProductChips extends StatelessWidget {
  const _ProductChips({required this.products, required this.state, required this.controller});

  final List<FertilizerProduct> products;
  final FertilizerFormState state;
  final FertilizerCalculatorController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final selected = [
      for (final id in state.selectedProductIds)
        for (final p in products)
          if (p.id == id) p,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Or tick the ones you have:', style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary)),
        for (final type in ProductType.values)
          if (products.any((p) => p.type == type)) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(productTypeIcon(type), size: 18, color: colors.textSecondary),
                const SizedBox(width: 6),
                Text(type.label, style: context.textTheme.labelLarge?.copyWith(color: colors.textSecondary)),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final product in products.where((p) => p.type == type))
                  SelectChip(
                    label: product.name,
                    icon: productTypeIcon(type),
                    selected: state.selectedProductIds.contains(product.id),
                    onTap: () => controller.toggleProduct(product),
                  ),
              ],
            ),
          ],
        if (selected.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Price per bag (optional)', style: context.textTheme.titleSmall),
          Text(
            'Add prices to see the total cost.',
            style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
          ),
          for (final product in selected) ...[
            const SizedBox(height: 10),
            NumberField(
              key: ValueKey('price-${product.id}-${state.formVersion}'),
              label: '${product.name} (${_bagLabel(product)})',
              unit: product.currency.isEmpty ? 'SLE' : product.currency,
              initialValue: state.prices[product.id],
              errorText: state.fieldErrors[FertilizerField.price(product.id)],
              onChanged: (value) => controller.setPrice(product.id, value),
            ),
          ],
        ],
      ],
    );
  }

  String _bagLabel(FertilizerProduct product) {
    final size = product.bagSizeKg == product.bagSizeKg.roundToDouble()
        ? product.bagSizeKg.toInt().toString()
        : product.bagSizeKg.toString();
    return '$size kg bag';
  }
}
