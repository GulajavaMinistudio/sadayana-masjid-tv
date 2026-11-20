import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/islamic_colors.dart';
import '../../core/theme/islamic_typography.dart';

class CountdownTimerWidget extends StatelessWidget {
  final Duration duration;
  final String label;
  final TextStyle? timerStyle;
  final TextStyle? labelStyle;
  final Color? color;
  final Color? labelColor;
  final double progress; // 0.0 to 1.0

  const CountdownTimerWidget({
    super.key,
    required this.duration,
    required this.label,
    this.timerStyle,
    this.labelStyle,
    this.color,
    this.labelColor,
    this.progress = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final highlightColor = color ?? IslamicColors.goldAmber;

    String timeStr;
    if (hours > 0) {
      timeStr =
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      timeStr =
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label.toUpperCase(),
          style:
              labelStyle ??
              IslamicTypography.subtitle(
                color: labelColor ?? IslamicColors.textSecondary,
                fontWeight: FontWeight.w600,
              ).copyWith(letterSpacing: 2.w),
        ),
        SizedBox(height: 16.h),
        Stack(
          alignment: Alignment.center,
          children: [
            // Progress indikator melingkar jika dibutuhkan, tapi untuk TV teks lebih dominan
            // Kita tampilkan progress bar di bawah teks saja.
            Text(
              timeStr,
              style:
                  timerStyle ??
                  IslamicTypography.display(color: highlightColor).copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        // Linear Progress
        SizedBox(
          width: 300.w,
          height: 8.h,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: IslamicColors.surfaceDark,
              valueColor: AlwaysStoppedAnimation<Color>(highlightColor),
            ),
          ),
        ),
      ],
    );
  }
}
