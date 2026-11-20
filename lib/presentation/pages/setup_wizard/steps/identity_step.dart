import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/islamic_colors.dart';
import '../../../../core/theme/islamic_typography.dart';
import '../../../../domain/entities/setup_wizard_data.dart';
import '../../../cubits/setup_wizard/setup_wizard_cubit.dart';
import '../../../cubits/setup_wizard/setup_wizard_state.dart';
import '../../../widgets/focusable_text_field.dart';
import '../../../widgets/focusable_widget.dart';
import '../../../widgets/glassmorphism_card.dart';

class IdentityStep extends StatefulWidget {
  const IdentityStep({super.key});

  @override
  State<IdentityStep> createState() => _IdentityStepState();
}

class _IdentityStepState extends State<IdentityStep> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<SetupWizardCubit>();
    final state = cubit.state;
    final data = (state is SetupWizardInProgress)
        ? state.data
        : const SetupWizardData();

    _nameController = TextEditingController(text: data.mosqueName);
    _addressController = TextEditingController(text: data.mosqueAddress);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SetupWizardCubit, SetupWizardState>(
      listener: (context, state) {
        if (state is SetupWizardInProgress) {
          // Sync text field if state updated externally (optional, but good practice)
          if (_nameController.text != state.data.mosqueName) {
            _nameController.text = state.data.mosqueName;
          }
        }
      },
      builder: (context, state) {
        String? errorText;
        if (state is SetupWizardInProgress) {
          errorText = state.validationError;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // Tambahkan bottom padding sebesar tinggi keyboard agar semua
            // konten (termasuk tombol navigasi) bisa di-scroll ke atas keyboard.
            final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: ConstrainedBox(
                // Kurangi minHeight dengan keyboardHeight agar Column tidak
                // mem-push konten ke bawah viewport saat keyboard muncul.
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - keyboardHeight,
                ),
                child: Center(
                  child: SizedBox(
                    width: 700.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Identitas Masjid',
                          style: IslamicTypography.heading(
                            color: IslamicColors.goldAmber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Masukkan nama dan alamat masjid Anda agar jamaah mengetahui informasi yang akurat.',
                          style: IslamicTypography.body(
                            color: IslamicColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 48.h),

                        // Form Container
                        GlassmorphismCard(
                          child: Padding(
                            padding: EdgeInsets.all(32.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nama Masjid Field
                                _buildLabel('Nama Masjid'),
                                SizedBox(height: 8.h),
                                FocusableTextField(
                                  controller: _nameController,
                                  hintText: 'Contoh: Masjid Raya Bandung',
                                  icon: Icons.mosque_rounded,
                                  autofocus: true,
                                  onChanged: (val) => context
                                      .read<SetupWizardCubit>()
                                      .updateMosqueName(val),
                                ),
                                SizedBox(height: 24.h),

                                // Alamat Masjid Field
                                _buildLabel('Alamat Lengkap'),
                                SizedBox(height: 8.h),
                                FocusableTextField(
                                  controller: _addressController,
                                  hintText: 'Contoh: Jl. Asia Afrika No. 123',
                                  icon: Icons.location_on_rounded,
                                  maxLines: 2,
                                  onChanged: (val) => context
                                      .read<SetupWizardCubit>()
                                      .updateMosqueAddress(val),
                                ),

                                // Validation Error Display
                                if (errorText != null) ...[
                                  SizedBox(height: 16.h),
                                  Container(
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: IslamicColors.error.withValues(
                                        alpha: 0.1,
                                      ),
                                      border: Border.all(
                                        color: IslamicColors.error.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: IslamicColors.error,
                                          size: 20.w,
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Text(
                                            errorText,
                                            style: IslamicTypography.body(
                                              color: IslamicColors.error,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 48.h),

                        // Navigation Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildNavButton(
                              label: 'Kembali',
                              isPrimary: false,
                              onPressed: () => context
                                  .read<SetupWizardCubit>()
                                  .goToPreviousStep(),
                            ),
                            SizedBox(width: 24.w),
                            _buildNavButton(
                              label: 'Selanjutnya',
                              isPrimary: true,
                              onPressed: () => context
                                  .read<SetupWizardCubit>()
                                  .goToNextStep(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: IslamicTypography.title(
        color: IslamicColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildNavButton({
    required String label,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return FocusableWidget(
      onSelect: onPressed,
      builder: (isFocused) {
        final baseColor = isPrimary
            ? IslamicColors.goldAmber
            : IslamicColors.surfaceLight;
        final textColor = isPrimary
            ? IslamicColors.deepTeal
            : IslamicColors.textPrimary;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 280.w,
          height: 56.h,
          decoration: BoxDecoration(
            color: isFocused ? baseColor.withValues(alpha: 0.9) : baseColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isFocused
                  ? IslamicColors.textPrimary
                  : (isPrimary
                        ? Colors.transparent
                        : IslamicColors.glassBorder),
              width: 2.0,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: baseColor.withValues(alpha: 0.5),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                label,
                style: IslamicTypography.title(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
