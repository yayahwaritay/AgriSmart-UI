import 'package:flutter/material.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/neu_card.dart';

/// Text field + send button for posting a new comment, styled as a
/// recessed pill to match the rest of the neumorphic/glass system.
class CommentComposer extends StatefulWidget {
  const CommentComposer({super.key, required this.onSubmit});

  final Future<void> Function(String text) onSubmit;

  @override
  State<CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<CommentComposer> {
  final _controller = TextEditingController();
  bool _hasText = false;
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    await widget.onSubmit(text);
    _controller.clear();
    if (mounted) {
      setState(() {
        _hasText = false;
        _sending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;

    return NeuCard(
      inset: true,
      borderRadius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: colors.primary.withValues(alpha: 0.14),
            child: const Text('🙂', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submit(),
              onChanged: (value) => setState(() => _hasText = value.trim().isNotEmpty),
              style: context.textTheme.bodySmall,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'Add a comment…',
                hintStyle: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
              ),
            ),
          ),
          IconButton(
            onPressed: _hasText && !_sending ? _submit : null,
            icon: _sending
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
                  )
                : Icon(
                    Icons.send_rounded,
                    color: _hasText ? colors.primary : colors.textSecondary,
                    size: 20,
                  ),
          ),
        ],
      ),
    );
  }
}
