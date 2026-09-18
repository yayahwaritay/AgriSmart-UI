import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../application/auth_providers.dart';
import '../widgets/auth_text_field.dart';

/// Covers both password-change cases from README.mobile.md's "Reset /
/// forgot password" section:
///  - a voluntary change, reached from the profile screen (current password
///    is the account's real password);
///  - finishing a forced reset, reached automatically via [appRouterProvider]
///    when the logged-in user has `mustChangePassword: true` (current
///    password is the admin-issued temporary one). This case can't be
///    dismissed — the router keeps redirecting back here until it succeeds.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool forced}) async {
    if (!_formKey.currentState!.validate() || _submitting) return;
    setState(() => _submitting = true);

    final ok = await ref.read(authControllerProvider.notifier).changePassword(
          currentPassword: _currentPassword.text,
          newPassword: _newPassword.text,
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok && !forced) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated.')));
      context.pop();
    }
    // On success in the forced case, the router's redirect takes over as
    // soon as authControllerProvider's state updates — nothing to do here.
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final authState = ref.watch(authControllerProvider);
    final forced = authState.user?.mustChangePassword ?? false;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: !forced,
        leading: forced ? null : const BackButton(),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    forced ? 'Set a new password' : 'Change password',
                    style: context.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    forced
                        ? "You're signed in with a temporary password. Choose a new one to continue."
                        : 'Enter your current password and choose a new one.',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: 28),
                  if (authState.errorMessage != null) ...[
                    Text(
                      authState.errorMessage!,
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodySmall?.copyWith(color: colors.accent),
                    ),
                    const SizedBox(height: 12),
                  ],
                  AuthTextField(
                    controller: _currentPassword,
                    label: forced ? 'Temporary password' : 'Current password',
                    obscureText: true,
                    validator: (value) => (value == null || value.isEmpty) ? 'Enter your current password' : null,
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    controller: _newPassword,
                    label: 'New password',
                    obscureText: true,
                    validator: (value) =>
                        (value == null || value.length < 8) ? 'Password must be at least 8 characters' : null,
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    controller: _confirmPassword,
                    label: 'Confirm new password',
                    obscureText: true,
                    validator: (value) => (value != _newPassword.text) ? 'Passwords do not match' : null,
                  ),
                  const SizedBox(height: 20),
                  _submitting
                      ? const Center(child: CircularProgressIndicator())
                      : PrimaryButton(label: 'Update password', onPressed: () => _submit(forced: forced)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
