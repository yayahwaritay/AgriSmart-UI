import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../auth/data/biometric_signature_service.dart';

class AccountCard extends ConsumerStatefulWidget {
  const AccountCard({super.key});

  @override
  ConsumerState<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends ConsumerState<AccountCard> {
  bool _biometricBusy = false;

  Future<void> _toggleBiometric(bool enable) async {
    setState(() => _biometricBusy = true);
    final controller = ref.read(authControllerProvider.notifier);

    bool ok = true;
    if (enable) {
      ok = await controller.enableBiometric();
    } else {
      await controller.disableBiometric();
    }

    if (!mounted) return;
    setState(() => _biometricBusy = false);
    if (enable && !ok) {
      final message = ref.read(authControllerProvider).errorMessage ?? 'Could not enable biometric login.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final biometricService = ref.watch(biometricSignatureServiceProvider);

    return GlassCard(
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colors.primary.withValues(alpha: 0.14),
                child: Icon(Icons.person_rounded, color: colors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? '—', style: context.textTheme.titleMedium),
                    Text(
                      user?.email ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (biometricService.isSupportedPlatform) ...[
            const SizedBox(height: 12),
            Divider(color: colors.divider, height: 1),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: authState.biometricEnabled,
              onChanged: _biometricBusy ? null : _toggleBiometric,
              activeThumbColor: colors.primary,
              secondary: _biometricBusy
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(Icons.fingerprint_rounded, color: colors.primary),
              title: Text('Face ID / fingerprint login', style: context.textTheme.titleSmall),
              subtitle: Text(
                'Sign in without typing your password',
                style: context.textTheme.labelSmall?.copyWith(color: colors.textSecondary),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Divider(color: colors.divider, height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.lock_reset_rounded, color: colors.primary),
            title: Text('Change password', style: context.textTheme.titleSmall),
            trailing: Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
            onTap: () => context.push('/change-password'),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
              icon: Icon(Icons.logout_rounded, color: colors.accent, size: 18),
              label: Text('Log out', style: TextStyle(color: colors.accent)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.accent.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
