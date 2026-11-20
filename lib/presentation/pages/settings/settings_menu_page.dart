import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/islamic_colors.dart';
import '../../../core/theme/islamic_typography.dart';
import '../../widgets/focusable_widget.dart';
import '../../widgets/glassmorphism_card.dart';
import '../../widgets/islamic_background.dart';
import '../../../../core/theme/tv_safe_area.dart';
import 'sections/dhuha_section.dart';
import 'sections/display_timing_section.dart';
import 'sections/identity_section.dart';
import 'sections/ihtiyat_section.dart';
import 'sections/iqomah_section.dart';
import 'sections/reset_section.dart';
import 'sections/running_text_section.dart';
import 'sections/security_section.dart';
import 'sections/treasury_section.dart';
import 'sections/alert_settings_section.dart';
import 'sections/imam_schedule_section.dart';
import 'sections/midnight_mode_section.dart';
import 'sections/slideshow_section.dart';
import 'sections/wisdom_quote_section.dart';
import 'sections/about_section.dart';

class SettingsMenuPage extends StatefulWidget {
  const SettingsMenuPage({super.key});

  @override
  State<SettingsMenuPage> createState() => _SettingsMenuPageState();
}

class _SettingsMenuPageState extends State<SettingsMenuPage> {
  int _selectedIndex = 0;

  final List<String> _categories = [
    "Identitas Masjid",
    "Koreksi Waktu (Ihtiyat)",
    "Durasi Iqomah",
    "Pengaturan Dhuha",
    "Durasi Tampilan",
    "Alarm Tanda Waktu",
    "Running Text",
    "Keamanan (PIN)",
    "Informasi Kas",
    "Kata Mutiara",
    "Slideshow Pengumuman",
    "Jadwal Imam",
    "Mode Hemat Daya",
    "Reset Data",
    "Tentang Aplikasi",
  ];

  final List<Widget> _sections = const [
    IdentitySection(),
    IhtiyatSection(),
    IqomahSection(),
    DhuhaSection(),
    DisplayTimingSection(),
    AlertSettingsSection(),
    RunningTextSection(),
    SecuritySection(),
    TreasurySection(),
    WisdomQuoteSection(),
    SlideshowSection(),
    ImamScheduleSection(),
    MidnightModeSection(),
    ResetSection(),
    AboutSection(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IslamicBackground(
        child: TVSafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Panel: Menu List
              Container(
                width: 400.w,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: IslamicColors.glassBorder),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 24.h,
                      ),
                      child: Text(
                        'Pengaturan',
                        style: IslamicTypography.title(),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Menu Items
                    Expanded(
                      child: ListView.builder(
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedIndex == index;
                          return FocusableWidget(
                            autofocus: index == 0,
                            onSelect: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                            builder: (isFocused) {
                              return Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 16.h,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  color: isFocused
                                      ? IslamicColors.goldAmber.withValues(
                                          alpha: 0.2,
                                        )
                                      : (isSelected
                                            ? IslamicColors.glassWhite
                                            : Colors.transparent),
                                  border: Border.all(
                                    color: isFocused
                                        ? IslamicColors.goldAmber
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Text(
                                  _categories[index],
                                  style: IslamicTypography.subtitle(
                                    color: (isFocused || isSelected)
                                        ? IslamicColors.goldAmber
                                        : IslamicColors.textSecondary,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // Back button at bottom
                    Padding(
                      padding: EdgeInsets.all(24.w),
                      child: FocusableWidget(
                        onSelect: () => Navigator.of(context).pop(),
                        builder: (isFocused) {
                          return GlassmorphismCard(
                            isFocused: isFocused,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 16.h,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Icon(
                                  Icons.arrow_back,
                                  color: isFocused
                                      ? IslamicColors.goldAmber
                                      : IslamicColors.textSecondary,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    'Tutup Pengaturan',
                                    style: IslamicTypography.body(
                                      color: isFocused
                                          ? IslamicColors.goldAmber
                                          : IslamicColors.textSecondary,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Right Panel: Selected Section
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(32.w),
                  child: IndexedStack(
                    index: _selectedIndex,
                    sizing: StackFit.expand,
                    children: _sections,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
