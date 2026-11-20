import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/islamic_typography.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/islamic_colors.dart';
import '../../../cubits/settings/settings_cubit.dart';
import '../../../cubits/settings/settings_state.dart';
import '../../../widgets/dpad_stepper.dart';

class DhuhaSection extends StatelessWidget {
  const DhuhaSection({super.key});

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
            Text('Pengaturan Dhuha', style: IslamicTypography.heading()),
            SizedBox(height: 8.h),
            Text(
              'Tentukan kapan waktu Dhuha dimulai setelah waktu Syuruq.',
              style: IslamicTypography.subtitle(
                color: IslamicColors.textSecondary,
              ),
            ),
            SizedBox(height: 32.h),
            Expanded(
              child: ListView(
                children: [
                  DPadStepper(
                    label: 'Offset Dhuha',
                    value: settings.dhuhaOffsetMinutes,
                    minValue: 10,
                    maxValue: 30,
                    suffix: 'menit setelah Syuruq',
                    onChanged: (val) {
                      cubit.updateDhuhaOffset(val);
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
