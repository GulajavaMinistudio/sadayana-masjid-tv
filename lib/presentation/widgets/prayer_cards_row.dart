import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../domain/entities/prayer_time.dart';
import '../../core/theme/islamic_colors.dart';
import '../../core/theme/islamic_typography.dart';
import 'glassmorphism_card.dart';

class PrayerCardsRow extends StatelessWidget {
  final List<PrayerTime> prayers;
  final PrayerTime? nextPrayer;

  const PrayerCardsRow({super.key, required this.prayers, this.nextPrayer});

  @override
  Widget build(BuildContext context) {
    if (prayers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: prayers.map((prayer) {
        final isNext = nextPrayer?.name == prayer.name;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: _PrayerCard(prayer: prayer, isNext: isNext),
          ),
        );
      }).toList(),
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final PrayerTime prayer;
  final bool isNext;

  const _PrayerCard({required this.prayer, required this.isNext});

  @override
  Widget build(BuildContext context) {
    // Jika menjadi sholat berikutnya, highlight dengan warna Gold
    final backgroundColor = isNext
        ? IslamicColors.goldAmber.withValues(alpha: 0.2)
        : IslamicColors.glassWhite;
    final borderColor = isNext
        ? IslamicColors.goldAmber
        : IslamicColors.glassBorder;
    final titleColor = isNext
        ? IslamicColors.goldAmber
        : IslamicColors.textSecondary;
    final timeColor = isNext
        ? IslamicColors.textPrimary
        : IslamicColors.textPrimary;

    return GlassmorphismCard(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      padding: EdgeInsets.symmetric(vertical: 28.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            prayer.name.toUpperCase(),
            style: IslamicTypography.overline(
              color: titleColor,
            ).copyWith(fontSize: 28.sp, letterSpacing: 2.0),
          ),
          SizedBox(height: 12.h),
          Text(
            prayer.formattedTime,
            style: IslamicTypography.heading(
              color: timeColor,
              fontWeight: FontWeight.bold,
            ).copyWith(fontSize: 40.sp),
          ),
        ],
      ),
    );
  }
}
