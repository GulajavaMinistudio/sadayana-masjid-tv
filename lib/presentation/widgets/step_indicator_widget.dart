import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/islamic_colors.dart';
import '../../../core/theme/islamic_typography.dart';

/// Widget indikator langkah (Step Indicator) untuk Setup Wizard.
///
/// Menampilkan row of circles yang merepresentasikan progress wizard.
/// - Step yang sudah selesai: Solid Gold.
/// - Step saat ini: Outlined Gold dengan glow effect.
/// - Step belum dilalui: Outlined Grey/Muted.
///
/// Design mengikuti Islamic Glassmorphism dengan warna dari [IslamicColors].
class StepIndicatorWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? stepLabels;

  const StepIndicatorWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        // Status step: completed, active, or upcoming
        final isCompleted = index < currentStep;
        final isActive = index == currentStep;

        return Row(
          children: [
            // Connector Line (sebelum dot, kecuali untuk item pertama)
            if (index > 0)
              Container(
                width: 40.w,
                height: 2.h,
                color: (index <= currentStep)
                    ? IslamicColors.goldAmber
                    : IslamicColors.glassBorder,
              ),

            // Step Dot & Label
            _buildStepDot(context, index, isActive, isCompleted),
          ],
        );
      }),
    );
  }

  Widget _buildStepDot(
    BuildContext context,
    int index,
    bool isActive,
    bool isCompleted,
  ) {
    // Determine colors based on state
    final Color dotColor = isCompleted
        ? IslamicColors.goldAmber
        : (isActive ? IslamicColors.goldAmber : Colors.transparent);

    final Color borderColor = isCompleted || isActive
        ? IslamicColors.goldAmber
        : IslamicColors.glassBorder;

    final double size = isActive ? 32.w : 24.w;

    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dotColor.withValues(
          alpha: isActive ? 0.2 : (isCompleted ? 1.0 : 0.0),
        ),
        border: Border.all(color: borderColor, width: 2.0),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: IslamicColors.goldAmber.withValues(alpha: 0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: isCompleted
            ? Icon(Icons.check, color: IslamicColors.deepTeal, size: 14.w)
            : Text(
                '${index + 1}',
                style: IslamicTypography.overline(
                  color: isActive || isCompleted
                      ? IslamicColors.textPrimary
                      : IslamicColors.textMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
