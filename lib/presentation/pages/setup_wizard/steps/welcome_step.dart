import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/islamic_colors.dart';
import '../../../../core/theme/islamic_typography.dart';
import '../../../cubits/setup_wizard/setup_wizard_cubit.dart';
import '../../../widgets/focusable_widget.dart';
import '../../../widgets/glassmorphism_card.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo / Icon
                  ClipOval(
                    child: SizedBox(
                      width: 120.w,
                      height: 120.w,
                      child: Image.asset(
                        'assets/images/mktv_icon_large.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Title
                  Text(
                    'Miqotul Khoir TV',
                    style: IslamicTypography.display(
                      color: IslamicColors.goldAmber,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),

                  // Subtitle
                  Text(
                    'Sistem Informasi & Jadwal Sholat Digital',
                    style: IslamicTypography.heading(
                      color: IslamicColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 48.h),

                  // Description
                  SizedBox(
                    width: 600.w,
                    child: Text(
                      'Selamat datang! Setup Wizard ini akan membantu Anda mengkonfigurasi nama masjid, lokasi, dan metode perhitungan waktu sholat untuk pertama kali.',
                      style: IslamicTypography.body(
                        color: IslamicColors.textMuted,
                      ).copyWith(height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 64.h),

                  // Start Button
                  FocusableWidget(
                    autofocus:
                        true, // Auto-focus here so user can just press Enter
                    onSelect: () {
                      context.read<SetupWizardCubit>().goToNextStep();
                    },
                    builder: (isFocused) {
                      return SizedBox(
                        width: 280.w,
                        height: 64.h,
                        child: GlassmorphismCard(
                          backgroundColor: isFocused
                              ? IslamicColors.goldAmber.withValues(alpha: 0.8)
                              : IslamicColors.glassWhite.withValues(alpha: 0.2),
                          borderColor: isFocused
                              ? IslamicColors.lightGold
                              : IslamicColors.glassBorder,
                          child: Center(
                            child: Text(
                              'Mulai Setup',
                              style: IslamicTypography.title(
                                color: isFocused
                                    ? IslamicColors.deepTeal
                                    : IslamicColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
