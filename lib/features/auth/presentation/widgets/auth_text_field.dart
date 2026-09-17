import 'package:flutter/material.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/neu_card.dart';

/// Recessed pill text field matching [CommentComposer]'s styling, used for
/// every field on the login/register forms.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;

    return NeuCard(
      inset: true,
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: context.textTheme.bodyMedium,
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          labelText: label,
          labelStyle: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
        ),
      ),
    );
  }
}
