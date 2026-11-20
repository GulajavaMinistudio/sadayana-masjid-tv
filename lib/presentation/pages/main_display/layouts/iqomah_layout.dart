import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/islamic_colors.dart';
import '../../../../core/theme/islamic_typography.dart';
import '../../../../domain/entities/display_state.dart';
import '../../../widgets/glassmorphism_card.dart';
import '../../../widgets/countdown_timer_widget.dart';

/// Layout khusus saat Countdown Iqomah
class IqomahLayout extends StatelessWidget {
  final IqomahState state;

  const IqomahLayout({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassmorphismCard(
        backgroundColor: IslamicColors.iqomahColor.withValues(alpha: 0.85),
        borderColor: IslamicColors.goldAmber,
        padding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 80.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Nama Sholat
            Text(
              'MENUJU SHOLAT BERJAMAAH',
              style: IslamicTypography.heading(
                color: IslamicColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),

            Text(
              state.currentPrayer.name.toUpperCase(),
              style: IslamicTypography.display(
                color: IslamicColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 64.h),

            // Countdown Iqomah
            CountdownTimerWidget(
              duration: state.remainingDuration,
              label: 'Waktu Iqomah',
              color: Colors.white,
              labelColor: Colors.white,
              labelStyle: IslamicTypography.heading(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ).copyWith(letterSpacing: 2.w),
              timerStyle:
                  IslamicTypography.display(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ).copyWith(
                    fontSize: 150.sp,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
              progress: state.progress,
            ),
            SizedBox(height: 48.h),

            Text(
              'Luruskan dan Rapatkan Shaf',
              style: IslamicTypography.heading(
                color: IslamicColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
