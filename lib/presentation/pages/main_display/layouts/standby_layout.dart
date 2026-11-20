import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/islamic_colors.dart';
import '../../../../core/theme/islamic_typography.dart';
import '../../../../domain/entities/display_state.dart';
import '../../../../domain/entities/settings.dart';
import '../../../cubits/settings/settings_cubit.dart';
import '../../../cubits/settings/settings_state.dart';
import '../../../widgets/digital_clock_widget.dart';
import '../../../widgets/glassmorphism_card.dart';
import '../../../widgets/header_widget.dart';
import '../../../widgets/prayer_cards_row.dart';
import '../../../widgets/running_text_widget.dart';
import '../../../widgets/treasury_info_widget.dart';

class StandbyLayout extends StatelessWidget {
  final StandbyState state;
  final bool isSettingsVisible;

  const StandbyLayout({
    super.key,
    required this.state,
    this.isSettingsVisible = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        // Baca data masjid dari SettingsCubit jika sudah loaded
        String mosqueName = 'Masjid Anda';
        String mosqueAddress = '';
        String? runningText = state.runningText;

        if (settingsState is SettingsLoaded) {
          final s = settingsState.settings;
          if (s.mosqueName.isNotEmpty) mosqueName = s.mosqueName;
          mosqueAddress = s.mosqueAddress;
          // Prioritaskan runningText dari state, fallback ke settings
          runningText ??= s.runningText;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HEADER
            HeaderWidget(
              mosqueName: mosqueName,
              mosqueAddress: mosqueAddress,
              hijriDate: state.hijriDate ?? '',
              currentTime: state.currentTime,
              isSettingsVisible: isSettingsVisible,
            ),

            SizedBox(height: 32.h),

            // BODY
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Kiri: Jam Besar
                  // RepaintBoundary mengisolasi jam dari repaint area body lain
                  // saat update detik setiap 1 detik (GUD-001).
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: RepaintBoundary(
                        // TASK-010: DigitalClockWidget kini self-contained (StatefulWidget),
                        // tidak lagi menerima currentTime dari state cubit.
                        child: DigitalClockWidget(),
                      ),
                    ),
                  ),

                  // Kanan: Info Panel / Next Prayer
                  Expanded(
                    flex: 4,
                    child: _buildInfoPanel(
                      settingsState is SettingsLoaded
                          ? settingsState.settings
                          : null,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // PRAYER CARDS
            if (state.dailyPrayerTimes != null)
              PrayerCardsRow(
                prayers: state.dailyPrayerTimes!.allPrayers,
                nextPrayer: state.nextPrayer,
              ),

            SizedBox(height: 24.h),

            // FOOTER / RUNNING TEXT
            // Diekstrak ke _StandbyRunningTextFooter agar terisolasi dari
            // rebuild timer 1-detik DisplayStateCubit (TASK-008, TASK-009).
            _StandbyRunningTextFooter(runningText: runningText),
          ],
        );
      },
    );
  }

  Widget _buildInfoPanel(Settings? settings) {
    if (state.nextPrayer == null || state.timeToNextPrayer == null) {
      return const SizedBox.shrink();
    }

    final duration = state.timeToNextPrayer!;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    String timeRemainingStr = '';
    if (hours > 0) {
      timeRemainingStr = '$hours Jam $minutes Menit';
    } else {
      timeRemainingStr = '$minutes Menit';
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: constraints.maxWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassmorphismCard(
                  padding: EdgeInsets.all(40.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label kecil
                      Text(
                        'Sholat Berikutnya',
                        style: IslamicTypography.subtitle(
                          color: IslamicColors.textSecondary,
                        ).copyWith(fontSize: 34.sp),
                      ),
                      SizedBox(height: 20.h),
                      // Nama sholat — paling dominan
                      Text(
                        state.nextPrayer!.name,
                        style: IslamicTypography.heading(
                          color: IslamicColors.goldAmber,
                          fontWeight: FontWeight.bold,
                        ).copyWith(fontSize: 84.sp),
                      ),
                      SizedBox(height: 12.h),
                      // Countdown
                      Text(
                        'Dalam waktu $timeRemainingStr',
                        style: IslamicTypography.body(
                          color: IslamicColors.textPrimary,
                        ).copyWith(fontSize: 36.sp),
                      ),
                      SizedBox(height: 28.h),
                      // Waktu masuk
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 32.w,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            'Masuk pada ${state.nextPrayer!.formattedTime}',
                            style: IslamicTypography.body(
                              color: Colors.white,
                            ).copyWith(fontSize: 30.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (settings != null && settings.isTreasuryEnabled) ...[
                  SizedBox(height: 24.h),
                  TreasuryInfoWidget(
                    balance: settings.treasuryBalance,
                    income: settings.treasuryIncome,
                    expense: settings.treasuryExpense,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Widget footer running text yang terisolasi dari rebuild [DisplayStateCubit].
///
/// Menerima [runningText] sebagai `final` parameter — Flutter element
/// reconciliation mempertahankan elemen `RepaintBoundary` dan `Marquee`
/// (via [ValueKey]) selama nilai teks tidak berubah, sehingga animasi
/// marquee tidak terganggu oleh timer tick 1-detik dari [DisplayStateCubit].
///
/// Ref: Plan refactor-running-text-performance-1 TASK-008, TASK-009.
class _StandbyRunningTextFooter extends StatelessWidget {
  final String? runningText;

  const _StandbyRunningTextFooter({required this.runningText});

  @override
  Widget build(BuildContext context) {
    // Jika tidak ada teks, tampilkan spacer dengan tinggi sama agar layout
    // Column tidak bergeser saat teks kosong.
    if (runningText == null || runningText!.isEmpty) {
      return SizedBox(height: 60.h);
    }

    // RepaintBoundary mengisolasi animasi marquee dari repaint area statis
    // di atasnya (prayer cards, header). Container solid menggantikan
    // GlassmorphismCard agar tidak ada BackdropFilter di atas animasi (GUD-002).
    return RepaintBoundary(
      child: SizedBox(
        height: 60.h,
        child: Container(
          decoration: BoxDecoration(
            color: IslamicColors.glassWhite,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: IslamicColors.glassBorder, width: 1.w),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Center(
            child: RunningTextWidget(
              text: runningText!,
              showBackground: false,
              textStyle: IslamicTypography.body().copyWith(
                color: IslamicColors.goldAmber,
                fontSize: 28.sp,
              ),
              scrollSpeed: 30.0,
            ),
          ),
        ),
      ),
    );
  }
}
