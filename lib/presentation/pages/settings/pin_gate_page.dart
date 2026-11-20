import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/islamic_colors.dart';
import '../../../core/theme/islamic_typography.dart';
import '../../cubits/settings/settings_cubit.dart';
import '../../widgets/focusable_widget.dart';
import '../../widgets/islamic_background.dart';
import '../../../../core/theme/tv_safe_area.dart';
import '../../widgets/pin_input_widget.dart';
import 'settings_menu_page.dart';

class PinGatePage extends StatefulWidget {
  const PinGatePage({super.key});

  @override
  State<PinGatePage> createState() => _PinGatePageState();
}

class _PinGatePageState extends State<PinGatePage> {
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    // Check if PIN is disabled. Note: delay until after first frame to navigate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final settingsCubit = context.read<SettingsCubit>();
        if (!settingsCubit.isPinEnabled) {
          _navigateToMenu();
        }
      }
    });
  }

  void _navigateToMenu() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SettingsMenuPage()),
    );
  }

  void _verifyPin(String pin) async {
    final success = await context.read<SettingsCubit>().verifyPin(pin);
    if (!mounted) return;

    if (success) {
      _navigateToMenu();
    } else {
      setState(() => _showError = true);
      // Reset error state so it can be re-triggered
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _showError = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IslamicBackground(
        child: TVSafeArea(
          child: Stack(
            children: [
              // Back Button
              Positioned(
                top: 24.h,
                left: 24.w,
                child: FocusableWidget(
                  onSelect: () => Navigator.of(context).pop(),
                  builder: (isFocused) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isFocused
                            ? IslamicColors.goldAmber.withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isFocused
                              ? IslamicColors.goldAmber
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: isFocused
                                ? IslamicColors.goldAmber
                                : IslamicColors.textSecondary,
                            size: 24.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Kembali',
                            style: IslamicTypography.body(
                              color: isFocused
                                  ? IslamicColors.goldAmber
                                  : IslamicColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // PIN Input Center Content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 80.sp,
                      color: IslamicColors.goldAmber,
                    ),
                    SizedBox(height: 24.h),
                    Text('Masukkan PIN', style: IslamicTypography.heading()),
                    SizedBox(height: 16.h),
                    Text(
                      'Silakan masukkan PIN keamanan untuk mengakses pengaturan.',
                      style: IslamicTypography.body(
                        color: IslamicColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 48.h),
                    PinInputWidget(
                      onCompleted: _verifyPin,
                      showError: _showError,
                      autofocus: true,
                    ),
                    if (_showError) ...[
                      SizedBox(height: 24.h),
                      Text(
                        'PIN yang Anda masukkan salah.',
                        style: IslamicTypography.body(
                          color: IslamicColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
