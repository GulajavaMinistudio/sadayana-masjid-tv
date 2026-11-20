import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/islamic_colors.dart';
import '../../../../core/theme/islamic_typography.dart';
import '../../../../domain/entities/slideshow_image.dart';
import '../../../../domain/repositories/slideshow_image_repository.dart';
import '../../../../domain/services/slideshow_file_storage_service.dart';
import '../../../cubits/settings/settings_cubit.dart';
import '../../../cubits/settings/settings_state.dart';
import '../../../cubits/slideshow_section/slideshow_section_cubit.dart';
import '../../../cubits/slideshow_section/slideshow_section_state.dart';
import '../../../cubits/display_state/display_state_cubit.dart';
import '../../../widgets/dpad_stepper.dart';
import '../../../widgets/focusable_widget.dart';
import '../../slideshow_preview_page.dart';

/// Section pengaturan Slideshow Pengumuman Masjid.
///
/// Menampilkan toggle aktif/nonaktif, ringkasan status, konfigurasi jadwal
/// (hanya non-interaktif saat toggle OFF), dan 3 slot gambar tetap dengan
/// tombol pilih/ganti/pratinjau/hapus.
///
/// Scalar settings slideshow dikelola oleh [SettingsCubit].
/// Manajemen slot gambar dikelola oleh [SlideshowSectionCubit] yang
/// di-provide secara lokal oleh widget ini.
///
/// **TS-P6-002**: Saat toggle OFF, hanya blok jadwal yang non-interaktif;
/// slot gambar tetap aktif dan bisa dikelola.
/// **TS-P6-004**: Auto-disable toggle berjalan di listener BlocConsumer
/// hanya setelah delete berhasil dan jumlah gambar tersisa benar-benar 0.
///
/// Ref: Plan feature-slideshow-pengumuman-1.md Phase 6 (TASK-031..038)
class SlideshowSection extends StatelessWidget {
  const SlideshowSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SlideshowSectionCubit>(
      create: (context) => SlideshowSectionCubit(
        imageRepository: context.read<SlideshowImageRepository>(),
        storageService: context.read<SlideshowFileStorageService>(),
        displayStateCubit: context.read<DisplayStateCubit>(),
      )..loadImages(),
      child: const _SlideshowSectionContent(),
    );
  }
}

class _SlideshowSectionContent extends StatelessWidget {
  const _SlideshowSectionContent();

  /// Format integer ke string dua digit (e.g. 3 → '03').
  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listenWhen: (_, current) => current is SettingsLoaded,
      listener: (_, _) {},
      builder: (context, settingsState) {
        if (settingsState is! SettingsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final settings = settingsState.settings;
        final settingsCubit = context.read<SettingsCubit>();
        final enabled = settings.isSlideshowEnabled;

        return BlocConsumer<SlideshowSectionCubit, SlideshowSectionState>(
          // TASK-036 / TS-P6-004: auto-disable toggle hanya setelah delete
          // berhasil dan jumlah gambar tersisa benar-benar 0.
          listenWhen: (previous, current) =>
              !current.isBusy &&
              previous.isBusy &&
              !current.isLoading &&
              current.errorMessage == null,
          listener: (context, slideshowState) {
            if (slideshowState.images.isEmpty && enabled) {
              context.read<SettingsCubit>().updateSlideshowEnabled(false);
            }
          },
          builder: (context, slideshowState) {
            final cubit = context.read<SlideshowSectionCubit>();
            final filledCount = slideshowState.images.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header ─────────────────────────────────────────────── //
                Row(
                  children: [
                    Icon(
                      Icons.slideshow,
                      color: IslamicColors.goldAmber,
                      size: 28.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Slideshow Pengumuman',
                      style: IslamicTypography.heading(),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'Tampilkan gambar pengumuman masjid secara periodik '
                  'di layar utama saat standby.',
                  style: IslamicTypography.subtitle(
                    color: IslamicColors.textSecondary,
                  ),
                ),
                SizedBox(height: 16.h),

                // ─── Ringkasan Status (TASK-032) ─────────────────────────── //
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: IslamicColors.glassWhite,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: IslamicColors.glassBorder),
                  ),
                  child: Wrap(
                    spacing: 16.w,
                    runSpacing: 4.h,
                    children: [
                      _StatusChip(
                        label: enabled ? 'ON' : 'OFF',
                        color: enabled
                            ? IslamicColors.success
                            : IslamicColors.textSecondary,
                      ),
                      _StatusChip(
                        label: '$filledCount/3 gambar',
                        color: filledCount > 0
                            ? IslamicColors.textPrimary
                            : IslamicColors.textSecondary,
                      ),
                      _StatusChip(
                        label:
                            'Setiap ${settings.slideshowIntervalMinutes} mnt',
                        color: IslamicColors.textSecondary,
                      ),
                      _StatusChip(
                        label:
                            'Slot ${settings.slideshowSlotDurationMinutes} mnt',
                        color: IslamicColors.textSecondary,
                      ),
                      _StatusChip(
                        label:
                            '${settings.slideshowImageDurationSeconds} dtk/gambar',
                        color: IslamicColors.textSecondary,
                      ),
                      _StatusChip(
                        label:
                            '${_pad(settings.slideshowStartHour)}:${_pad(settings.slideshowStartMinute)}'
                            ' – '
                            '${_pad(settings.slideshowEndHour)}:${_pad(settings.slideshowEndMinute)}',
                        color: IslamicColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // ─── Toggle: Aktifkan Slideshow (TASK-033) ──────────────── //
                FocusableWidget(
                  autofocus: true,
                  onSelect: () => settingsCubit.updateSlideshowEnabled(
                    !settings.isSlideshowEnabled,
                  ),
                  builder: (isFocused) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 14.h,
                    ),
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
                          'Aktifkan Slideshow Pengumuman',
                          style: IslamicTypography.body(
                            color: IslamicColors.textPrimary,
                          ),
                        ),
                        Switch.adaptive(
                          value: settings.isSlideshowEnabled,
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

                // ─── Konten Scrollable ───────────────────────────────────── //
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Blok Jadwal — non-interaktif saat OFF (TS-P6-002 + TASK-034) ─ //
                        ExcludeFocus(
                          excluding: !enabled,
                          child: IgnorePointer(
                            ignoring: !enabled,
                            child: Opacity(
                              opacity: enabled ? 1.0 : 0.4,
                              child: _buildScheduleBlock(
                                settings: settings,
                                cubit: settingsCubit,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        Divider(color: IslamicColors.glassBorder),
                        SizedBox(height: 16.h),

                        // ─── Header blok gambar ─────────────────────────── //
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Kelola Gambar Slideshow',
                              style: IslamicTypography.body(
                                color: IslamicColors.textSecondary,
                              ),
                            ),
                            Text(
                              '$filledCount dari 3 slot terisi',
                              style: IslamicTypography.caption(
                                color: filledCount > 0
                                    ? IslamicColors.success
                                    : IslamicColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),

                        // ─── Pesan error jika ada ───────────────────────── //
                        if (slideshowState.errorMessage != null) ...[
                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: IslamicColors.error.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: IslamicColors.error.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: IslamicColors.error,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    slideshowState.errorMessage!,
                                    style: IslamicTypography.caption(
                                      color: IslamicColors.error,
                                    ),
                                  ),
                                ),
                                FocusableWidget(
                                  onSelect: () => context
                                      .read<SlideshowSectionCubit>()
                                      .clearError(),
                                  builder: (isFocused) => Icon(
                                    Icons.close,
                                    color: isFocused
                                        ? IslamicColors.goldAmber
                                        : IslamicColors.textSecondary,
                                    size: 20.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12.h),
                        ],

                        // ─── Indikator loading saat operasi berjalan ────── //
                        if (slideshowState.isBusy)
                          Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: LinearProgressIndicator(
                              color: IslamicColors.goldAmber,
                              backgroundColor: IslamicColors.glassWhite,
                            ),
                          ),

                        // ─── 3 Slot Gambar (TASK-035) ────────────────────── //
                        ...List.generate(3, (i) {
                          final slotIndex = i + 1;
                          final image = slideshowState.images
                              .where((img) => img.slotIndex == slotIndex)
                              .firstOrNull;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: _SlotCard(
                              slotIndex: slotIndex,
                              image: image,
                              isBusy: slideshowState.isBusy,
                              onImport: () => cubit.importIntoSlot(slotIndex),
                              onReplace: () => cubit.replaceSlot(slotIndex),
                              onPreview: () {
                                if (image != null) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          SlideshowPreviewPage(image: image),
                                    ),
                                  );
                                }
                              },
                              onDelete: () => cubit.deleteFromSlot(slotIndex),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Blok DPadStepper untuk konfigurasi jadwal slideshow (TASK-034 / TS-P6-006).
  Widget _buildScheduleBlock({
    required settings,
    required SettingsCubit cubit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Konfigurasi Tampilan',
          style: IslamicTypography.body(color: IslamicColors.textSecondary),
        ),
        SizedBox(height: 12.h),

        // Interval antar-slot: 5..60 step 5
        DPadStepper(
          label: 'Jeda Antar Slot',
          value: settings.slideshowIntervalMinutes,
          minValue: 5,
          maxValue: 60,
          step: 5,
          suffix: 'menit',
          onChanged: cubit.updateSlideshowIntervalMinutes,
        ),
        SizedBox(height: 12.h),

        // Durasi satu slot: 1..10 step 1
        DPadStepper(
          label: 'Durasi Satu Slot',
          value: settings.slideshowSlotDurationMinutes,
          minValue: 1,
          maxValue: 10,
          step: 1,
          suffix: 'menit',
          onChanged: cubit.updateSlideshowSlotDurationMinutes,
        ),
        SizedBox(height: 12.h),

        // Durasi per gambar: 5..30 step 5
        DPadStepper(
          label: 'Durasi Per Gambar',
          value: settings.slideshowImageDurationSeconds,
          minValue: 5,
          maxValue: 30,
          step: 5,
          suffix: 'detik',
          onChanged: cubit.updateSlideshowImageDurationSeconds,
        ),
        SizedBox(height: 20.h),

        Divider(color: IslamicColors.glassBorder),
        SizedBox(height: 16.h),

        Text(
          'Jam Aktif',
          style: IslamicTypography.body(color: IslamicColors.textSecondary),
        ),
        SizedBox(height: 12.h),

        // Jam mulai: 0..23
        DPadStepper(
          label: 'Dari Jam',
          value: settings.slideshowStartHour,
          minValue: 0,
          maxValue: 23,
          suffix: '',
          onChanged: cubit.updateSlideshowStartHour,
        ),
        SizedBox(height: 12.h),

        // Menit mulai: 0..59 step 5
        DPadStepper(
          label: 'Menit Mulai',
          value: settings.slideshowStartMinute,
          minValue: 0,
          maxValue: 59,
          step: 5,
          suffix: '',
          onChanged: cubit.updateSlideshowStartMinute,
        ),
        SizedBox(height: 16.h),

        // Jam selesai: 0..23
        DPadStepper(
          label: 'Sampai Jam',
          value: settings.slideshowEndHour,
          minValue: 0,
          maxValue: 23,
          suffix: '',
          onChanged: cubit.updateSlideshowEndHour,
        ),
        SizedBox(height: 12.h),

        // Menit selesai: 0..59 step 5
        DPadStepper(
          label: 'Menit Selesai',
          value: settings.slideshowEndMinute,
          minValue: 0,
          maxValue: 59,
          step: 5,
          suffix: '',
          onChanged: cubit.updateSlideshowEndMinute,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal: Status Chip
// ─────────────────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: IslamicTypography.caption(color: color));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal: Slot Card (TASK-035)
// ─────────────────────────────────────────────────────────────────────────────

/// Widget untuk satu slot gambar slideshow.
///
/// Menampilkan placeholder jika kosong, atau thumbnail + metadata jika terisi.
/// Tombol aksi yang tersedia disesuaikan dengan kondisi slot.
/// **TS-P6-003**: Thumbnail menggunakan box 16:9 berlatar hitam dengan BoxFit.contain.
class _SlotCard extends StatelessWidget {
  final int slotIndex;
  final SlideshowImage? image;
  final bool isBusy;
  final VoidCallback onImport;
  final VoidCallback onReplace;
  final VoidCallback onPreview;
  final VoidCallback onDelete;

  const _SlotCard({
    required this.slotIndex,
    required this.image,
    required this.isBusy,
    required this.onImport,
    required this.onReplace,
    required this.onPreview,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOccupied = image != null;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: IslamicColors.glassWhite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: IslamicColors.glassBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Thumbnail / Placeholder (TS-P6-003) ──────────────────────── //
          _buildThumbnail(isOccupied),
          SizedBox(width: 16.w),

          // ── Info + Actions ────────────────────────────────────────────── //
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Slot label
                Text(
                  'Slot $slotIndex',
                  style: IslamicTypography.body(color: IslamicColors.goldAmber),
                ),
                SizedBox(height: 4.h),

                if (isOccupied) ...[
                  // Nama file
                  Text(
                    image!.fileName,
                    style: IslamicTypography.caption(
                      color: IslamicColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  // Resolusi + ukuran
                  Text(
                    '${image!.width}×${image!.height} · '
                    '${_formatSize(image!.fileSizeBytes)}',
                    style: IslamicTypography.caption(
                      color: IslamicColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Tombol: Ganti | Pratinjau | Hapus
                  Wrap(
                    spacing: 8.w,
                    children: [
                      _ActionButton(
                        label: 'Ganti',
                        icon: Icons.swap_horiz,
                        onSelect: isBusy ? null : onReplace,
                      ),
                      _ActionButton(
                        label: 'Pratinjau',
                        icon: Icons.visibility,
                        onSelect: onPreview,
                      ),
                      _ActionButton(
                        label: 'Hapus',
                        icon: Icons.delete_outline,
                        onSelect: isBusy ? null : onDelete,
                        isDestructive: true,
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    'Slot kosong',
                    style: IslamicTypography.caption(
                      color: IslamicColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Tombol: Pilih Gambar
                  _ActionButton(
                    label: 'Pilih Gambar',
                    icon: Icons.add_photo_alternate_outlined,
                    onSelect: isBusy ? null : onImport,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Thumbnail 16:9 berlatar hitam (TS-P6-003).
  Widget _buildThumbnail(bool isOccupied) {
    // Lebar tetap, tinggi = lebar * 9/16
    final thumbW = 160.w;
    final thumbH = thumbW * 9 / 16;

    return Container(
      width: thumbW,
      height: thumbH,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: IslamicColors.glassBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: isOccupied
          ? Image.file(
              File(image!.storedPath),
              fit: BoxFit.contain,
              alignment: Alignment.center,
              errorBuilder: (_, _, _) => Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: IslamicColors.textSecondary,
                  size: 24.sp,
                ),
              ),
            )
          : Center(
              child: Icon(
                Icons.image_outlined,
                color: IslamicColors.textSecondary,
                size: 28.sp,
              ),
            ),
    );
  }

  /// Format bytes ke string ramah manusia (KB / MB).
  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal: Action Button
// ─────────────────────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onSelect;
  final bool isDestructive;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onSelect,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onSelect != null;
    final activeColor = isDestructive
        ? IslamicColors.error
        : IslamicColors.goldAmber;

    return FocusableWidget(
      onSelect: onSelect,
      builder: (isFocused) => Opacity(
        opacity: isEnabled ? 1.0 : 0.4,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isFocused
                ? activeColor.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isFocused ? activeColor : IslamicColors.glassBorder,
              width: isFocused ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: isFocused ? activeColor : IslamicColors.textSecondary,
              ),
              SizedBox(width: 4.w),
              Text(
                label,
                style: IslamicTypography.caption(
                  color: isFocused ? activeColor : IslamicColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
