import 'package:flutter/material.dart';

import '../fertilizer_format.dart';

/// "Add price" on the result screen — asks for the price of one bag.
/// Returns `null` if cancelled.
Future<double?> showPriceDialog(
  BuildContext context, {
  required String productName,
  required double bagSizeKg,
  String currency = 'SLE',
}) {
  return showDialog<double>(
    context: context,
    builder: (context) => _PriceDialog(productName: productName, bagSizeKg: bagSizeKg, currency: currency),
  );
}

class _PriceDialog extends StatefulWidget {
  const _PriceDialog({required this.productName, required this.bagSizeKg, required this.currency});

  final String productName;
  final double bagSizeKg;
  final String currency;

  @override
  State<_PriceDialog> createState() => _PriceDialogState();
}

class _PriceDialogState extends State<_PriceDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = parseNumber(_controller.text);
    if (value == null || value < 0) {
      setState(() => _error = 'Enter a price of 0 or more.');
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final bag = widget.bagSizeKg > 0 ? '${formatNumber(widget.bagSizeKg)} kg bag' : 'bag';
    return AlertDialog(
      title: Text('Price of ${widget.productName}'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: 'Price for one $bag',
          suffixText: widget.currency,
          errorText: _error,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        TextButton(onPressed: _submit, child: const Text('Recalculate')),
      ],
    );
  }
}
