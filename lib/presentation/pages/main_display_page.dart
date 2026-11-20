import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/islamic_colors.dart';
import '../../domain/entities/display_state.dart';
import '../../domain/entities/display_state_type.dart';
import '../cubits/display_state/display_state.dart';
import '../widgets/islamic_background.dart';
import '../../../core/theme/tv_safe_area.dart';
import 'main_display/layouts/adzan_layout.dart';
import 'main_display/layouts/imam_schedule_layout.dart';
import 'main_display/layouts/iqomah_layout.dart';
import 'main_display/layouts/midnight_standby_layout.dart';
import 'main_display/layouts/pre_adzan_layout.dart';
import 'main_display/layouts/sholat_layout.dart';
import 'main_display/layouts/slideshow_layout.dart';
import 'main_display/layouts/standby_layout.dart';
import 'main_display/layouts/wisdom_quote_layout.dart';
import 'settings/pin_gate_page.dart';

class MainDisplayPage extends StatefulWidget {
  const MainDisplayPage({super.key});

  @override
  State<MainDisplayPage> createState() => _MainDisplayPageState();
}

class _MainDisplayPageState extends State<MainDisplayPage> {
  final FocusNode _focusNode = FocusNode();

  // --- Settings icon touch state ---
  bool _isSettingsIconVisible = false;
  Timer? _settingsIconTimer;

  @override
  void initState() {
    super.initState();
    context.read<DisplayStateCubit>().onAppResumed();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _settingsIconTimer?.cancel();
    super.dispose();
  }

  /// Tampilkan icon settings dan mulai timer auto-hide 5 detik.
  void _showSettingsIcon() {
    _settingsIconTimer?.cancel();
    setState(() => _isSettingsIconVisible = true);
    _settingsIconTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _isSettingsIconVisible = false);
    });
  }

  /// Navigasi ke halaman Settings.
  void _openSettings() {
    _settingsIconTimer?.cancel();
    setState(() => _isSettingsIconVisible = false);

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PinGatePage())).then((_) {
      if (mounted) {
        context.read<DisplayStateCubit>().onSettingsChanged();
        _focusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IslamicBackground(
        child: TVSafeArea(
          child: Focus(
            autofocus: true,
            focusNode: _focusNode,
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.select ||
                    event.logicalKey == LogicalKeyboardKey.enter ||
                    event.logicalKey == LogicalKeyboardKey.escape ||
                    event.logicalKey == LogicalKeyboardKey.mediaPlayPause) {
                  _openSettings();
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;
            },
            // GestureDetector: tap di mana saja → tampilkan icon settings
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _showSettingsIcon,
              child: Stack(
                children: [
                  // Layer utama: layout berdasarkan display state
                  // TASK-011 (Phase 5): buildWhen mencegah rebuild StandbyLayout setiap detik.
                  // StandbyLayout hanya di-rebuild saat menit berganti atau type state berubah.
                  // State lain (PreAdzan/Adzan/Iqomah/Sholat/WisdomQuote) selalu rebuild
                  // karena menampilkan countdown dalam satuan detik.
                  BlocBuilder<DisplayStateCubit, DisplayState>(
                    buildWhen: (prev, next) {
                      if (prev.type != next.type) return true;
                      if (next.type == DisplayStateType.standby) {
                        return (prev as StandbyState).currentTime.minute !=
                            (next as StandbyState).currentTime.minute;
                      }
                      return true;
                    },
                    builder: (context, state) {
                      Widget layoutWidget;

                      switch (state.type) {
                        case DisplayStateType.standby:
                          layoutWidget = StandbyLayout(
                            key: const ValueKey('standby'),
                            state: state as StandbyState,
                            isSettingsVisible: _isSettingsIconVisible,
                          );
                          break;
                        case DisplayStateType.preAdzan:
                          layoutWidget = PreAdzanLayout(
                            key: const ValueKey('pre_adzan'),
                            state: state as PreAdzanState,
                            isSettingsVisible: _isSettingsIconVisible,
                          );
                          break;
                        case DisplayStateType.adzan:
                          layoutWidget = AdzanLayout(
                            key: const ValueKey('adzan'),
                            state: state as AdzanState,
                          );
                          break;
                        case DisplayStateType.iqomah:
                          layoutWidget = IqomahLayout(
                            key: const ValueKey('iqomah'),
                            state: state as IqomahState,
                          );
                          break;
                        case DisplayStateType.sholat:
                          layoutWidget = SholatLayout(
                            key: const ValueKey('sholat'),
                            state: state as SholatState,
                          );
                          break;
                        // TASK-043 (Phase 7): Layout runtime Slideshow Pengumuman Masjid.
                        case DisplayStateType.slideshowAnnouncement:
                          layoutWidget = SlideshowLayout(
                            key: const ValueKey('slideshow_announcement'),
                            state: state as SlideshowAnnouncementState,
                          );
                          break;
                        // TASK-040 (Phase 8): Layout runtime Jadwal Imam Sholat Berjamaah.
                        case DisplayStateType.imamSchedule:
                          layoutWidget = ImamScheduleLayout(
                            key: const ValueKey('imam_schedule'),
                            state: state as ImamScheduleState,
                          );
                          break;
                        case DisplayStateType.wisdomQuote:
                          layoutWidget = WisdomQuoteLayout(
                            key: const ValueKey('wisdom_quote'),
                            state: state as WisdomQuoteState,
                          );
                          break;
                        case DisplayStateType.midnightStandby:
                          layoutWidget = MidnightStandbyLayout(
                            key: const ValueKey('midnight_standby'),
                            state: state as MidnightStandbyState,
                          );
                          break;
                      }

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: layoutWidget,
                      );
                    },
                  ),

                  // Layer overlay: settings icon pojok kanan atas
                  Positioned(
                    top: 16.h,
                    right: 16.w,
                    child: AnimatedOpacity(
                      opacity: _isSettingsIconVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: IgnorePointer(
                        ignoring: !_isSettingsIconVisible,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _openSettings,
                            borderRadius: BorderRadius.circular(40.r),
                            child: Container(
                              width: 72.w,
                              height: 72.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: IslamicColors.glassWhite,
                                border: Border.all(
                                  color: IslamicColors.glassBorder,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.settings_rounded,
                                color: IslamicColors.textPrimary.withValues(
                                  alpha: 0.85,
                                ),
                                size: 36.w,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
