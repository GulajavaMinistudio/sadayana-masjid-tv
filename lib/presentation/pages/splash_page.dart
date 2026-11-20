import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/islamic_colors.dart';
import '../../core/theme/islamic_typography.dart';
import '../../domain/repositories/settings_repository.dart';
import '../cubits/settings/settings_cubit.dart';
import 'main_display_page.dart';
import 'setup_wizard/setup_wizard_page.dart';

/// Halaman splash screen yang menangani logika routing awal.
///
/// Memeriksa status `isFirstRun` dari [SettingsRepository]:
/// - Jika true (pertama kali install/data clear) → navigasi ke [SetupWizardPage].
/// - Jika false (sudah setup) → navigasi ke Main Display Page (Placeholder for now).
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkFirstRun();
  }

  Future<void> _checkFirstRun() async {
    // Artificial delay untuk menampilkan logo branding (min 2 detik)
    // Agar user sempat melihat branding masjid/aplikasi
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      final settingsRepo = context.read<SettingsRepository>();
      final isFirstRun = await settingsRepo.isFirstRun();

      if (!mounted) return;

      if (isFirstRun) {
        // Navigasi ke Setup Wizard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SetupWizardPage()),
        );
      } else {
        // PERBAIKAN: Paksa SettingsCubit me-reload data dari DB
        // Karena SettingsCubit di-keep global, datanya mungkin masih
        // versi lama (kosong) saat pertama kali buka app sebelum wizard selesai.
        if (mounted) {
          await context.read<SettingsCubit>().loadSettings();
        }

        if (!mounted) return;

        // Navigasi ke Main Display
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainDisplayPage()),
        );
      }
    } catch (e) {
      // Fallback jika terjadi error baca settings (sangat jarang)
      // Default ke Setup Wizard untuk safety
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SetupWizardPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IslamicColors.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo App
            ClipOval(
              child: SizedBox(
                width: 140.w,
                height: 140.w,
                child: Image.asset(
                  'assets/images/mktv_icon_large.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 48.h),

            // Nama Aplikasi
            Text(
              'Miqotul Khoir TV',
              style: IslamicTypography.heading(
                color: IslamicColors.goldAmber,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),

            // Loading Indicator
            SizedBox(
              width: 200.w,
              child: const LinearProgressIndicator(
                color: IslamicColors.goldAmber,
                backgroundColor: IslamicColors.surfaceLight,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Memuat pengaturan...',
              style: IslamicTypography.body(color: IslamicColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
