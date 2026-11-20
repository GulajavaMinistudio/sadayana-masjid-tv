import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/islamic_colors.dart';
import '../../../../core/theme/islamic_typography.dart';
import '../../../../domain/entities/display_state.dart';
import '../../../widgets/digital_clock_widget.dart';

/// Layout layar hemat daya tengah malam.
///
/// Menampilkan background hitam mutlak dengan jam digital dan info Subuh.
/// Anti burn-in: blok teks bergeser posisi secara perlahan (drift animation).
///
/// Timer jam digital self-contained via [DigitalClockWidget] — tidak bergantung
/// pada rebuild dari parent (GUD-003). Animasi drift self-contained di dalam
/// widget ini menggunakan [AnimationController] + [AlignmentTween] (PAT-003).
class MidnightStandbyLayout extends StatefulWidget {
  final MidnightStandbyState state;

  const MidnightStandbyLayout({super.key, required this.state});

  @override
  State<MidnightStandbyLayout> createState() => _MidnightStandbyLayoutState();
}

class _MidnightStandbyLayoutState extends State<MidnightStandbyLayout>
    with SingleTickerProviderStateMixin {
  late AnimationController _driftController;
  late Animation<Alignment> _driftAnimation;

  // Daftar posisi aman dalam batas layar agar konten tidak terpotong di tepi.
  // Nilai dibatasi ±0.5 sehingga blok teks tetap terbaca.
  static const _safePositions = [
    Alignment(-0.40, -0.45),
    Alignment(0.35, -0.30),
    Alignment(-0.50, 0.05),
    Alignment(0.40, 0.30),
    Alignment(-0.20, 0.45),
    Alignment(0.10, -0.50),
    Alignment(-0.45, 0.20),
    Alignment(0.50, -0.10),
  ];

  @override
  void initState() {
    super.initState();

    // Seed deterministik berdasarkan menit saat ini agar posisi bervariasi
    // setiap kali mode aktif tanpa random murni.
    final seed = DateTime.now().minute;
    final begin = _safePositions[seed % _safePositions.length];
    final end = _safePositions[(seed + 4) % _safePositions.length];

    _driftController = AnimationController(
      vsync: this,
      // Durasi per arah ~30 detik → siklus penuh 60 detik (reverse: true).
      duration: const Duration(seconds: 30),
    );

    _driftAnimation = AlignmentTween(begin: begin, end: end).animate(
      CurvedAnimation(parent: _driftController, curve: Curves.easeInOut),
    );

    _driftController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _driftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // OverflowBox agar container hitam menutupi seluruh layar,
    // melewati batas TVSafeArea padding di parent (GUD-002).
    return OverflowBox(
      maxWidth: screenSize.width,
      maxHeight: screenSize.height,
      child: Container(
        color: Colors.black,
        width: screenSize.width,
        height: screenSize.height,
        child: AnimatedBuilder(
          animation: _driftAnimation,
          builder: (_, _) => Align(
            alignment: _driftAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Jam digital — self-contained timer, warna hijau redup
                // agar nyaman di ruangan gelap (REQ-007).
                Opacity(
                  opacity: 0.85,
                  child: DigitalClockWidget(
                    customStyle: IslamicTypography.display(
                      // Hijau redup — terbaca di gelap tanpa menyilaukan.
                      color: const Color(0xFF8DCFB5),
                      fontWeight: FontWeight.w300,
                    ).copyWith(fontSize: 160.sp, letterSpacing: -2),
                  ),
                ),
                SizedBox(height: 20.h),
                // Info jadwal Subuh hari ini.
                Text(
                  widget.state.subuhLabel,
                  style: IslamicTypography.subtitle(
                    color: IslamicColors.textSecondary.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
