import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/islamic_colors.dart';
import '../../../../core/theme/islamic_typography.dart';
import '../../../../domain/entities/display_state.dart';
import '../../../widgets/glassmorphism_card.dart';

/// Layout khusus saat Adzan berkumandang
class AdzanLayout extends StatelessWidget {
  final AdzanState state;

  const AdzanLayout({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassmorphismCard(
        backgroundColor: IslamicColors.deepTeal.withValues(alpha: 0.85),
        borderColor: IslamicColors.goldAmber,
        padding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 80.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ikon penanda Adzan
            Icon(
              Icons.volume_up_rounded,
              size: 120.w,
              color: IslamicColors.goldAmber,
            ),
            SizedBox(height: 32.h),

            // Nama Sholat
            Text(
              'WAKTU ADZAN',
              style: IslamicTypography.display(
                color: IslamicColors.goldAmber,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),

            Text(
              state.currentPrayer.name.toUpperCase(),
              style: IslamicTypography.display(
                color: IslamicColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 48.h),

            // Pesan ajakan
            Text(
              'Harap Tenang, Mendengarkan, dan Menjawab Adzan',
              style: IslamicTypography.heading(
                color: IslamicColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
