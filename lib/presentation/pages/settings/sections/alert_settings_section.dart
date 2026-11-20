import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/islamic_colors.dart';
import '../../../../core/theme/islamic_typography.dart';
import '../../../cubits/settings/settings_cubit.dart';
import '../../../cubits/settings/settings_state.dart';
import '../../../widgets/dpad_stepper.dart';
import '../../../widgets/focusable_widget.dart';

/// Section pengaturan Alarm Tanda Waktu (Pre-Adzan & Pre-Iqomah Alert).
///
/// Menampilkan dua pasang toggle + DPadStepper: satu untuk alarm sebelum
/// Adzan, dan satu untuk alarm sebelum Iqomah selesai.
/// DPadStepper hanya aktif saat toggle terkait dalam kondisi ON.
/// Semua perubahan disimpan otomatis via [SettingsCubit].
///
/// Ref: Plan feature-alarm-alert-1.md Phase 5 (TASK-021 s.d. TASK-023)
class AlertSettingsSection extends StatelessWidget {
  const AlertSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        if (state is! SettingsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final settings = state.settings;
        final cubit = context.read<SettingsCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ─────────────────────────────────────────────────── //
            Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: IslamicColors.goldAmber,
                  size: 28.sp,
                ),
                SizedBox(width: 12.w),
                Text('Alarm Tanda Waktu', style: IslamicTypography.heading()),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Bunyikan alarm pendek beberapa detik sebelum adzan '
              'dan/atau sebelum iqomah selesai sebagai tanda pengingat.',
              style: IslamicTypography.subtitle(
                color: IslamicColors.textSecondary,
              ),
            ),
            SizedBox(height: 32.h),

            // ─── Konten Scrollable ───────────────────────────────────────── //
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Blok Pre-Adzan ───────────────────────────────────── //
                    Text(
                      'Pre-Adzan',
                      style: IslamicTypography.body(
                        color: IslamicColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Toggle: Aktifkan Alarm Sebelum Adzan
                    FocusableWidget(
                      autofocus: true,
                      onSelect: () => cubit.updatePreAdzanAlertEnabled(
                        !settings.isPreAdzanAlertEnabled,
                      ),
                      builder: (isFocused) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 14.h,
                        ),
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
                              'Aktifkan Alarm Sebelum Adzan',
                              style: IslamicTypography.body(
                                color: IslamicColors.textPrimary,
                              ),
                            ),
                            Switch.adaptive(
                              value: settings.isPreAdzanAlertEnabled,
                              onChanged: null,
                              activeThumbColor: IslamicColors.goldAmber,
                              activeTrackColor: IslamicColors.goldAmber
                                  .withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // DPadStepper Pre-Adzan — disabled saat toggle OFF
                    ExcludeFocus(
                      excluding: !settings.isPreAdzanAlertEnabled,
                      child: IgnorePointer(
                        ignoring: !settings.isPreAdzanAlertEnabled,
                        child: Opacity(
                          opacity: settings.isPreAdzanAlertEnabled ? 1.0 : 0.4,
                          child: DPadStepper(
                            label: 'Durasi Alarm Pre-Adzan',
                            value: settings.preAdzanAlertSeconds,
                            minValue: 5,
                            maxValue: 15,
                            suffix: 'detik',
                            onChanged: cubit.updatePreAdzanAlertSeconds,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    Divider(color: IslamicColors.glassBorder),
                    SizedBox(height: 16.h),

                    // ── Blok Pre-Iqomah ──────────────────────────────────── //
                    Text(
                      'Pre-Iqomah',
                      style: IslamicTypography.body(
                        color: IslamicColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Toggle: Aktifkan Alarm Sebelum Iqomah
                    FocusableWidget(
                      onSelect: () => cubit.updatePreIqomahAlertEnabled(
                        !settings.isPreIqomahAlertEnabled,
                      ),
                      builder: (isFocused) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 14.h,
                        ),
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
                              'Aktifkan Alarm Sebelum Iqomah',
                              style: IslamicTypography.body(
                                color: IslamicColors.textPrimary,
                              ),
                            ),
                            Switch.adaptive(
                              value: settings.isPreIqomahAlertEnabled,
                              onChanged: null,
                              activeThumbColor: IslamicColors.goldAmber,
                              activeTrackColor: IslamicColors.goldAmber
                                  .withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // DPadStepper Pre-Iqomah — disabled saat toggle OFF
                    ExcludeFocus(
                      excluding: !settings.isPreIqomahAlertEnabled,
                      child: IgnorePointer(
                        ignoring: !settings.isPreIqomahAlertEnabled,
                        child: Opacity(
                          opacity: settings.isPreIqomahAlertEnabled ? 1.0 : 0.4,
                          child: DPadStepper(
                            label: 'Durasi Alarm Pre-Iqomah',
                            value: settings.preIqomahAlertSeconds,
                            minValue: 5,
                            maxValue: 15,
                            suffix: 'detik',
                            onChanged: cubit.updatePreIqomahAlertSeconds,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
