import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/islamic_typography.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/islamic_colors.dart';
import '../../../cubits/settings/settings_cubit.dart';
import '../../../cubits/settings/settings_state.dart';
import '../../../widgets/dpad_stepper.dart';

class DisplayTimingSection extends StatelessWidget {
  const DisplayTimingSection({super.key});

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
            Text('Durasi Tampilan', style: IslamicTypography.heading()),
            SizedBox(height: 8.h),
            Text(
              'Atur durasi transisi setiap state pada layar (Pre-Adzan, Adzan, Sholat) serta kalibrasi tanggal Hijriyah.',
              style: IslamicTypography.subtitle(
                color: IslamicColors.textSecondary,
              ),
            ),
            SizedBox(height: 32.h),
            Expanded(
              child: ListView(
                children: [
                  DPadStepper(
                    label: 'Pre-Adzan (Persiapan)',
                    value: settings.preAdzanMinutes,
                    minValue: 5,
                    maxValue: 30,
                    suffix: 'menit',
                    onChanged: (val) {
                      cubit.updatePreAdzanMinutes(val);
                    },
                  ),
                  SizedBox(height: 16.h),
                  DPadStepper(
                    label: 'Tampilan Waktu Adzan',
                    value: settings.adzanDurationSeconds,
                    minValue: 60,
                    maxValue: 600,
                    step: 10,
                    suffix: 'detik',
                    onChanged: (val) {
                      cubit.updateAdzanDuration(val);
                    },
                  ),
                  SizedBox(height: 16.h),
                  DPadStepper(
                    label: 'Durasi Layar Hitam (Saat Sholat)',
                    value: settings.sholatDurationMinutes,
                    minValue: 10,
                    maxValue: 45,
                    step: 5,
                    suffix: 'menit',
                    onChanged: (val) {
                      cubit.updateSholatDuration(val);
                    },
                  ),
                  SizedBox(height: 16.h),
                  DPadStepper(
                    label: "Durasi Layar Hitam Jum'at (Khutbah + Sholat)",
                    value: settings.sholatJumatDurationMinutes,
                    minValue: 10,
                    maxValue: 90,
                    step: 5,
                    suffix: 'menit',
                    onChanged: (val) {
                      cubit.updateSholatJumatDuration(val);
                    },
                  ),
                  SizedBox(height: 16.h),
                  DPadStepper(
                    label: 'Kalibrasi Tanggal Hijriyah',
                    value: settings.hijriAdjustment,
                    minValue: -2,
                    maxValue: 2,
                    suffix: 'hari',
                    onChanged: (val) {
                      cubit.updateHijriAdjustment(val);
                    },
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
