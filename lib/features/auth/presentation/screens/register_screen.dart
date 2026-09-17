import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../application/auth_providers.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _submitting) return;
    setState(() => _submitting = true);
    await ref.read(authControllerProvider.notifier).register(
          name: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
        );
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(backgroundColor: Colors.transparent, leading: const BackButton()),
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
                  Text('Create your account', style: context.textTheme.headlineSmall, textAlign: TextAlign.center),
                  const SizedBox(height: 6),
                  Text(
                    'Buy seeds, fertilizer and fresh produce from farmers near you.',
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
                    controller: _name,
                    label: 'Full name',
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter your name' : null,
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 20),
                  _submitting
                      ? const Center(child: CircularProgressIndicator())
                      : PrimaryButton(label: 'Create account', onPressed: _submit),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Already have an account? Log in',
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
