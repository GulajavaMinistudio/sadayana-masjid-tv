import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/islamic_colors.dart';
import '../../../../domain/entities/settings.dart';
import '../../../../core/theme/islamic_typography.dart';
import '../../../../domain/entities/wisdom_quote.dart';
import '../../../../domain/repositories/wisdom_quote_repository.dart';
import '../../../cubits/settings/settings_cubit.dart';
import '../../../cubits/settings/settings_state.dart';
import '../../../widgets/checklist_item_widget.dart';
import '../../../widgets/dpad_stepper.dart';
import '../../../widgets/focusable_widget.dart';
import '../../wisdom_preview_page.dart';

/// Section pengaturan Kata Mutiara Islam.
///
/// Menampilkan toggle aktif/nonaktif, konfigurasi interval/durasi/jam aktif,
/// mode tampil (urut/acak), checklist pemilihan konten, dan tombol pratinjau.
/// Semua perubahan disimpan otomatis via [SettingsCubit].
///
/// Ref: Plan feature-wisdom-quote-1.md Phase 11 (TASK-044 s.d. TASK-053)
class WisdomQuoteSection extends StatefulWidget {
  const WisdomQuoteSection({super.key});

  @override
  State<WisdomQuoteSection> createState() => _WisdomQuoteSectionState();
}

class _WisdomQuoteSectionState extends State<WisdomQuoteSection> {
  List<WisdomQuote> _allQuotes = const [];
  bool _isLoading = true;

  /// Flag untuk memastikan quotes hanya dimuat satu kali.
  bool _quotesLoaded = false;

  /// Memuat semua wisdom quotes dari repository.
  /// Menggunakan didChangeDependencies agar context.read() tersedia.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_quotesLoaded) return;
    _quotesLoaded = true;
    context.read<WisdomQuoteRepository>().getAll().then((quotes) {
      if (mounted) {
        setState(() {
          _allQuotes = quotes;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) =>
          previous is! SettingsLoaded && current is SettingsLoaded,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is! SettingsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final settings = state.settings;
        final cubit = context.read<SettingsCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ──────────────────────────────────────────────────── //
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: IslamicColors.goldAmber,
                  size: 28.sp,
                ),
                SizedBox(width: 12.w),
                Text('Kata Mutiara Islam', style: IslamicTypography.heading()),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Tampilkan ayat Al-Quran atau hadits pilihan secara periodik '
              'di layar utama saat standby.',
              style: IslamicTypography.subtitle(
                color: IslamicColors.textSecondary,
              ),
            ),
            SizedBox(height: 32.h),

            // ─── Toggle: Aktifkan Kata Mutiara — TASK-046 ────────────────── //
            FocusableWidget(
              autofocus: true,
              onSelect: () =>
                  cubit.updateWisdomEnabled(!settings.isWisdomEnabled),
              builder: (isFocused) => Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: IslamicColors.glassWhite,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isFocused
                        ? IslamicColors.goldAmber
                        : IslamicColors.glassBorder,
                    width: isFocused ? 2.0 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Aktifkan Kata Mutiara',
                      style: IslamicTypography.body(
                        color: IslamicColors.textPrimary,
                      ),
                    ),
                    Switch.adaptive(
                      value: settings.isWisdomEnabled,
                      onChanged: (_) {},
                      activeThumbColor: IslamicColors.goldAmber,
                      activeTrackColor: IslamicColors.goldAmber.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // ─── Config area (disabled when toggle off) ───────────────────── //
            Expanded(
              child: ExcludeFocus(
                excluding: !settings.isWisdomEnabled,
                child: IgnorePointer(
                  ignoring: !settings.isWisdomEnabled,
                  child: Opacity(
                    opacity: settings.isWisdomEnabled ? 1.0 : 0.4,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Interval tampil — TASK-047
                          DPadStepper(
                            label: 'Tampil Setiap',
                            value: settings.wisdomIntervalMinutes,
                            minValue: 5,
                            maxValue: 30,
                            step: 5,
                            suffix: 'menit',
                            onChanged: cubit.updateWisdomIntervalMinutes,
                          ),
                          SizedBox(height: 16.h),

                          // Durasi tampil — TASK-048
                          DPadStepper(
                            label: 'Lama Tampil',
                            value: settings.wisdomDurationMinutes,
                            minValue: 1,
                            maxValue: 10,
                            suffix: 'menit',
                            onChanged: cubit.updateWisdomDurationMinutes,
                          ),
                          SizedBox(height: 24.h),

                          Divider(color: IslamicColors.glassBorder),
                          SizedBox(height: 16.h),

                          // Jam Aktif label
                          Text(
                            'Jam Aktif',
                            style: IslamicTypography.body(
                              color: IslamicColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // Jam mulai — TASK-049
                          DPadStepper(
                            label: 'Dari Jam',
                            value: settings.wisdomStartHour,
                            minValue: 0,
                            maxValue: 23,
                            suffix: '',
                            onChanged: cubit.updateWisdomStartHour,
                          ),
                          SizedBox(height: 12.h),
                          DPadStepper(
                            label: 'Menit Mulai',
                            value: settings.wisdomStartMinute,
                            minValue: 0,
                            maxValue: 59,
                            step: 5,
                            suffix: '',
                            onChanged: cubit.updateWisdomStartMinute,
                          ),
                          SizedBox(height: 16.h),

                          // Jam selesai — TASK-049
                          DPadStepper(
                            label: 'Sampai Jam',
                            value: settings.wisdomEndHour,
                            minValue: 0,
                            maxValue: 23,
                            suffix: '',
                            onChanged: cubit.updateWisdomEndHour,
                          ),
                          SizedBox(height: 12.h),
                          DPadStepper(
                            label: 'Menit Selesai',
                            value: settings.wisdomEndMinute,
                            minValue: 0,
                            maxValue: 59,
                            step: 5,
                            suffix: '',
                            onChanged: cubit.updateWisdomEndMinute,
                          ),
                          SizedBox(height: 24.h),

                          Divider(color: IslamicColors.glassBorder),
                          SizedBox(height: 16.h),

                          // Mode tampil (Urut / Acak) — TASK-050
                          Text(
                            'Mode Tampil',
                            style: IslamicTypography.body(
                              color: IslamicColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildRadioButton(
                                  label: 'Urut',
                                  isActive: !settings.wisdomShuffle,
                                  onSelect: () =>
                                      cubit.updateWisdomShuffle(false),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: _buildRadioButton(
                                  label: 'Acak',
                                  isActive: settings.wisdomShuffle,
                                  onSelect: () =>
                                      cubit.updateWisdomShuffle(true),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24.h),

                          Divider(color: IslamicColors.glassBorder),
                          SizedBox(height: 16.h),

                          // Checklist header + counter — TASK-052
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pilih Konten',
                                style: IslamicTypography.body(
                                  color: IslamicColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${settings.wisdomSelectedIds.length} item dipilih',
                                style: IslamicTypography.caption(
                                  color: settings.wisdomSelectedIds.isEmpty
                                      ? IslamicColors.warning
                                      : IslamicColors.success,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),

                          // Checklist items — TASK-051
                          if (_isLoading)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 24.h),
                                child: CircularProgressIndicator(
                                  color: IslamicColors.goldAmber,
                                ),
                              ),
                            )
                          else
                            Column(
                              children: _allQuotes.map((quote) {
                                final isChecked = settings.wisdomSelectedIds
                                    .contains(quote.id);
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: ChecklistItemWidget(
                                    id: quote.id,
                                    type: quote.type,
                                    label: quote.label,
                                    translationText: quote.translationText,
                                    isChecked: isChecked,
                                    onChanged: (checked) {
                                      final updatedIds = List<String>.from(
                                        settings.wisdomSelectedIds,
                                      );
                                      if (checked) {
                                        updatedIds.add(quote.id);
                                      } else {
                                        updatedIds.remove(quote.id);
                                      }
                                      cubit.updateWisdomSelectedIds(updatedIds);
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          SizedBox(height: 24.h),

                          // Tombol Pratinjau — TASK-053
                          _buildPreviewButton(context, settings),
                          SizedBox(height: 32.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Radio-style button untuk mode tampil Urut/Acak.
  Widget _buildRadioButton({
    required String label,
    required bool isActive,
    required VoidCallback onSelect,
  }) {
    return FocusableWidget(
      onSelect: onSelect,
      builder: (isFocused) => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isActive
              ? IslamicColors.goldAmber.withValues(alpha: 0.1)
              : IslamicColors.glassWhite,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isActive || isFocused
                ? IslamicColors.goldAmber
                : IslamicColors.glassBorder,
            width: isActive || isFocused ? 2.0 : 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: IslamicTypography.body(
            color: isActive ? IslamicColors.goldAmber : IslamicColors.textMuted,
          ),
        ),
      ),
    );
  }

  /// Tombol pratinjau kata mutiara.
  /// Dinonaktifkan (opacity 0.4) jika belum ada item yang dipilih.
  Widget _buildPreviewButton(BuildContext context, Settings settings) {
    final hasSelection = settings.wisdomSelectedIds.isNotEmpty;

    return Opacity(
      opacity: hasSelection ? 1.0 : 0.4,
      child: FocusableWidget(
        onSelect: hasSelection
            ? () {
                final selectedQuotes = _allQuotes
                    .where((q) => settings.wisdomSelectedIds.contains(q.id))
                    .toList();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WisdomPreviewPage(quotes: selectedQuotes),
                  ),
                );
              }
            : null,
        builder: (isFocused) => Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: hasSelection && isFocused
                ? IslamicColors.goldAmber.withValues(alpha: 0.15)
                : IslamicColors.glassWhite,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isFocused
                  ? IslamicColors.goldAmber
                  : IslamicColors.glassBorder,
              width: isFocused ? 2.0 : 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_circle_outline,
                color: IslamicColors.goldAmber,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Pratinjau Kata Mutiara',
                style: IslamicTypography.body(color: IslamicColors.goldAmber),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
