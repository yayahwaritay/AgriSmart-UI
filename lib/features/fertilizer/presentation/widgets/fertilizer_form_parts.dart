import 'package:flutter/material.dart';

import '../../../../core/theme/build_context_x.dart';
import '../fertilizer_format.dart';

/// Section heading with an icon, used for each step of the calculator form.
class FormSectionHeader extends StatelessWidget {
  const FormSectionHeader({super.key, required this.icon, required this.title, this.subtitle, this.trailing});

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.textTheme.titleSmall),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary)),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// An inline error line with an icon, so it doesn't rely on colour alone.
class InlineFieldError extends StatelessWidget {
  const InlineFieldError(this.message, {super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final text = message;
    if (text == null) return const SizedBox.shrink();
    final colors = context.agriColors;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: colors.accent),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: context.textTheme.bodySmall?.copyWith(color: colors.accent)),
          ),
        ],
      ),
    );
  }
}

/// A decimal-keypad text field that reports parsed numbers. Uses
/// [initialValue] (not a controller), so give it a key that changes when the
/// form is prefilled to reset its text.
class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.label,
    required this.onChanged,
    this.initialValue,
    this.unit,
    this.hint,
    this.errorText,
  });

  final String label;
  final double? initialValue;
  final String? unit;
  final String? hint;
  final String? errorText;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    final value = initialValue;
    return TextFormField(
      initialValue: value == null ? '' : formatNumber(value, decimals: 3),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      onChanged: (text) => onChanged(parseNumber(text)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: unit,
        errorText: errorText,
        errorMaxLines: 3,
        helperMaxLines: 2,
      ),
    );
  }
}

/// Selectable pill in the market's category-chip style. Selected chips also
/// get a check icon, so the state isn't shown by colour alone.
class SelectChip extends StatelessWidget {
  const SelectChip({super.key, required this.label, required this.selected, required this.onTap, this.icon});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final foreground = selected ? colors.onPrimary : colors.textPrimary;
    final leading = selected ? Icons.check_rounded : icon;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      avatar: leading == null ? null : Icon(leading, size: 18, color: foreground),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      selectedColor: colors.primary,
      backgroundColor: colors.surface.withValues(alpha: 0.6),
      labelStyle: context.textTheme.labelLarge?.copyWith(
        color: foreground,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: selected ? Colors.transparent : colors.divider),
      ),
    );
  }
}
