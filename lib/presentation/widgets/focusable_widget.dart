import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

/// D-Pad-aware focus wrapper untuk seluruh interactive elements di Android TV.
///
/// Membungkus widget apapun dengan focus management yang konsisten:
/// - Visual focus indicator via [builder] callback (isFocused parameter)
/// - Smooth scale animation saat focused (1.0 → 1.02) (TASK-010)
/// - D-Pad select/Enter key handler via [onSelect] (TASK-011)
/// - Minimum tap target 48×48 logical pixels (REQ-003, TASK-012)
///
/// Ref: Plan 04 TASK-007 s.d. TASK-012
class FocusableWidget extends StatefulWidget {
  /// Builder yang menerima [isFocused] state dan mengembalikan widget.
  /// Gunakan [isFocused] untuk mengubah tampilan saat focused.
  final Widget Function(bool isFocused) builder;

  /// Callback yang dipanggil saat D-Pad select / Enter / GameButton A ditekan.
  final VoidCallback? onSelect;

  /// FocusNode eksternal. Jika null, widget akan membuat internal FocusNode.
  final FocusNode? focusNode;

  /// Jika true, widget akan otomatis mendapat focus saat pertama kali build.
  final bool autofocus;

  /// Durasi animasi scale saat focus berubah. Default: 200ms (GUD-001).
  final Duration focusAnimationDuration;

  const FocusableWidget({
    super.key,
    required this.builder,
    this.onSelect,
    this.focusNode,
    this.autofocus = false,
    this.focusAnimationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<FocusableWidget> createState() => _FocusableWidgetState();
}

class _FocusableWidgetState extends State<FocusableWidget> {
  /// Internal FocusNode — hanya dibuat jika tidak disediakan via constructor.
  FocusNode? _internalFocusNode;

  /// FocusNode yang aktif digunakan (external atau internal).
  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode!;

  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    // Buat internal FocusNode hanya jika tidak ada external yang disediakan.
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
    }
  }

  @override
  void dispose() {
    // Hanya dispose internal FocusNode — jangan dispose external FocusNode.
    _internalFocusNode?.dispose();
    super.dispose();
  }

  /// Handler untuk keyboard/D-Pad events.
  ///
  /// Mendeteksi tombol select (D-Pad center), Enter, dan GameButton A.
  /// Return [KeyEventResult.handled] jika event diproses, [KeyEventResult.ignored] jika tidak.
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final isSelectKey =
          event.logicalKey == LogicalKeyboardKey.select ||
          event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.gameButtonA;

      if (isSelectKey) {
        widget.onSelect?.call();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _effectiveFocusNode,
      autofocus: widget.autofocus,
      onKeyEvent: _handleKeyEvent,
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: AnimatedScale(
        scale: _isFocused ? 1.02 : 1.0,
        duration: widget.focusAnimationDuration,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _effectiveFocusNode.requestFocus();
            widget.onSelect?.call();
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: widget.builder(_isFocused),
          ),
        ),
      ),
    );
  }
}
