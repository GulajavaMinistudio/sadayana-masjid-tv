import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/islamic_colors.dart';
import '../../../../core/theme/islamic_typography.dart';
import '../../../cubits/settings/settings_cubit.dart';
import '../../../cubits/settings/settings_state.dart';
import '../../../widgets/dpad_stepper.dart';
import '../../../widgets/focusable_widget.dart';

/// Section pengaturan Mode Hemat Daya Tengah Malam.
///
/// Menampilkan toggle aktif/nonaktif, konfigurasi jam mulai dan berakhir,
/// serta info bar ringkas rentang waktu aktif.
/// Semua perubahan disimpan otomatis via [SettingsCubit].
///
/// Ref: Plan prd-plan-midnight-feature.md Phase 6 (TASK-025 s.d. TASK-028)
class MidnightModeSection extends StatelessWidget {
  const MidnightModeSection({super.key});

  /// Format integer ke string dua digit (e.g. 3 → '03').
  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        if (state is! SettingsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final settings = state.settings;
        final cubit = context.read<SettingsCubit>();
        final enabled = settings.isMidnightModeEnabled;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ─────────────────────────────────────────────────── //
            Row(
              children: [
                Icon(
                  Icons.nightlight_round,
                  color: IslamicColors.goldAmber,
                  size: 28.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Mode Hemat Daya Malam',
                  style: IslamicTypography.heading(),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Alihkan tampilan ke mode minimal (jam + jadwal sholat) '
              'pada rentang waktu tengah malam untuk menghemat daya layar.',
              style: IslamicTypography.subtitle(
                color: IslamicColors.textSecondary,
              ),
            ),
            SizedBox(height: 32.h),

            // ─── Toggle: Aktifkan Mode Hemat Daya ────────────────────────── //
            FocusableWidget(
              autofocus: true,
              onSelect: () => cubit.updateMidnightModeEnabled(
                !settings.isMidnightModeEnabled,
              ),
              builder: (isFocused) => Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: IslamicColors.glassWhite,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isFocused
                        ? IslamicColors.goldAmber
                        : IslamicColors.glassBorder,
                    width: isFocused ? 2.0 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Aktifkan Mode Hemat Daya',
                      style: IslamicTypography.body(
                        color: IslamicColors.textPrimary,
                      ),
                    ),
                    Switch.adaptive(
                      value: settings.isMidnightModeEnabled,
                      onChanged: null,
                      activeThumbColor: IslamicColors.goldAmber,
                      activeTrackColor: IslamicColors.goldAmber.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // ─── Config area (disabled when toggle off) ──────────────────── //
            Expanded(
              child: ExcludeFocus(
                excluding: !enabled,
                child: IgnorePointer(
                  ignoring: !enabled,
                  child: Opacity(
                    opacity: enabled ? 1.0 : 0.4,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Jam Mulai label
                          Text(
                            'Jam Mulai',
                            style: IslamicTypography.body(
                              color: IslamicColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // Jam & Menit Mulai — TASK-026
                          DPadStepper(
                            label: 'Jam Mulai',
                            value: settings.midnightStartHour,
                            minValue: 0,
                            maxValue: 23,
                            suffix: '',
                            onChanged: cubit.updateMidnightStartHour,
                          ),
                          SizedBox(height: 12.h),
                          DPadStepper(
                            label: 'Menit Mulai',
                            value: settings.midnightStartMinute,
                            minValue: 0,
                            maxValue: 59,
                            step: 5,
                            suffix: '',
                            onChanged: cubit.updateMidnightStartMinute,
                          ),
                          SizedBox(height: 24.h),

                          Divider(color: IslamicColors.glassBorder),
                          SizedBox(height: 16.h),

                          // Jam Berakhir label
                          Text(
                            'Jam Berakhir',
                            style: IslamicTypography.body(
                              color: IslamicColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // Jam & Menit Berakhir — TASK-026
                          DPadStepper(
                            label: 'Jam Berakhir',
                            value: settings.midnightEndHour,
                            minValue: 0,
                            maxValue: 23,
                            suffix: '',
                            onChanged: cubit.updateMidnightEndHour,
                          ),
                          SizedBox(height: 12.h),
                          DPadStepper(
                            label: 'Menit Berakhir',
                            value: settings.midnightEndMinute,
                            minValue: 0,
                            maxValue: 59,
                            step: 5,
                            suffix: '',
                            onChanged: cubit.updateMidnightEndMinute,
                          ),
                          SizedBox(height: 24.h),

                          Divider(color: IslamicColors.glassBorder),
                          SizedBox(height: 16.h),

                          // Info bar — TASK-026
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: IslamicColors.glassWhite,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: IslamicColors.glassBorder,
                              ),
                            ),
                            child: Text(
                              'ℹ Aktif setiap hari: '
                              '${_pad(settings.midnightStartHour)}:'
                              '${_pad(settings.midnightStartMinute)} – '
                              '${_pad(settings.midnightEndHour)}:'
                              '${_pad(settings.midnightEndMinute)}',
                              style: IslamicTypography.caption(
                                color: IslamicColors.textSecondary,
                              ),
                            ),
                          ),
                          SizedBox(height: 32.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
