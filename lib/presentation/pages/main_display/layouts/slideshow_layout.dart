import 'dart:io';

import 'package:material_ui/material_ui.dart';

import '../../../../../core/theme/islamic_colors.dart';
import '../../../../domain/entities/display_state.dart';
import '../../../widgets/islamic_background.dart';

/// Layout runtime full-screen untuk menampilkan Slideshow Pengumuman Masjid.
///
/// **Struktur layout (TS-P7-001)**:
/// ```
/// IslamicBackground
///   └── Center
///         └── LayoutBuilder
///               └── FittedBox(BoxFit.scaleDown)
///                     └── SizedBox(1280 × 720)   ← kanvas aman
///                           └── Stack
///                                 ├── Container(black)
///                                 ├── Image.file(...)          ← gambar pengumuman
///                                 └── Positioned(bottom)       ← footer indikator
/// ```
///
/// **Catatan desain**:
/// - Tidak ada header besar (TS-P7-002); fokus utama adalah gambar pengumuman.
/// - Footer indikator ringan ditempatkan di bagian bawah kanvas (TS-P7-003),
///   hanya menampilkan posisi gambar (`1 / n`) dan sisa detik gambar aktif.
/// - Jika file gambar tidak ditemukan, ditampilkan placeholder error yang aman
///   tanpa crash (TS-P7-004).
///
/// Ref: Plan feature-slideshow-pengumuman-1.md Phase 7 (TASK-039..042)
class SlideshowLayout extends StatelessWidget {
  final SlideshowAnnouncementState state;

  const SlideshowLayout({super.key, required this.state});

  // Dimensi kanvas aman (REQ-020)
  static const double _canvasWidth = 1280;
  static const double _canvasHeight = 720;

  @override
  Widget build(BuildContext context) {
    return IslamicBackground(
      child: Center(
        child: LayoutBuilder(
          builder: (_, _) {
            return FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: SizedBox(
                width: _canvasWidth,
                height: _canvasHeight,
                child: _buildCanvas(),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Kanvas hitam 1280x720 berisi gambar dan footer indikator.
  Widget _buildCanvas() {
    return Stack(
      children: [
        // ── Layer dasar: canvas hitam ────────────────────────────────────── //
        Container(
          width: _canvasWidth,
          height: _canvasHeight,
          color: Colors.black,
        ),

        // ── Gambar pengumuman (TASK-041) ─────────────────────────────────── //
        // BoxFit.scaleDown memastikan gambar tidak ter-crop (REQ-021, PAT-005).
        // errorBuilder menampilkan placeholder aman jika file tidak ditemukan (TS-P7-004).
        Positioned.fill(
          child: Image.file(
            File(state.currentImage.storedPath),
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            errorBuilder: (_, _, _) => _buildErrorPlaceholder(),
          ),
        ),

        // ── Footer indikator di bagian bawah kanvas (TASK-042, TS-P7-003) ── //
        Positioned(left: 0, right: 0, bottom: 0, child: _buildFooter()),
      ],
    );
  }

  /// Footer minimal: posisi gambar + sisa detik. Visual ringan, tidak
  /// menutupi area inti gambar (TS-P7-003).
  Widget _buildFooter() {
    final imagePosition = '${state.currentIndex + 1} / ${state.totalItems}';
    final remainingSecs = state.remainingImageSeconds;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.65), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Posisi gambar: "1 / 3"
          Row(
            children: [
              Icon(Icons.slideshow, color: IslamicColors.goldAmber, size: 18),
              const SizedBox(width: 6),
              Text(
                imagePosition,
                style: const TextStyle(
                  color: IslamicColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Sisa waktu gambar (detik)
          Text(
            '$remainingSecs dtk',
            style: const TextStyle(
              color: IslamicColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Placeholder aman jika file gambar tidak ditemukan (TS-P7-004).
  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              color: IslamicColors.textSecondary,
              size: 72,
            ),
            const SizedBox(height: 16),
            Text(
              'File gambar tidak ditemukan',
              style: TextStyle(
                color: IslamicColors.textSecondary,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.currentImage.fileName,
              style: TextStyle(
                color: IslamicColors.textSecondary.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
