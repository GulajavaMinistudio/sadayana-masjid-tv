import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../core/theme/islamic_colors.dart';
import '../../core/theme/islamic_typography.dart';

// TASK-010 (Phase 5): Dikonversi ke StatefulWidget dengan Timer.periodic internal.
// Widget kini self-contained — tidak lagi menerima currentTime dari luar,
// sehingga StandbyLayout aman di-skip rebuild setiap detik via buildWhen.
class DigitalClockWidget extends StatefulWidget {
  final TextStyle? customStyle;

  const DigitalClockWidget({super.key, this.customStyle});

  @override
  State<DigitalClockWidget> createState() => _DigitalClockWidgetState();
}

class _DigitalClockWidgetState extends State<DigitalClockWidget> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeString = DateFormat('HH:mm').format(_now);
    final secondsString = DateFormat('ss').format(_now);

    // Ukuran besar untuk TV 1920×1080 — jam utama 210sp, detik 105sp
    final mainStyle =
        widget.customStyle ??
        IslamicTypography.display().copyWith(
          fontSize: 210.sp,
          fontWeight: FontWeight.w700,
          color: IslamicColors.textPrimary,
          letterSpacing: -2,
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(timeString, style: mainStyle),
        Text(
          ':$secondsString',
          style: mainStyle.copyWith(
            fontSize: (mainStyle.fontSize ?? 180.sp) * 0.5,
            color: IslamicColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
