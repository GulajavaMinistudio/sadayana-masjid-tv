import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/islamic_typography.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/islamic_colors.dart';
import '../../../cubits/settings/settings_cubit.dart';
import '../../../cubits/settings/settings_state.dart';
import '../../../widgets/dpad_stepper.dart';

class IqomahSection extends StatelessWidget {
  const IqomahSection({super.key});

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
            Text('Durasi Iqomah', style: IslamicTypography.heading()),
            SizedBox(height: 8.h),
            Text(
              'Tentukan durasi jeda antara adzan dan iqomah untuk setiap waktu sholat wajib.',
              style: IslamicTypography.subtitle(
                color: IslamicColors.textSecondary,
              ),
            ),
            SizedBox(height: 32.h),
            Expanded(
              child: ListView(
                children: [
                  _buildStepper('Subuh', settings.iqomahSubuh, cubit),
                  SizedBox(height: 16.h),
                  _buildStepper('Dzuhur', settings.iqomahDzuhur, cubit),
                  SizedBox(height: 16.h),
                  _buildStepper("Jum'at", settings.iqomahJumat, cubit),
                  SizedBox(height: 16.h),
                  _buildStepper('Ashar', settings.iqomahAshar, cubit),
                  SizedBox(height: 16.h),
                  _buildStepper('Maghrib', settings.iqomahMaghrib, cubit),
                  SizedBox(height: 16.h),
                  _buildStepper('Isya', settings.iqomahIsya, cubit),
                  SizedBox(height: 32.h), // padding at bottom
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepper(String prayerName, int value, SettingsCubit cubit) {
    return DPadStepper(
      label: prayerName,
      value: value,
      minValue: 1,
      maxValue: 30,
      suffix: 'menit',
      onChanged: (val) {
        cubit.updateIqomahDuration(prayerName.toLowerCase(), val);
      },
    );
  }
}
