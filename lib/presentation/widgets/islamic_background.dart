import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../core/theme/islamic_colors.dart';

/// Animated background widget dengan Islamic-inspired design dan anti burn-in.
///
/// Menampilkan layered gradient background:
/// - Layer 1: [LinearGradient] diagonal dari [IslamicColors.darkBackground]
///   ke [IslamicColors.surfaceDark]
/// - Layer 2: [RadialGradient] subtle teal glow di center (opacity 0.1)
///
/// Anti screen burn-in: gradient alignment di-shift sedikit (±0.5%) setiap
/// 60 detik via [Timer.periodic] (TASK-015, REQ-005).
///
/// Ref: Plan 04 TASK-013 s.d. TASK-016
class IslamicBackground extends StatefulWidget {
  /// Widget yang ditampilkan di atas background.
  final Widget child;

  const IslamicBackground({super.key, required this.child});

  @override
  State<IslamicBackground> createState() => _IslamicBackgroundState();
}

class _IslamicBackgroundState extends State<IslamicBackground> {
  /// Timer untuk anti screen burn-in mechanism.
  Timer? _burnInTimer;

  /// Offset alignment untuk gradient shift (anti burn-in).
  /// Nilai berubah ±0.5% setiap 60 detik.
  double _alignmentOffset = 0.0;

  /// Arah shift saat ini (+1 atau -1).
  int _shiftDirection = 1;

  @override
  void initState() {
    super.initState();
    _startBurnInTimer();
  }

  @override
  void dispose() {
    _burnInTimer?.cancel();
    super.dispose();
  }

  /// Memulai timer anti burn-in yang shift gradient alignment setiap 60 detik.
  void _startBurnInTimer() {
    _burnInTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _shiftGradient(),
    );
  }

  /// Menggeser alignment gradient sebesar 0.005 (0.5%) untuk mencegah burn-in.
  void _shiftGradient() {
    setState(() {
      _alignmentOffset += _shiftDirection * 0.005;
      // Balik arah saat mencapai batas ±0.02 (2%)
      if (_alignmentOffset.abs() >= 0.02) {
        _shiftDirection = -_shiftDirection;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final offset = _alignmentOffset;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Layer 1: Linear gradient diagonal — background utama
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + offset, -1.0 + offset),
              end: Alignment(1.0 + offset, 1.0 + offset),
              colors: const [
                IslamicColors.darkBackground,
                IslamicColors.surfaceDark,
              ],
            ),
          ),
        ),

        // Layer 2: Radial gradient — subtle emerald glow di center
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(offset, offset),
              radius: 1.2,
              colors: [
                IslamicColors.primaryTeal.withValues(alpha: 0.1),
                Colors.transparent,
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        ),

        // Layer 3: Mosque Silhouette (Glassmorphism overlay & Anti Burn-in)
        // Fill penuh layar (cover) dengan micro-movement parallax anti burn-in.
        Positioned.fill(
          child: Transform.translate(
            // Micro-movement selaras dengan offset gradient anti burn-in
            offset: Offset(offset * 1000, 0),
            child: ColorFiltered(
              // Filter matrix: Solid White → Transparent, Hitam/Abu → Siluet tipis 15%.
              colorFilter: const ColorFilter.matrix([
                0, 0, 0, 0, 0, // R'
                0, 0, 0, 0, 0, // G'
                0, 0, 0, 0, 0, // B'
                -0.05, -0.05, -0.05, 0.15, 0, // A' ≈ 0.15*(1-L)
              ]),
              child: Image.asset(
                'assets/images/mosque_silhouette.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        // Content layer — child di atas background
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: widget.child,
        ),
      ],
    );
  }
}
