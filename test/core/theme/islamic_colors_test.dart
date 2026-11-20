import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:miqotul_khoir_tv/core/theme/islamic_colors.dart';

/// Unit tests untuk [IslamicColors] — validasi color constants.
///
/// Ref: Plan 03 TASK-033 s.d. TASK-035
void main() {
  // ---------------------------------------------------------------------------
  // TEST: Semua color groups terdefinisi (non-null)
  // ---------------------------------------------------------------------------

  group('IslamicColors — Primary Colors', () {
    test('deepTeal, primaryTeal, lightTeal are defined', () {
      expect(IslamicColors.deepTeal, isA<Color>());
      expect(IslamicColors.primaryTeal, isA<Color>());
      expect(IslamicColors.lightTeal, isA<Color>());
    });

    test('primary colors have correct hex values', () {
      expect(IslamicColors.deepTeal.toARGB32(), equals(0xFF075B5E));
      expect(IslamicColors.primaryTeal.toARGB32(), equals(0xFF0E9296));
      expect(IslamicColors.lightTeal.toARGB32(), equals(0xFF1CC0C5));
    });
  });

  group('IslamicColors — Accent Colors', () {
    test('goldAmber, lightGold, warmGold are defined', () {
      expect(IslamicColors.goldAmber, isA<Color>());
      expect(IslamicColors.lightGold, isA<Color>());
      expect(IslamicColors.warmGold, isA<Color>());
    });

    test('accent colors have correct hex values', () {
      expect(IslamicColors.goldAmber.toARGB32(), equals(0xFFD4A012));
      expect(IslamicColors.lightGold.toARGB32(), equals(0xFFE8C547));
      expect(IslamicColors.warmGold.toARGB32(), equals(0xFFF5D060));
    });
  });

  group('IslamicColors — Background Colors', () {
    test('darkBackground, surfaceDark, surfaceLight are defined', () {
      expect(IslamicColors.darkBackground, isA<Color>());
      expect(IslamicColors.surfaceDark, isA<Color>());
      expect(IslamicColors.surfaceLight, isA<Color>());
    });
  });

  group('IslamicColors — Text Colors', () {
    test('textPrimary, textSecondary, textMuted are defined', () {
      expect(IslamicColors.textPrimary, isA<Color>());
      expect(IslamicColors.textSecondary, isA<Color>());
      expect(IslamicColors.textMuted, isA<Color>());
    });
  });

  group('IslamicColors — Glassmorphism Colors (opacity validation)', () {
    test('glassWhite has ~10% opacity (alpha ≈ 26)', () {
      // 0x1A = 26, 26/255 ≈ 10.2%
      expect(IslamicColors.glassWhite.a, closeTo(26 / 255, 0.01));
    });

    test('glassBorder has ~20% opacity (alpha ≈ 51)', () {
      // 0x33 = 51, 51/255 ≈ 20%
      expect(IslamicColors.glassBorder.a, closeTo(51 / 255, 0.01));
    });

    test('glassOverlay has ~5% opacity (alpha ≈ 13)', () {
      // 0x0D = 13, 13/255 ≈ 5.1%
      expect(IslamicColors.glassOverlay.a, closeTo(13 / 255, 0.01));
    });

    test('glass colors are white-based (r=g=b=1.0)', () {
      expect(IslamicColors.glassWhite.r, equals(1.0));
      expect(IslamicColors.glassWhite.g, equals(1.0));
      expect(IslamicColors.glassWhite.b, equals(1.0));
    });
  });

  group('IslamicColors — State Colors', () {
    test('success, error, warning, info are defined', () {
      expect(IslamicColors.success, isA<Color>());
      expect(IslamicColors.error, isA<Color>());
      expect(IslamicColors.warning, isA<Color>());
      expect(IslamicColors.info, isA<Color>());
    });
  });

  group('IslamicColors — Prayer State Colors', () {
    test('all 5 prayer state colors are defined', () {
      expect(IslamicColors.standbyColor, isA<Color>());
      expect(IslamicColors.preAdzanColor, isA<Color>());
      expect(IslamicColors.adzanColor, isA<Color>());
      expect(IslamicColors.iqomahColor, isA<Color>());
      expect(IslamicColors.sholatColor, isA<Color>());
    });

    test('standbyColor equals deepTeal', () {
      expect(IslamicColors.standbyColor, equals(IslamicColors.deepTeal));
    });

    test('adzanColor equals goldAmber', () {
      expect(IslamicColors.adzanColor, equals(IslamicColors.goldAmber));
    });

    test('sholatColor equals deepTeal', () {
      expect(IslamicColors.sholatColor, equals(IslamicColors.deepTeal));
    });
  });
}
