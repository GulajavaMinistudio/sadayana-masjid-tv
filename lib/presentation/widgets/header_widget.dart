import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../core/theme/islamic_colors.dart';
import '../../core/theme/islamic_typography.dart';
import 'glassmorphism_card.dart';

// TASK-012 (Phase 5): Dikonversi ke StatefulWidget untuk meng-cache masehiDate.
// DateFormat('id_ID') hanya dijalankan saat hari berganti, bukan setiap detik.
class HeaderWidget extends StatefulWidget {
  final String mosqueName;
  final String mosqueAddress;
  final String hijriDate;
  final DateTime currentTime;
  final bool isSettingsVisible;

  const HeaderWidget({
    super.key,
    required this.mosqueName,
    required this.mosqueAddress,
    required this.hijriDate,
    required this.currentTime,
    this.isSettingsVisible = false,
  });

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  String _masehiDate = '';
  int _cachedDay = -1;

  @override
  void initState() {
    super.initState();
    _updateDateIfNeeded();
  }

  @override
  void didUpdateWidget(HeaderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateDateIfNeeded();
  }

  // Jalankan DateFormat hanya saat tanggal (hari) benar-benar berubah.
  void _updateDateIfNeeded() {
    final day = widget.currentTime.day;
    if (day != _cachedDay) {
      _cachedDay = day;
      _masehiDate = DateFormat(
        'EEEE, dd MMMM yyyy',
        'id_ID',
      ).format(widget.currentTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Animated right padding: reserves space when settings icon is visible,
    // fills in when icon is hidden — smooth slide transition.
    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(right: widget.isSettingsVisible ? 100.w : 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Kiri: Logo & Nama Masjid
          Expanded(
            child: Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 80.w,
                    height: 80.w,
                    child: Image.asset(
                      'assets/images/mktv_icon_large.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 24.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.mosqueName.isNotEmpty
                            ? widget.mosqueName
                            : 'Masjid Anda',
                        style: IslamicTypography.heading(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        widget.mosqueAddress.isNotEmpty
                            ? widget.mosqueAddress
                            : 'Menunggu Pengaturan',
                        style: IslamicTypography.body(),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 24.w),

          // Kanan: Tanggal Hijriah & Masehi
          GlassmorphismCard(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.hijriDate.isNotEmpty
                      ? widget.hijriDate
                      : 'Memuat Tanggal Hijriah...',
                  style: IslamicTypography.subtitle().copyWith(
                    color: IslamicColors.goldAmber,
                    fontWeight: FontWeight.bold,
                    fontSize: 34.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _masehiDate,
                  style: IslamicTypography.body().copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 28.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
