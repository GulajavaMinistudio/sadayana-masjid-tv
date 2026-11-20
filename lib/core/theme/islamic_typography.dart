import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'islamic_colors.dart';

/// Islamic Glassmorphism typography scale.
///
/// Semua font sizes menggunakan `.sp` dari ScreenUtil (CON-001).
/// Setiap method menerima optional `color` dan `fontWeight` override (TASK-020).
/// Font family: Poppins via GoogleFonts (REQ-006).
///
/// Ref: Plan 03 TASK-012 s.d. TASK-020
class IslamicTypography {
  // ---------------------------------------------------------------------------
  // Private constructor — prevent instantiation
  // ---------------------------------------------------------------------------
  const IslamicTypography._();

  // ---------------------------------------------------------------------------
  // Display — 72sp — Jam digital utama, angka besar
  // ---------------------------------------------------------------------------

  /// Style untuk clock display utama dan angka besar.
  /// fontSize: 72.sp, fontWeight: w700
  static TextStyle display({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.poppins(
      fontSize: 72.sp,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color ?? IslamicColors.textPrimary,
      height: 1.1,
    );
  }

  // ---------------------------------------------------------------------------
  // Heading — 48sp — Judul section utama
  // ---------------------------------------------------------------------------

  /// Style untuk judul section utama.
  /// fontSize: 48.sp, fontWeight: w600
  static TextStyle heading({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.poppins(
      fontSize: 48.sp,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color ?? IslamicColors.textPrimary,
      height: 1.2,
    );
  }

  // ---------------------------------------------------------------------------
  // Title — 36sp — Judul card/panel
  // ---------------------------------------------------------------------------

  /// Style untuk judul card dan panel.
  /// fontSize: 36.sp, fontWeight: w600
  static TextStyle title({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.poppins(
      fontSize: 36.sp,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color ?? IslamicColors.textPrimary,
      height: 1.25,
    );
  }

  // ---------------------------------------------------------------------------
  // Subtitle — 28sp — Sub-judul
  // ---------------------------------------------------------------------------

  /// Style untuk sub-judul dan secondary headings.
  /// fontSize: 28.sp, fontWeight: w500
  static TextStyle subtitle({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.poppins(
      fontSize: 28.sp,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color ?? IslamicColors.textPrimary,
      height: 1.3,
    );
  }

  // ---------------------------------------------------------------------------
  // Body — 24sp — Teks konten utama
  // ---------------------------------------------------------------------------

  /// Style untuk teks konten utama.
  /// fontSize: 24.sp, fontWeight: w400
  static TextStyle body({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.poppins(
      fontSize: 24.sp,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? IslamicColors.textPrimary,
      height: 1.4,
    );
  }

  // ---------------------------------------------------------------------------
  // Caption — 20sp — Label kecil
  // ---------------------------------------------------------------------------

  /// Style untuk label kecil dan metadata.
  /// fontSize: 20.sp, fontWeight: w400, color: textSecondary
  static TextStyle caption({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.poppins(
      fontSize: 20.sp,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? IslamicColors.textSecondary,
      height: 1.4,
    );
  }

  // ---------------------------------------------------------------------------
  // Overline — 16sp — Label uppercase
  // ---------------------------------------------------------------------------

  /// Style untuk label uppercase, kategori, dan overline text.
  /// fontSize: 16.sp, fontWeight: w500, letterSpacing: 2.sp
  static TextStyle overline({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.poppins(
      fontSize: 16.sp,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color ?? IslamicColors.textMuted,
      letterSpacing: 2.sp,
      height: 1.5,
    );
  }
}
