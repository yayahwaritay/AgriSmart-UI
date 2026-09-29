import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../application/fertilizer_providers.dart';
import '../../domain/entities/fertilizer_result.dart';
import '../widgets/fertilizer_result_view.dart';
import '../widgets/price_dialog.dart';

/// `/fertilizer/result` — the latest calculation from
/// [fertilizerCalculatorControllerProvider], with "Add price" (recalculates)
/// and "Save" (`POST /fertilizer/recommendations`).
class FertilizerResultScreen extends ConsumerStatefulWidget {
  const FertilizerResultScreen({super.key});

  @override
  ConsumerState<FertilizerResultScreen> createState() => _FertilizerResultScreenState();
}

class _FertilizerResultScreenState extends ConsumerState<FertilizerResultScreen> {
  /// The result that was last saved, so "Save" isn't offered twice for it.
  FertilizerResult? _savedResult;

  void _showSnackBar(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message), action: action));
  }

  Future<void> _addPrice(ProductQuantity product) async {
    final result = ref.read(fertilizerCalculatorControllerProvider).result;
    final price = await showPriceDialog(
      context,
      productName: product.name,
      bagSizeKg: product.bagSizeKg,
      currency: result?.currency.isNotEmpty ?? false ? result!.currency : 'SLE',
    );
    if (price == null || !mounted) return;

    final controller = ref.read(fertilizerCalculatorControllerProvider.notifier)..setPrice(product.productId, price);
    final ok = await controller.calculate();
    if (ok || !mounted) return;
    final state = ref.read(fertilizerCalculatorControllerProvider);
    // A price the server rejected: drop it so the result stays consistent.
    final priceError = state.fieldErrors[FertilizerField.price(product.productId)];
    if (priceError != null) controller.setPrice(product.productId, null);
    _showSnackBar(priceError ?? state.errorMessage ?? 'Could not recalculate.');
  }

  Future<void> _save() async {
    final result = ref.read(fertilizerCalculatorControllerProvider).result;
    final saved = await showDialog<bool>(context: context, builder: (context) => const _SaveDialog());
    if (saved != true || !mounted) return;
    setState(() => _savedResult = result);
    _showSnackBar(
      'Plan saved.',
      action: SnackBarAction(label: 'View saved', onPressed: () => context.push('/fertilizer/history')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final state = ref.watch(fertilizerCalculatorControllerProvider);
    final result = state.result;
    final recalculating = state.status == CalculationStatus.calculating;
    final alreadySaved = result != null && identical(result, _savedResult);

    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Your fertilizer plan')),
      body: SafeArea(
        top: false,
        child: result == null
            ? Center(
                child: Text(
                  'No plan yet — fill in the calculator first.',
                  style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                ),
              )
            : Column(
                children: [
                  if (recalculating) const LinearProgressIndicator(minHeight: 3),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                      children: [
                        FertilizerResultView(result: result, onAddPrice: recalculating ? null : _addPrice),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          label: alreadySaved ? 'Saved' : 'Save this plan',
                          icon: alreadySaved ? Icons.check_rounded : Icons.bookmark_add_rounded,
                          onPressed: alreadySaved || recalculating ? null : _save,
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton.icon(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.edit_rounded),
                            label: const Text('Change my answers'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Asks for an optional plot name, then saves. Pops `true` once saved.
class _SaveDialog extends ConsumerStatefulWidget {
  const _SaveDialog();

  @override
  ConsumerState<_SaveDialog> createState() => _SaveDialogState();
}

class _SaveDialogState extends ConsumerState<_SaveDialog> {
  final _controller = TextEditingController();
  bool _saving = false;
  String? _fieldError;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _saving = true;
      _fieldError = null;
      _error = null;
    });
    try {
      await ref.read(fertilizerCalculatorControllerProvider.notifier).save(plotLabel: _controller.text);
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      final fieldErrors = mapFertilizerApiErrors(e.errors, null);
      setState(() {
        _saving = false;
        _fieldError = fieldErrors[FertilizerField.plotLabel];
        _error = _fieldError == null ? e.message : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Could not save. Check your connection and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    return AlertDialog(
      title: const Text('Save this plan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            maxLength: 100,
            enabled: !_saving,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Plot name (optional)',
              hintText: 'e.g. Back field by the stream',
              errorText: _fieldError,
            ),
          ),
          if (_error != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline_rounded, size: 18, color: colors.accent),
                const SizedBox(width: 6),
                Expanded(child: Text(_error!, style: TextStyle(color: colors.accent))),
              ],
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
        TextButton(
          onPressed: _saving ? null : _submit,
          child: Text(_saving ? 'Saving…' : (_error != null ? 'Try again' : 'Save')),
        ),
      ],
    );
  }
}
