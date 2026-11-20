import 'dart:ui';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/islamic_colors.dart';

/// Reusable glassmorphism container widget.
///
/// Menampilkan backdrop blur effect, semi-transparent background, dan subtle
/// border sesuai Islamic Glassmorphism design system (REQ-001).
///
/// Semua dimensi menggunakan ScreenUtil extensions (CON-001).
/// Warna diambil dari [IslamicColors] constants (CON-002).
///
/// Ref: Plan 04 TASK-003 s.d. TASK-006
class GlassmorphismCard extends StatelessWidget {
  /// Widget yang ditampilkan di dalam card.
  final Widget child;

  /// Intensitas blur backdrop filter (sigma). Default: 15.
  /// Range yang disarankan: 10–20 (GUD-002).
  final double blurIntensity;

  /// Warna background semi-transparan. Default: [IslamicColors.glassWhite].
  final Color backgroundColor;

  /// Warna border. Default: [IslamicColors.glassBorder].
  final Color borderColor;

  /// Border radius dalam logical pixels (akan di-scale via `.r`).
  /// Default: 16.
  final double borderRadius;

  /// Padding internal card. Default: `EdgeInsets.all(16.w)`.
  final EdgeInsetsGeometry? padding;

  /// Margin eksternal card. Default: null (tanpa margin).
  final EdgeInsetsGeometry? margin;

  /// Jika true, menampilkan golden glow [BoxShadow] di sekeliling card.
  /// Digunakan untuk menandai focused state (GUD-001).
  final bool isFocused;

  /// Jika false, menonaktifkan [BackdropFilter] blur untuk menghemat GPU.
  /// Gunakan pada widget yang dianimasikan secara kontinu (misal: marquee,
  /// running text) di perangkat Android TV spesifikasi rendah. Default: true.
  final bool useBlur;

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.blurIntensity = 15,
    this.backgroundColor = IslamicColors.glassWhite,
    this.borderColor = IslamicColors.glassBorder,
    this.borderRadius = 16,
    this.padding,
    this.margin,
    this.isFocused = false,
    this.useBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius.r),
      border: Border.all(color: borderColor, width: 1.w),
      boxShadow: isFocused
          ? [
              BoxShadow(
                color: IslamicColors.goldAmber.withValues(alpha: 0.3),
                blurRadius: 12.r,
                spreadRadius: 2.r,
              ),
            ]
          : null,
    );

    // Tanpa blur: render Container solid langsung, tanpa ClipRRect + BackdropFilter.
    // Digunakan untuk widget animasi kontinu agar tidak membebani GPU TV (GUD-002).
    if (!useBlur) {
      return Container(
        margin: margin,
        decoration: decoration,
        padding: padding ?? EdgeInsets.all(16.w),
        child: child,
      );
    }

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurIntensity,
            sigmaY: blurIntensity,
          ),
          child: Container(
            decoration: decoration,
            padding: padding ?? EdgeInsets.all(16.w),
            child: child,
          ),
        ),
      ),
    );
  }
}
