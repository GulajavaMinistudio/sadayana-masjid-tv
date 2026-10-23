import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/app_version.dart';
import '../../../../core/theme/islamic_colors.dart';
import '../../../../core/theme/islamic_typography.dart';
import '../../../widgets/glassmorphism_card.dart';

// ---------------------------------------------------------------------------
// _AppInfo — Konstanta statis informasi aplikasi dan developer
// Ref: Plan feature-about-page-1.md TASK-002
// ---------------------------------------------------------------------------
class _AppInfo {
  const _AppInfo._();

  static const String appName = 'Miqotul Khoir TV';
  static const String license = 'GPL v3';

  static const String description =
      'Aplikasi jam masjid digital dan papan informasi jadwal sholat '
      'berbasis Android TV. Dirancang untuk menggantikan jam jadwal sholat '
      'konvensional di masjid atau musala dengan tampilan yang indah dan '
      'mudah dibaca dari jarak jauh.\n\n'
      'Dirancang dengan prinsip Offline-First — cukup masukkan koordinat '
      'lokasi satu kali, dan aplikasi ini akan menghitung jadwal sholat '
      'secara presisi abadi tanpa perlu terhubung ke internet sama sekali. '
      'Kompatibel dengan perangkat TV Android, TV Pintar, dan Kotak Dekoder.';

  static const List<String> features = [
    'Kalkulasi waktu sholat 100% offline — standar Kemenag RI (SIHAT)',
    '7 waktu sholat: Subuh, Syuruq, Dhuha, Dzuhur, Ashar, Maghrib, Isya',
    'Koreksi ketinggian tempat (DPL/Elevasi) otomatis untuk kota dataran tinggi',
    '9 status tampilan otomatis: Standby → Pre-Adzan → Adzan → Iqomah → '
        'Sholat → Slideshow Announcement → Imam Schedule → Wisdom Quote → '
        'Midnight Standby',
    'Database 514 kota & 34 provinsi Indonesia — tanpa koneksi internet',
    'D-Pad navigation — dioptimalkan untuk Remote TV Android',
    'Informasi Kas Masjid & Running Text yang dapat dikustomisasi',
  ];

  static const String developerName = 'Gulajava Ministudio';
  static const String developerEmail = 'gulajava.mini@gmail.com';
  static const String developerLogoAsset = 'assets/images/gulajavas-scaled.png';
}

/// Section halaman Tentang Aplikasi pada Settings Menu.
///
/// Menampilkan informasi versi, deskripsi, fitur utama, serta kredit
/// pengembang lengkap dengan logo. Widget ini bersifat read-only.
/// Konten dapat di-scroll menggunakan tombol atas/bawah D-Pad remote TV.
///
/// Ref: Plan feature-about-page-1.md TASK-001 s.d. TASK-008
class AboutSection extends StatefulWidget {
  const AboutSection({super.key});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  final ScrollController _scrollController = ScrollController();

  static const double _scrollStep = 120.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _scrollController.animateTo(
        (_scrollController.offset + _scrollStep).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _scrollController.animateTo(
        (_scrollController.offset - _scrollStep).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header — TASK-004
            Text('Tentang Aplikasi', style: IslamicTypography.heading()),
            SizedBox(height: 24.h),

            // Card 1: Informasi Aplikasi — TASK-005 s.d. TASK-007
            _buildAppInfoCard(),
            SizedBox(height: 24.h),

            // Card 2: Informasi Developer — TASK-008
            _buildDeveloperCard(),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Card 1: Informasi Aplikasi
  // ---------------------------------------------------------------------------

  Widget _buildAppInfoCard() {
    return GlassmorphismCard(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris ikon masjid + nama & versi — TASK-005
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.asset(
                  'assets/images/mktv_icon_large.png',
                  width: 96.sp,
                  height: 96.sp,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _AppInfo.appName,
                      style: IslamicTypography.title(
                        color: IslamicColors.goldAmber,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Versi ${AppVersion.displayName}  ·  Build ${AppVersion.displayBuildNumber}  ·  ${_AppInfo.license}',
                      style: IslamicTypography.caption(
                        color: IslamicColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),
          Divider(color: IslamicColors.glassBorder, thickness: 1),
          SizedBox(height: 20.h),

          // Deskripsi panjang — TASK-006
          Text(
            _AppInfo.description,
            style: IslamicTypography.body(color: IslamicColors.textSecondary),
          ),

          SizedBox(height: 20.h),

          // Daftar fitur utama — TASK-007
          ...(_AppInfo.features.map(_buildFeatureItem)),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: IslamicColors.primaryTeal,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              feature,
              style: IslamicTypography.body(color: IslamicColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Card 2: Informasi Developer
  // ---------------------------------------------------------------------------

  Widget _buildDeveloperCard() {
    return GlassmorphismCard(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dikembangkan oleh',
            style: IslamicTypography.caption(color: IslamicColors.textMuted),
          ),
          SizedBox(height: 20.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo developer — dibungkus container lingkaran
              ClipOval(
                child: Container(
                  width: 80.h,
                  height: 80.h,
                  color: Colors.white,
                  child: Image.asset(
                    _AppInfo.developerLogoAsset,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 24.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _AppInfo.developerName,
                      style: IslamicTypography.subtitle(
                        color: IslamicColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          color: IslamicColors.textSecondary,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Text(
                            _AppInfo.developerEmail,
                            style: IslamicTypography.body(
                              color: IslamicColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
