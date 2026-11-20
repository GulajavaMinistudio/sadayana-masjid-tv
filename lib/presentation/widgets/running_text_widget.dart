import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marquee/marquee.dart';

import '../../core/theme/islamic_typography.dart';
import 'glassmorphism_card.dart';

/// Widget ticker text yang scroll horizontal terus-menerus (marquee effect).
///
/// Menggunakan package `marquee` untuk continuous horizontal scrolling.
/// Jika [text] kosong, mengembalikan [SizedBox.shrink()] (TASK-019).
///
/// Opsional: menampilkan [GlassmorphismCard] sebagai background wrapper
/// via [showBackground] parameter (TASK-020).
///
/// Ref: Plan 04 TASK-017 s.d. TASK-020
class RunningTextWidget extends StatelessWidget {
  /// Teks yang akan di-scroll. Jika kosong, widget tidak ditampilkan.
  final String text;

  /// Style teks. Default: [IslamicTypography.body()].
  final TextStyle? textStyle;

  /// Kecepatan scroll dalam pixel per detik. Default: 30.0 (Phase 3).
  final double scrollSpeed;

  /// Jarak kosong setelah teks sebelum teks diulang. Default: 100.w.
  final double? blankSpace;

  /// Jeda sebelum mulai scroll ulang. Default: [Duration.zero] (continuous).
  final Duration pauseDuration;

  /// Jika true, menampilkan [GlassmorphismCard] sebagai background. Default: true.
  final bool showBackground;

  /// Tinggi widget dalam logical pixels (akan di-scale via `.h`). Default: 48.
  final double height;

  const RunningTextWidget({
    super.key,
    required this.text,
    this.textStyle,
    this.scrollSpeed = 30.0, // Phase 3: default scrollSpeed lebih rendah
    this.blankSpace,
    this.pauseDuration = Duration.zero,
    this.showBackground = true,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    // Guard: jika teks kosong, jangan tampilkan apapun (TASK-019)
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    final effectiveTextStyle = textStyle ?? IslamicTypography.body();
    final effectiveBlankSpace = blankSpace ?? 100.w;

    final marqueeWidget = SizedBox(
      height: height.h,
      child: Marquee(
        key: ValueKey(text),
        text: text,
        style: effectiveTextStyle,
        scrollAxis: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        blankSpace: effectiveBlankSpace,
        velocity: scrollSpeed,
        pauseAfterRound: pauseDuration,
        startPadding: 0,
        accelerationDuration: const Duration(seconds: 1),
        accelerationCurve: Curves.linear,
        decelerationDuration: const Duration(milliseconds: 500),
        decelerationCurve: Curves.easeOut,
      ),
    );

    if (showBackground) {
      return GlassmorphismCard(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: marqueeWidget,
      );
    }

    return marqueeWidget;
  }
}
