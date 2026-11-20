import 'package:material_ui/material_ui.dart';

/// Islamic Glassmorphism color palette constants.
///
/// Semua warna didefinisikan sebagai `static const Color` sesuai PAT-001.
/// Tidak ada hardcoded color values di luar file ini — akses via class ini
/// atau `Theme.of(context)`.
///
/// Ref: Plan 03 TASK-004 s.d. TASK-011 | Refactor: refactor-theme-color-teal-1.md
class IslamicColors {
  // ---------------------------------------------------------------------------
  // Private constructor — prevent instantiation
  // ---------------------------------------------------------------------------
  const IslamicColors._();

  // ---------------------------------------------------------------------------
  // Primary Colors — Teal palette (#036666 / #248277 / #3AA898)
  // ---------------------------------------------------------------------------

  /// Warna utama paling gelap — background utama, state STANDBY & SHOLAT
  static const Color deepTeal = Color(0xFF075B5E);

  /// Warna teal medium — primary accent, card borders
  static const Color primaryTeal = Color(0xFF0E9296);

  /// Warna teal terang — hover states, highlights, D-Pad focus glow
  static const Color lightTeal = Color(0xFF1CC0C5);

  // ---------------------------------------------------------------------------
  // Accent Colors — Gold/Amber palette (tidak berubah)
  // ---------------------------------------------------------------------------

  /// Warna gold utama — CTA, adzan state, highlights
  static const Color goldAmber = Color(0xFFD4A012);

  /// Warna gold terang — secondary highlights
  static const Color lightGold = Color(0xFFE8C547);

  /// Warna gold hangat — subtle accents
  static const Color warmGold = Color(0xFFF5D060);

  // ---------------------------------------------------------------------------
  // Background Colors — diturunkan dari deepTeal (#036666)
  // ---------------------------------------------------------------------------

  /// Background paling gelap — scaffold background
  static const Color darkBackground = Color(0xFF041E1E);

  /// Surface gelap — card backgrounds, panels
  static const Color surfaceDark = Color(0xFF082E2E);

  /// Surface sedikit lebih terang — nested containers
  static const Color surfaceLight = Color(0xFF0F4343);

  // ---------------------------------------------------------------------------
  // Text Colors — diselaraskan ke tone Teal
  // ---------------------------------------------------------------------------

  /// Teks utama — hampir putih, high contrast
  static const Color textPrimary = Color(0xFFF5F5F5);

  /// Teks sekunder — abu-abu ke-teal-an, medium contrast
  static const Color textSecondary = Color(0xFFB0C9C6);

  /// Teks muted — low contrast, untuk label kecil
  static const Color textMuted = Color(0xFF739A95);

  // ---------------------------------------------------------------------------
  // Glassmorphism Colors — semi-transparent overlays (tidak berubah)
  // ---------------------------------------------------------------------------

  /// Glass white overlay — ~10% opacity (0x1A = 26/255 ≈ 10.2%)
  static const Color glassWhite = Color(0x1AFFFFFF);

  /// Glass border — ~20% opacity (0x33 = 51/255 ≈ 20%)
  static const Color glassBorder = Color(0x33FFFFFF);

  /// Glass overlay paling tipis — ~5% opacity (0x0D = 13/255 ≈ 5.1%)
  static const Color glassOverlay = Color(0x0DFFFFFF);

  // ---------------------------------------------------------------------------
  // State Colors — semantic feedback colors (tidak berubah)
  // ---------------------------------------------------------------------------

  /// Warna sukses — hijau Material
  static const Color success = Color(0xFF4CAF50);

  /// Warna error — merah Material
  static const Color error = Color(0xFFE53935);

  /// Warna warning — oranye Material
  static const Color warning = Color(0xFFFFA726);

  /// Warna info — biru Material
  static const Color info = Color(0xFF42A5F5);

  // ---------------------------------------------------------------------------
  // Prayer State Colors — untuk Display State Machine
  // ---------------------------------------------------------------------------

  /// Warna state STANDBY — deep teal, tenang
  static const Color standbyColor = deepTeal;

  /// Warna state PRE-ADZAN — midpoint antara deepTeal dan primaryTeal
  static const Color preAdzanColor = Color(0xFF14706E);

  /// Warna state ADZAN — gold amber, highlight utama
  static const Color adzanColor = goldAmber;

  /// Warna state IQOMAH — dark gold, transisi
  static const Color iqomahColor = Color(0xFFB8860B);

  /// Warna state SHOLAT — deep teal, khusyuk
  static const Color sholatColor = deepTeal;
}
