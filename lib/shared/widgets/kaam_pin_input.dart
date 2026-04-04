import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_spacing.dart';

/// Digit PIN / OTP entry: one invisible [TextEditingController] drives boxed cells.
/// Reuse for login codes, password reset codes, or any fixed-length numeric OTP.
class KaamPinInput extends StatefulWidget {
  const KaamPinInput({
    super.key,
    this.length = 6,
    required this.controller,
    this.focusNode,
    this.enabled = true,
    this.autofocus = false,
    this.label,
    this.onChanged,
    /// Called once when [controller] reaches [length] digits (also on paste).
    this.onCompleted,
    this.spacing = 8,
  });

  final int length;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool enabled;
  final bool autofocus;
  final String? label;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final double spacing;

  @override
  State<KaamPinInput> createState() => _KaamPinInputState();
}

class _KaamPinInputState extends State<KaamPinInput> {
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;
  int _prevLen = 0;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _ownsFocusNode = false;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
    _prevLen = widget.controller.text.length;
    widget.controller.addListener(_handleController);
    _focusNode.addListener(_handleFocus);
  }

  @override
  void didUpdateWidget(covariant KaamPinInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleController);
      widget.controller.addListener(_handleController);
      _prevLen = widget.controller.text.length;
    }
  }

  void _handleFocus() {
    setState(() {});
  }

  void _handleController() {
    final String t = widget.controller.text;
    widget.onChanged?.call(t);
    if (t.length == widget.length && _prevLen != widget.length) {
      widget.onCompleted?.call(t);
    }
    _prevLen = t.length;
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleController);
    _focusNode.removeListener(_handleFocus);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  int get _activeIndex {
    final String text = widget.controller.text;
    if (!_focusNode.hasFocus) {
      return -1;
    }
    if (text.isEmpty) {
      return 0;
    }
    if (text.length >= widget.length) {
      return widget.length - 1;
    }
    return text.length;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final String text = widget.controller.text;

    final Widget row = Row(
      children: List<Widget>.generate(widget.length, (int i) {
        final String char = i < text.length ? text[i] : '';
        final bool active = widget.enabled && i == _activeIndex;
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              end: i < widget.length - 1 ? widget.spacing : 0,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  width: active ? 2 : 1,
                  color: active
                      ? scheme.primary
                      : scheme.outlineVariant.withValues(alpha: 0.9),
                ),
                color: widget.enabled
                    ? scheme.surfaceContainerHighest.withValues(alpha: 0.35)
                    : scheme.surfaceContainerHighest.withValues(alpha: 0.2),
              ),
              child: Text(
                char,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        );
      }),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (widget.label != null && widget.label!.isNotEmpty) ...<Widget>[
          Text(
            widget.label!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Semantics(
          label: widget.label,
          child: SizedBox(
            height: 52,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                row,
                Positioned.fill(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    autofocus: widget.autofocus,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    autofillHints: const <String>[AutofillHints.oneTimeCode],
                    maxLength: widget.length,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(widget.length),
                    ],
                    style: const TextStyle(
                      color: Colors.transparent,
                      height: 0.01,
                      fontSize: 1,
                    ),
                    cursorColor: Colors.transparent,
                    showCursor: false,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                      counterText: '',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
