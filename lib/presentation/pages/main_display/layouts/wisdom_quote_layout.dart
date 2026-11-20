import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/islamic_colors.dart';
import '../../../../core/theme/islamic_typography.dart';
import '../../../../domain/entities/display_state.dart';
import '../../../cubits/settings/settings_cubit.dart';
import '../../../cubits/settings/settings_state.dart';
import '../../../widgets/glassmorphism_card.dart';
import '../../../widgets/islamic_background.dart';

/// Layout full-screen untuk menampilkan satu item Kata Mutiara Islam (State ke-6).
///
/// Struktur tiga zona:
/// - **Header**: jam digital kiri | tanggal Masehi tengah | tanggal Hijriyah kanan
/// - **Body**: GlassmorphismCard centered — badge tipe + terjemahan + referensi
/// - **Footer**: progress bar | counter posisi | nama masjid
///
/// Kompatibel dengan 1920×1080 dan 1280×720 via [LayoutBuilder] + [FittedBox].
/// Ref: Plan 07 TASK-030 s.d. TASK-034
class WisdomQuoteLayout extends StatelessWidget {
  final WisdomQuoteState state;

  const WisdomQuoteLayout({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        String mosqueName = 'Masjid Anda';
        if (settingsState is SettingsLoaded) {
          final s = settingsState.settings;
          if (s.mosqueName.isNotEmpty) mosqueName = s.mosqueName;
        }

        return IslamicBackground(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 40.w,
                      vertical: 24.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        SizedBox(height: 32.h),
                        Expanded(child: _buildBody()),
                        SizedBox(height: 24.h),
                        _buildFooter(mosqueName),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Header kompak: jam digital | tanggal Masehi | tanggal Hijriyah
  Widget _buildHeader() {
    final masehiDate = DateFormat(
      'EEEE, dd MMMM yyyy',
      'id_ID',
    ).format(state.currentTime);

    final hijri = HijriCalendar.fromDate(state.currentTime);
    final hijriDate = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} H';

    final timeString = DateFormat('HH:mm').format(state.currentTime);

    return GlassmorphismCard(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Kiri: Jam digital
          Text(
            timeString,
            style: IslamicTypography.heading().copyWith(
              fontSize: 56.sp,
              fontWeight: FontWeight.bold,
              color: IslamicColors.textPrimary,
            ),
          ),

          // Tengah: Tanggal Masehi
          Text(
            masehiDate,
            style: IslamicTypography.subtitle().copyWith(
              fontSize: 30.sp,
              color: IslamicColors.textPrimary,
            ),
          ),

          // Kanan: Tanggal Hijriyah
          Text(
            hijriDate,
            style: IslamicTypography.subtitle().copyWith(
              fontSize: 30.sp,
              color: IslamicColors.goldAmber,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Body: GlassmorphismCard centered berisi badge tipe, terjemahan, referensi.
  Widget _buildBody() {
    final isQuran = state.currentQuote.type == 'quran';
    final badgeColor = isQuran
        ? IslamicColors.primaryTeal
        : IslamicColors.goldAmber;
    final badgeIcon = isQuran ? '🕌' : '📖';

    return Center(
      child: GlassmorphismCard(
        padding: EdgeInsets.symmetric(horizontal: 80.w, vertical: 60.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge oval tipe: teal untuk Quran, amber untuk Hadits
            Container(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(40.r),
                border: Border.all(color: badgeColor, width: 1.5),
              ),
              child: Text(
                '$badgeIcon  ${state.currentQuote.label}',
                style: IslamicTypography.subtitle().copyWith(
                  color: badgeColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 28.sp,
                ),
              ),
            ),

            SizedBox(height: 48.h),

            // Teks terjemahan — large, centered
            Text(
              '"${state.currentQuote.translationText}"',
              style: IslamicTypography.title().copyWith(
                fontSize: 42.sp,
                color: IslamicColors.textPrimary,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32.h),

            // Referensi — caption, max 2 baris
            Text(
              state.currentQuote.reference,
              style: IslamicTypography.caption().copyWith(
                fontSize: 24.sp,
                color: IslamicColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Footer: progress bar | counter posisi | nama masjid
  Widget _buildFooter(String mosqueName) {
    final progress = state.totalDurationSeconds > 0
        ? 1.0 - (state.remainingSeconds / state.totalDurationSeconds)
        : 0.0;

    return GlassmorphismCard(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
      child: Row(
        children: [
          // Progress bar horizontal
          Expanded(
            flex: 7,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 8.h,
                backgroundColor: IslamicColors.glassWhite,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  IslamicColors.primaryTeal,
                ),
              ),
            ),
          ),

          SizedBox(width: 24.w),

          // Counter posisi: "3 / 7"
          Text(
            '${state.currentIndex + 1} / ${state.totalItems}',
            style: IslamicTypography.body().copyWith(
              fontSize: 24.sp,
              color: IslamicColors.textSecondary,
            ),
          ),

          SizedBox(width: 24.w),

          // Nama masjid
          Text(
            mosqueName,
            style: IslamicTypography.body().copyWith(
              fontSize: 24.sp,
              color: IslamicColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
