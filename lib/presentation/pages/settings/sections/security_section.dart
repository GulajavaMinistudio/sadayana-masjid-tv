import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/islamic_colors.dart';
import '../../../../core/theme/islamic_typography.dart';
import '../../../cubits/settings/settings_cubit.dart';
import '../../../cubits/settings/settings_state.dart';
import '../../../widgets/focusable_widget.dart';
import '../../../widgets/pin_input_widget.dart';

class SecuritySection extends StatefulWidget {
  const SecuritySection({super.key});

  @override
  State<SecuritySection> createState() => _SecuritySectionState();
}

class _SecuritySectionState extends State<SecuritySection> {
  bool _isChangingPin = false;
  bool _isDisablingPin = false;
  final bool _showError = false;

  Future<void> _handlePinSubmit(SettingsCubit cubit, String pin) async {
    final messenger = ScaffoldMessenger.maybeOf(context);

    // If we're setting a new PIN (regardless if disabling or enabling/changing)
    // Actually, PIN verification should be required to change or disable.
    // However, the user already passed the PinGatePage to enter settings.
    // So we can assume they are authorized to change or delete PIN here.

    if (_isDisablingPin) {
      // In this state, we assume the input was maybe a confirmation, but let's just use cubit.removePin()
      await cubit.removePin();
      if (!mounted) return;

      setState(() {
        _isDisablingPin = false;
      });
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            'PIN Keamanan telah dinonaktifkan.',
            style: IslamicTypography.body(color: IslamicColors.surfaceDark),
          ),
          backgroundColor: IslamicColors.success,
        ),
      );
    } else if (_isChangingPin) {
      await cubit.setPin(pin);
      if (!mounted) return;

      setState(() {
        _isChangingPin = false;
      });
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            'PIN Keamanan baru berhasil disimpan.',
            style: IslamicTypography.body(color: IslamicColors.surfaceDark),
          ),
          backgroundColor: IslamicColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        if (state is! SettingsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final cubit = context.read<SettingsCubit>();
        final bool isPinEnabled = cubit.isPinEnabled;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Keamanan (PIN)', style: IslamicTypography.heading()),
              SizedBox(height: 8.h),
              Text(
                'Gunakan PIN 6 digit untuk mengunci menu pengaturan layar ini.',
                style: IslamicTypography.subtitle(
                  color: IslamicColors.textSecondary,
                ),
              ),
              SizedBox(height: 32.h),

              // Status Indicator
              Row(
                children: [
                  Icon(
                    isPinEnabled ? Icons.lock : Icons.lock_open,
                    color: isPinEnabled
                        ? IslamicColors.goldAmber
                        : IslamicColors.textMuted,
                    size: 32.sp,
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    isPinEnabled ? 'PIN Aktif' : 'PIN Tidak Aktif',
                    style: IslamicTypography.title(
                      color: isPinEnabled
                          ? IslamicColors.goldAmber
                          : IslamicColors.textMuted,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              if (!_isChangingPin && !_isDisablingPin) ...[
                // Action Buttons
                IntrinsicHeight(
                  child: FocusableWidget(
                    onSelect: () {
                      setState(() {
                        _isChangingPin = true;
                        _isDisablingPin = false;
                      });
                    },
                    builder: (isFocused) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: IslamicColors.primaryTeal,
                          border: Border.all(
                            color: isFocused
                                ? IslamicColors.goldAmber
                                : IslamicColors.primaryTeal,
                            width: isFocused ? 2.0 : 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          isPinEnabled ? 'Ubah PIN' : 'Buat PIN',
                          style: IslamicTypography.title(
                            color: IslamicColors.textPrimary,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                if (isPinEnabled) ...[
                  SizedBox(height: 16.h),
                  IntrinsicHeight(
                    child: FocusableWidget(
                      onSelect: () {
                        setState(() {
                          _isDisablingPin = true;
                          _isChangingPin = false;
                        });

                        // Directly disable (since user is already authenticated to be in Settings)
                        _handlePinSubmit(cubit, '');
                      },
                      builder: (isFocused) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: IslamicColors.error,
                            border: Border.all(
                              color: isFocused
                                  ? IslamicColors.goldAmber
                                  : IslamicColors.error,
                              width: isFocused ? 2.0 : 1.0,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            'Nonaktifkan PIN',
                            style: IslamicTypography.title(
                              color: IslamicColors.textPrimary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],

              if (_isChangingPin) ...[
                Text(
                  'Masukkan 6-digit PIN Baru',
                  style: IslamicTypography.title(),
                ),
                SizedBox(height: 24.h),
                PinInputWidget(
                  onCompleted: (pin) => _handlePinSubmit(cubit, pin),
                  showError: _showError,
                ),
                SizedBox(height: 32.h),
                IntrinsicHeight(
                  child: FocusableWidget(
                    onSelect: () {
                      setState(() {
                        _isChangingPin = false;
                      });
                    },
                    builder: (isFocused) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: isFocused
                              ? IslamicColors.glassWhite
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isFocused
                                ? IslamicColors.textPrimary
                                : IslamicColors.textMuted,
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: IslamicTypography.title(
                            color: IslamicColors.textMuted,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
