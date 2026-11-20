import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/islamic_colors.dart';
import '../../../../core/theme/islamic_typography.dart';
import '../../../../domain/entities/display_state.dart';
import '../../../cubits/settings/settings_cubit.dart';
import '../../../cubits/settings/settings_state.dart';
import '../../../widgets/countdown_timer_widget.dart';
import '../../../widgets/glassmorphism_card.dart';
import '../../../widgets/header_widget.dart';
import '../../../widgets/prayer_cards_row.dart';

class PreAdzanLayout extends StatelessWidget {
  final PreAdzanState state;
  final bool isSettingsVisible;

  const PreAdzanLayout({
    super.key,
    required this.state,
    this.isSettingsVisible = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        String mosqueName = 'Masjid Anda';
        String mosqueAddress = '';
        if (settingsState is SettingsLoaded) {
          final s = settingsState.settings;
          if (s.mosqueName.isNotEmpty) mosqueName = s.mosqueName;
          mosqueAddress = s.mosqueAddress;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HEADER
            HeaderWidget(
              mosqueName: mosqueName,
              mosqueAddress: mosqueAddress,
              hijriDate: state.dailyPrayerTimes.hijriDate,
              currentTime: DateTime.now(),
              isSettingsVisible: isSettingsVisible,
            ),

            SizedBox(height: 32.h),

            // BODY
            Expanded(
              child: Center(
                child: GlassmorphismCard(
                  backgroundColor: IslamicColors.preAdzanColor.withValues(
                    alpha: 0.8,
                  ),
                  borderColor: IslamicColors.goldAmber,
                  padding: EdgeInsets.symmetric(
                    horizontal: 64.w,
                    vertical: 48.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CountdownTimerWidget(
                        duration: state.remainingDuration,
                        label:
                            'Persiapan Menuju Sholat ${state.upcomingPrayer.name}',
                        color: IslamicColors.goldAmber,
                        labelColor: Colors.white,
                        labelStyle: IslamicTypography.heading(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ).copyWith(letterSpacing: 2.w),
                        timerStyle:
                            IslamicTypography.display(
                              color: IslamicColors.goldAmber,
                              fontWeight: FontWeight.bold,
                            ).copyWith(
                              fontSize: 120.sp,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                        progress: state.progress,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 32.h),

            // PRAYER CARDS
            PrayerCardsRow(
              prayers: state.dailyPrayerTimes.allPrayers,
              nextPrayer: state.upcomingPrayer,
            ),

            SizedBox(height: 84.h), // Spacing for footer area
          ],
        );
      },
    );
  }
}
