import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/islamic_colors.dart';
import '../../../../core/theme/islamic_typography.dart';
import '../../../../domain/entities/display_state.dart';
import '../../../../domain/entities/imam_schedule_display.dart';
import '../../../cubits/settings/settings_cubit.dart';
import '../../../cubits/settings/settings_state.dart';
import '../../../widgets/glassmorphism_card.dart';
import '../../../widgets/header_widget.dart';
import '../../../widgets/islamic_background.dart';

/// Layout full-screen untuk menampilkan Jadwal Imam Sholat Berjamaah.
///
/// Struktur tiga zona:
/// - **Header**: jam digital | tanggal Masehi | tanggal Hijriyah (via [HeaderWidget])
/// - **Body**:  GlassmorphismCard centered — badge hari + tabel 5 slot jadwal imam
/// - **Footer**: progress bar + nama masjid
///
/// Kompatibel dengan 1920×1080 dan 1280×720 via [LayoutBuilder] + [FittedBox].
/// Ref: Plan feature-imam-schedule-1 TASK-036 s.d. TASK-039
class ImamScheduleLayout extends StatelessWidget {
  final ImamScheduleState state;

  const ImamScheduleLayout({super.key, required this.state});

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
                        HeaderWidget(
                          mosqueName: mosqueName,
                          mosqueAddress: mosqueAddress,
                          hijriDate: state.hijriDate,
                          currentTime: state.currentTime,
                        ),
                        SizedBox(height: 24.h),
                        Expanded(child: _buildBody(mosqueName)),
                        SizedBox(height: 16.h),
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

  Widget _buildBody(String mosqueName) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 1400.w,
              maxHeight: constraints.maxHeight,
            ),
            child: GlassmorphismCard(
              padding: EdgeInsets.symmetric(horizontal: 64.w, vertical: 28.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🕌', style: TextStyle(fontSize: 36.sp)),
                      SizedBox(width: 16.w),
                      Text(
                        'JADWAL IMAM SHOLAT',
                        style: IslamicTypography.heading().copyWith(
                          fontSize: 38.sp,
                          fontWeight: FontWeight.bold,
                          color: IslamicColors.goldAmber,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  // Mosque name
                  Text(
                    mosqueName,
                    style: IslamicTypography.subtitle().copyWith(
                      fontSize: 32.sp,
                      color: IslamicColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Day badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 40.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Text(
                      '══  ${state.dayName}  ══',
                      style: IslamicTypography.title().copyWith(
                        fontSize: 36.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Schedule slots
                  ...state.slots.map(_buildSlotRow),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlotRow(ImamScheduleDisplay slot) {
    final isFriday = slot.prayerName == 'jumat';
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prayer label
          SizedBox(
            width: 200.w,
            child: Text(
              slot.prayerLabel,
              style: IslamicTypography.body().copyWith(
                fontSize: 36.sp,
                color: IslamicColors.goldAmber,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Separator
          Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: Text(
              '│',
              style: TextStyle(fontSize: 36.sp, color: IslamicColors.textMuted),
            ),
          ),
          // Imam info
          Expanded(
            child: isFriday
                ? _buildFridayImamInfo(slot)
                : _buildRegularImamInfo(slot),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularImamInfo(ImamScheduleDisplay slot) {
    final name = slot.imamName;
    final hasName = name != null && name.isNotEmpty;
    return Text(
      hasName ? name : 'Imam belum tersedia',
      style: IslamicTypography.body().copyWith(
        fontSize: 36.sp,
        color: hasName ? IslamicColors.textPrimary : IslamicColors.textMuted,
        fontStyle: hasName ? FontStyle.normal : FontStyle.italic,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFridayImamInfo(ImamScheduleDisplay slot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPersonLine(
          label: 'Khatib',
          name: slot.khatibName,
          emptyText: 'Khatib belum tersedia',
        ),
        SizedBox(height: 4.h),
        _buildPersonLine(
          label: 'Imam',
          name: slot.imamName,
          emptyText: 'Imam belum tersedia',
        ),
      ],
    );
  }

  Widget _buildPersonLine({
    required String label,
    String? name,
    required String emptyText,
  }) {
    final hasName = name != null && name.isNotEmpty;
    return Row(
      children: [
        SizedBox(
          width: 160.w,
          child: Text(
            '$label:',
            style: IslamicTypography.body().copyWith(
              fontSize: 34.sp,
              color: IslamicColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            hasName ? name : emptyText,
            style: IslamicTypography.body().copyWith(
              fontSize: 34.sp,
              color: hasName
                  ? IslamicColors.textPrimary
                  : IslamicColors.textMuted,
              fontStyle: hasName ? FontStyle.normal : FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(String mosqueName) {
    final progress = state.totalDurationSeconds > 0
        ? (1.0 - state.remainingSeconds / state.totalDurationSeconds).clamp(
            0.0,
            1.0,
          )
        : 0.0;

    return GlassmorphismCard(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8.h,
                backgroundColor: IslamicColors.glassWhite,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  IslamicColors.goldAmber,
                ),
              ),
            ),
          ),
          SizedBox(width: 24.w),
          Expanded(
            flex: 3,
            child: Text(
              mosqueName,
              style: IslamicTypography.caption().copyWith(
                fontSize: 22.sp,
                color: IslamicColors.textSecondary,
              ),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
