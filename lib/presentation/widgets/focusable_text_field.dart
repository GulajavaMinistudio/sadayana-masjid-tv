import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/islamic_colors.dart';
import '../../core/theme/islamic_typography.dart';
import 'focusable_widget.dart';

/// TextField khusus Android TV yang mendukung D-Pad navigation.
///
/// Menggunakan kombinasi dua FocusNode:
/// 1. Container FocusNode: Menangkap event navigasi D-Pad dan menampilkan highlight/border.
/// 2. TextField FocusNode: Menangkap keyboard input.
///
/// Cara kerja:
/// - Saat user menavigasi ke field menggunakan D-Pad, container di-highlight.
/// - Saat user menekan tombol Select / Tengah / OK pada D-Pad, TextField diberikan fokus
///   sehingga virtual keyboard (Soft Keyboard) muncul.
/// - Setelah keyboard ditutup, fokus dikembalikan kembali ke container untuk navigasi D-Pad lanjutan.
class FocusableTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? icon;
  final int maxLines;
  final int minLines;
  final bool autofocus;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final TextInputType keyboardType;

  const FocusableTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.icon,
    this.maxLines = 1,
    this.minLines = 1,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<FocusableTextField> createState() => _FocusableTextFieldState();
}

class _FocusableTextFieldState extends State<FocusableTextField> {
  late FocusNode _containerFocusNode;
  late FocusNode _textFieldFocusNode;

  @override
  void initState() {
    super.initState();
    _containerFocusNode = FocusNode();
    // skipTraversal: true — D-pad tidak auto-landing di sini,
    // tapi requestFocus() programatik via addPostFrameCallback tetap berfungsi.
    _textFieldFocusNode = FocusNode(skipTraversal: true);

    // Ketika textField mendapat atau kehilangan fokus
    _textFieldFocusNode.addListener(() {
      if (_textFieldFocusNode.hasFocus) {
        // Scroll agar field ini terlihat di atas keyboard.
        // Delay 200ms untuk memberi waktu keyboard selesai muncul
        // dan layout (viewInsets padding) selesai di-recalculate.
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && _textFieldFocusNode.hasFocus) {
            Scrollable.ensureVisible(
              context,
              alignment: 0.3,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
            );
          }
        });
      } else {
        if (mounted) {
          // Kembalikan fokus ke container agar D-Pad kembali bisa navigasi antar field
          _containerFocusNode.requestFocus();
        }
      }
      // Trigger re-render untuk update UI border
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _containerFocusNode.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusableWidget(
      focusNode: _containerFocusNode,
      autofocus: widget.autofocus,
      onSelect: () {
        // WAJIB addPostFrameCallback: synchronous requestFocus() di dalam
        // key-event handler tidak membuka IME di Android TV karena event
        // belum selesai diproses Flutter saat callback ini dipanggil.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _textFieldFocusNode.requestFocus();
        });
      },
      builder: (isContainerFocused) {
        // Highlight border berwarna Gold/Emerald jika container terpilih ATAU sedang mengetik
        final isFocused = isContainerFocused || _textFieldFocusNode.hasFocus;

        return Container(
          decoration: BoxDecoration(
            color: isFocused
                ? IslamicColors.surfaceLight
                : IslamicColors.surfaceDark,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isFocused
                  ? IslamicColors.goldAmber
                  : IslamicColors.glassBorder,
              width: 1.5,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: IslamicColors.goldAmber.withValues(alpha: 0.2),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _textFieldFocusNode,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            keyboardType: widget.keyboardType,
            style: IslamicTypography.body(color: IslamicColors.textPrimary),
            cursorColor: IslamicColors.goldAmber,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: IslamicTypography.body(color: IslamicColors.textMuted),
              prefixIcon: widget.icon != null
                  ? Icon(
                      widget.icon,
                      color: isFocused
                          ? IslamicColors.goldAmber
                          : IslamicColors.textSecondary,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: 16.h,
                horizontal: 16.w,
              ),
            ),
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
          ),
        );
      },
    );
  }
}
