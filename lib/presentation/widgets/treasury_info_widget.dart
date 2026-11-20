import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../core/theme/islamic_colors.dart';
import '../../core/theme/islamic_typography.dart';
import 'glassmorphism_card.dart';

/// Widget display Informasi Kas Masjid untuk halaman utama (Standby Layout).
///
/// Menampilkan saldo kas, pemasukan, dan pengeluaran dalam format Rupiah
/// di dalam [GlassmorphismCard]. Widget ini bersifat pure presentational —
/// menerima data via constructor params, tidak mengakses state secara langsung.
///
/// Dipasang di panel kanan Standby Layout, di bawah card "Sholat Berikutnya",
/// hanya saat `isTreasuryEnabled == true` pada [Settings].
///
/// Ref: Plan feature-treasury-info-1.md Phase 7 (TASK-026 s.d. TASK-029)
class TreasuryInfoWidget extends StatelessWidget {
  /// Saldo kas masjid dalam satuan Rupiah.
  final int balance;

  /// Pemasukan periode ini dalam satuan Rupiah.
  final int income;

  /// Pengeluaran periode ini dalam satuan Rupiah.
  final int expense;

  const TreasuryInfoWidget({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
  });

  /// Format integer ke string Rupiah: 12500000 → "Rp 12.500.000"
  /// Ref: TASK-029, GUD-001
  String _formatRupiah(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphismCard(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title row: ikon wallet + label "Kas Masjid" — TASK-028
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: IslamicColors.goldAmber,
                size: 24.sp,
              ),
              SizedBox(width: 10.w),
              Text(
                'Kas Masjid',
                style: IslamicTypography.subtitle(
                  color: IslamicColors.goldAmber,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Baris Saldo — font subtitle, warna textPrimary — TASK-028, TASK-029
          _buildBalanceRow(),
          SizedBox(height: 10.h),

          // Baris Pemasukan — icon ▲ hijau, font body — TASK-028, TASK-029
          _buildAmountRow(
            label: 'Pemasukan',
            amount: income,
            icon: Icons.arrow_upward,
            iconColor: IslamicColors.success,
          ),
          SizedBox(height: 8.h),

          // Baris Pengeluaran — icon ▼ oranye, font body — TASK-028, TASK-029
          _buildAmountRow(
            label: 'Pengeluaran',
            amount: expense,
            icon: Icons.arrow_downward,
            iconColor: IslamicColors.warning,
          ),
        ],
      ),
    );
  }

  /// Baris Saldo dengan font subtitle (lebih besar) sesuai TASK-029.
  Widget _buildBalanceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Saldo',
          style: IslamicTypography.subtitle(color: IslamicColors.textSecondary),
        ),
        Text(
          _formatRupiah(balance),
          style: IslamicTypography.subtitle(
            color: IslamicColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Baris pemasukan/pengeluaran dengan font body sesuai TASK-029.
  Widget _buildAmountRow({
    required String label,
    required int amount,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 28.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: IslamicTypography.body(color: IslamicColors.textSecondary),
            ),
          ],
        ),
        Text(
          _formatRupiah(amount),
          style: IslamicTypography.body(color: IslamicColors.textPrimary),
        ),
      ],
    );
  }
}
