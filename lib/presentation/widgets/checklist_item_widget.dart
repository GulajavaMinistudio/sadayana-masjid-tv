import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/islamic_colors.dart';
import '../../core/theme/islamic_typography.dart';
import 'focusable_widget.dart';

/// Widget checklist reusable untuk item Kata Mutiara di Settings UI.
///
/// Menampilkan:
/// - Badge oval tipe (teal untuk Quran, amber untuk Hadits)
/// - Kolom teks: label judul + preview terjemahan (1 baris, ellipsis)
/// - Ikon centang di kanan
///
/// Support D-Pad navigation via [FocusableWidget]: D-Pad select / tap
/// memanggil [onChanged] dengan nilai toggled dari [isChecked].
///
/// Ref: Plan feature-wisdom-quote-1.md TASK-037, TASK-038
class ChecklistItemWidget extends StatelessWidget {
  /// Identifier unik item (misal: `"quran_001"`, `"hadith_003"`).
  final String id;

  /// Tipe konten: `"quran"` atau `"hadith"`. Menentukan warna badge.
  final String type;

  /// Label tampilan tipe (misal: `"Ayat Al-Quran"`, `"Hadits"`).
  final String label;

  /// Teks terjemahan yang ditampilkan sebagai preview (maksimal 1 baris).
  final String translationText;

  /// Status centang saat ini.
  final bool isChecked;

  /// Callback dipanggil dengan nilai baru saat item di-toggle.
  final ValueChanged<bool> onChanged;

  const ChecklistItemWidget({
    super.key,
    required this.id,
    required this.type,
    required this.label,
    required this.translationText,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FocusableWidget(
      onSelect: () => onChanged(!isChecked),
      builder: (isFocused) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isFocused
              ? IslamicColors.primaryTeal.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isFocused
                ? IslamicColors.primaryTeal
                : IslamicColors.primaryTeal.withValues(alpha: 0.0),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            _buildBadge(),
            SizedBox(width: 16.w),
            Expanded(child: _buildTextColumn()),
            SizedBox(width: 16.w),
            _buildCheckIcon(),
          ],
        ),
      ),
    );
  }

  /// Badge oval kecil berisi ikon dan label tipe.
  ///
  /// Teal untuk Quran (🕌), amber untuk Hadits (📖).
  Widget _buildBadge() {
    final isQuran = type == 'quran';
    final badgeColor = isQuran
        ? IslamicColors.primaryTeal
        : IslamicColors.goldAmber;
    final badgeIcon = isQuran ? '🕌' : '📖';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: badgeColor, width: 1.0),
      ),
      child: Text(
        '$badgeIcon  $label',
        style: IslamicTypography.caption(
          color: badgeColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Kolom teks: label judul + preview terjemahan (1 baris, ellipsis).
  Widget _buildTextColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          translationText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: IslamicTypography.body(color: IslamicColors.textPrimary),
        ),
      ],
    );
  }

  /// Ikon centang di sisi kanan: filled gold saat checked, muted saat tidak.
  Widget _buildCheckIcon() {
    return Icon(
      isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
      size: 28.r,
      color: isChecked ? IslamicColors.goldAmber : IslamicColors.textMuted,
    );
  }
}
