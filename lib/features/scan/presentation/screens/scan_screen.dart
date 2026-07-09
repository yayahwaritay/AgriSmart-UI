import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/scan_viewfinder.dart';
import '../../../history/application/history_providers.dart';
import '../../../scan/domain/entities/plant_scan.dart';
import '../../application/scan_providers.dart';

class ScanScreen extends ConsumerWidget {
  const ScanScreen({super.key});

  Future<void> _pickImage(WidgetRef ref, ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    ref.read(scanControllerProvider.notifier).setCapturedImage(File(picked.path));
    await ref.read(scanControllerProvider.notifier).runDiagnosis();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.agriColors;
    final scanState = ref.watch(scanControllerProvider);

    ref.listen<ScanState>(scanControllerProvider, (previous, next) {
      if (next.status == ScanStatus.success && next.result != null && next.image != null) {
        unawaited(
          ref.read(scanHistoryProvider.notifier).addScan(
                PlantScan(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  imagePath: next.image!.path,
                  diagnosis: next.result!,
                  scannedAt: DateTime.now(),
                ),
              ),
        );
        unawaited(
          context.push('/result', extra: next.result).then((_) {
            ref.read(scanControllerProvider.notifier).reset();
          }),
        );
      } else if (next.status == ScanStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? 'Diagnosis failed. Please try again.')),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Scan', style: context.textTheme.headlineSmall),
                  if (scanState.image != null && scanState.status != ScanStatus.diagnosing)
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => ref.read(scanControllerProvider.notifier).reset(),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ScanViewfinder(
                  size: 300,
                  scanning: scanState.status == ScanStatus.diagnosing,
                  child: scanState.image != null
                      ? Image.file(scanState.image!, fit: BoxFit.cover)
                      : ColoredBox(
                          color: colors.surface,
                          child: Icon(Icons.eco_outlined, size: 64, color: colors.textSecondary),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: _ScanActions(state: scanState, onPick: (source) => _pickImage(ref, source)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanActions extends StatelessWidget {
  const _ScanActions({required this.state, required this.onPick});

  final ScanState state;
  final ValueChanged<ImageSource> onPick;

  @override
  Widget build(BuildContext context) {
    if (state.status == ScanStatus.diagnosing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text('Analyzing leaf...', style: context.textTheme.bodyMedium),
        ],
      );
    }

    return Column(
      children: [
        PrimaryButton(
          label: 'Open Camera',
          icon: Icons.camera_alt_rounded,
          onPressed: () => onPick(ImageSource.camera),
        ),
        const SizedBox(height: 12),
        GlassButton(
          label: 'Choose from Gallery',
          icon: Icons.photo_library_outlined,
          onPressed: () => onPick(ImageSource.gallery),
        ),
      ],
    );
  }
}
