import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/islamic_typography.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/islamic_colors.dart';
import '../../../cubits/settings/settings_cubit.dart';
import '../../../cubits/settings/settings_state.dart';
import '../../../widgets/dpad_stepper.dart';

class IhtiyatSection extends StatelessWidget {
  const IhtiyatSection({super.key});

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
            Text('Koreksi Waktu (Ihtiyat)', style: IslamicTypography.heading()),
            SizedBox(height: 8.h),
            Text(
              'Sesuaikan waktu sholat untuk keperluan ikhtiyat (kehati-hatian). Penambahan/pengurangan dalam menit.',
              style: IslamicTypography.subtitle(
                color: IslamicColors.textSecondary,
              ),
            ),
            SizedBox(height: 32.h),
            Expanded(
              child: ListView(
                children: [
                  _buildStepper('Subuh', settings.offsetSubuh, cubit),
                  SizedBox(height: 16.h),
                  _buildStepper('Syuruq', settings.offsetSyuruq, cubit),
                  SizedBox(height: 16.h),
                  _buildStepper('Dhuha', settings.offsetDhuha, cubit),
                  SizedBox(height: 16.h),
                  _buildStepper('Dzuhur', settings.offsetDzuhur, cubit),
                  SizedBox(height: 16.h),
                  _buildStepper('Ashar', settings.offsetAshar, cubit),
                  SizedBox(height: 16.h),
                  _buildStepper('Maghrib', settings.offsetMaghrib, cubit),
                  SizedBox(height: 16.h),
                  _buildStepper('Isya', settings.offsetIsya, cubit),
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
      minValue: -30,
      maxValue: 30,
      suffix: 'menit',
      onChanged: (val) {
        cubit.updateIhtiyatOffset(prayerName.toLowerCase(), val);
      },
    );
  }
}
