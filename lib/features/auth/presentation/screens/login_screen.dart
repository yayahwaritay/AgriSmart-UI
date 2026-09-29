import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../application/auth_providers.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  bool _biometricSubmitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _submitting) return;
    setState(() => _submitting = true);
    await ref.read(authControllerProvider.notifier).login(email: _email.text.trim(), password: _password.text);
    if (mounted) setState(() => _submitting = false);
  }

  Future<void> _submitBiometric() async {
    if (_biometricSubmitting) return;
    setState(() => _biometricSubmitting = true);
    await ref.read(authControllerProvider.notifier).loginWithBiometric();
    if (mounted) setState(() => _biometricSubmitting = false);
  }

  // There's no self-serve reset flow (README.mobile.md "Reset / forgot
  // password") — a buyer who's locked out has to go through support/an
  // admin, who issues a temporary password from the admin console.
  void _showForgotPasswordInfo() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot your password?'),
        content: const Text(
          "We can't reset it from here yet. Contact AgriSmart support and "
          "we'll issue you a temporary password by email — use it to log in "
          "and you'll be asked to set a new one straight away.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Got it')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Center(child: FloatingAppLogo(size: 104)),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome to AgriSmart',
                    style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Log in to browse the market and scan your crops.',
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
                  if (authState.biometricEnabled) ...[
                    Text(
                      authState.biometricEmail!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.labelSmall?.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    _biometricSubmitting
                        ? const Center(child: CircularProgressIndicator())
                        : GlassButton(
                            label: 'Log in with Face ID / fingerprint',
                            icon: Icons.fingerprint_rounded,
                            onPressed: _submitBiometric,
                          ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: Divider(color: colors.divider)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text('or', style: context.textTheme.labelSmall?.copyWith(color: colors.textSecondary)),
                        ),
                        Expanded(child: Divider(color: colors.divider)),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                  AuthTextField(
                    controller: _email,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value == null || !value.contains('@')) ? 'Enter a valid email' : null,
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    controller: _password,
                    label: 'Password',
                    obscureText: true,
                    validator: (value) =>
                        (value == null || value.length < 8) ? 'Password must be at least 8 characters' : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPasswordInfo,
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 32)),
                      child: Text(
                        'Forgot password?',
                        style: context.textTheme.labelMedium?.copyWith(color: colors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _submitting
                      ? const Center(child: CircularProgressIndicator())
                      : PrimaryButton(label: 'Log in', onPressed: _submit),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: Text(
                      "Don't have an account? Sign up",
                      style: context.textTheme.labelMedium?.copyWith(color: colors.primary, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
