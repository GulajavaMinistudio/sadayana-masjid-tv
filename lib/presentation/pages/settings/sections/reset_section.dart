import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/islamic_colors.dart';
import '../../../../core/theme/islamic_typography.dart';
import '../../../cubits/settings/settings_cubit.dart';
import '../../../widgets/focusable_widget.dart';
import '../../splash_page.dart';

/// Section untuk mereset pengaturan ke default pabrik.
///
/// Akan menampilkan dialog konfirmasi sebelum menghapus semua data
/// dan menavigasi kembali ke Setup Wizard (via SplashPage).
class ResetSection extends StatelessWidget {
  const ResetSection({super.key});

  Future<void> _confirmReset(BuildContext context) async {
    final curContext = context;
    final cubit = context.read<SettingsCubit>();

    final confirmed = await showDialog<bool>(
      context: curContext,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: IslamicColors.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: const BorderSide(color: IslamicColors.error),
          ),
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: IslamicColors.error,
                      size: 48.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Konfirmasi Reset',
                      style: IslamicTypography.heading(
                        color: IslamicColors.error,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                // Content
                Text(
                  'Apakah Anda yakin ingin mereset semua pengaturan ke bawaan pabrik?',
                  style: IslamicTypography.body(
                    color: IslamicColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Tindakan ini akan menghapus kota tersimpan, koreksi waktu, '
                  'dan identitas masjid.',
                  style: IslamicTypography.body(
                    color: IslamicColors.textSecondary,
                  ),
                ),
                SizedBox(height: 32.h),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FocusableWidget(
                      autofocus: true,
                      onSelect: () => Navigator.of(dialogContext).pop(false),
                      builder: (isFocused) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                            horizontal: 28.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: isFocused
                                  ? IslamicColors.goldAmber
                                  : IslamicColors.glassBorder,
                              width: isFocused ? 2.0 : 1.0,
                            ),
                            color: isFocused
                                ? IslamicColors.glassWhite
                                : Colors.transparent,
                          ),
                          child: Text(
                            'Batal',
                            style: IslamicTypography.body(
                              color: isFocused
                                  ? IslamicColors.textPrimary
                                  : IslamicColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 16.w),
                    FocusableWidget(
                      onSelect: () => Navigator.of(dialogContext).pop(true),
                      builder: (isFocused) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                            horizontal: 28.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: isFocused
                                  ? IslamicColors.goldAmber
                                  : IslamicColors.error,
                              width: isFocused ? 2.0 : 1.0,
                            ),
                            color: IslamicColors.error,
                          ),
                          child: Text(
                            'Hapus Data',
                            style: IslamicTypography.body(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true && curContext.mounted) {
      await cubit.resetSettings();

      if (curContext.mounted) {
        // Navigasi kembali ke SplashPage / Root Navigator
        // SplashPage akan mendeteksi is_first_run == 1 dan membuka SetupWizard
        Navigator.of(curContext, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SplashPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reset Data',
            style: IslamicTypography.title(
              color: IslamicColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Hapus semua pengaturan dan kembali ke wizard pengaturan awal.',
            style: IslamicTypography.caption(color: IslamicColors.textMuted),
          ),
          SizedBox(height: 32.h),

          // Tombol Reset
          SizedBox(
            width: double.infinity,
            height: 64.h,
            child: ElevatedButton(
              onPressed: () => _confirmReset(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: IslamicColors.glassWhite,
                foregroundColor: IslamicColors.error,
                side: const BorderSide(color: IslamicColors.error, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restore_page_outlined, size: 28.w),
                  SizedBox(width: 12.w),
                  Text(
                    'Reset ke Pengaturan Awal',
                    style: IslamicTypography.body(
                      color: IslamicColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
