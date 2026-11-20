import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/islamic_colors.dart';
import '../../core/theme/islamic_typography.dart';
import '../../domain/entities/slideshow_image.dart';
import '../widgets/focusable_widget.dart';

/// Halaman pratinjau fullscreen untuk satu gambar slideshow.
///
/// Menggunakan layout aman yang identik dengan runtime slideshow:
/// kanvas hitam 1280x720 dipusatkan di layar, gambar dirender dengan
/// [BoxFit.scaleDown] agar tidak ter-crop.
///
/// Tombol back menutup halaman tanpa mengubah data slot apapun.
/// **TS-P6-005** dan **REQ-024**
///
/// Ref: Plan feature-slideshow-pengumuman-1.md Phase 6 TASK-038
class SlideshowPreviewPage extends StatelessWidget {
  /// Gambar yang akan di-preview.
  final SlideshowImage image;

  const SlideshowPreviewPage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        autofocus: false,
        onKeyEvent: (node, event) {
          // Tutup preview saat tombol Back / Escape ditekan
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.goBack ||
                  event.logicalKey == LogicalKeyboardKey.escape ||
                  event.logicalKey == LogicalKeyboardKey.browserBack)) {
            Navigator.of(context).maybePop();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Stack(
          children: [
            // ── Kanvas aman 1280x720 terpusat (TS-P6-005, REQ-020) ──────── //
            Center(
              child: LayoutBuilder(
                builder: (_, constraints) {
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: 1280,
                      height: 720,
                      child: Container(
                        color: Colors.black,
                        child: Image.file(
                          File(image.storedPath),
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          errorBuilder: (_, _, _) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_outlined,
                                  color: IslamicColors.textSecondary,
                                  size: 64.sp,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'File gambar tidak ditemukan',
                                  style: IslamicTypography.body(
                                    color: IslamicColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Header overlay: label slot + tombol tutup ────────────────── //
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Label slot + nama file
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pratinjau · Slot ${image.slotIndex}',
                          style: IslamicTypography.body(
                            color: IslamicColors.goldAmber,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          image.fileName,
                          style: IslamicTypography.caption(
                            color: IslamicColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${image.width}×${image.height}',
                          style: IslamicTypography.caption(
                            color: IslamicColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    // Tombol tutup
                    FocusableWidget(
                      autofocus: true,
                      onSelect: () => Navigator.of(context).pop(),
                      builder: (isFocused) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: isFocused
                              ? IslamicColors.goldAmber.withValues(alpha: 0.2)
                              : IslamicColors.glassWhite,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: isFocused
                                ? IslamicColors.goldAmber
                                : IslamicColors.glassBorder,
                            width: isFocused ? 2.0 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.close,
                              color: isFocused
                                  ? IslamicColors.goldAmber
                                  : IslamicColors.textPrimary,
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Tutup Preview',
                              style: IslamicTypography.body(
                                color: isFocused
                                    ? IslamicColors.goldAmber
                                    : IslamicColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
