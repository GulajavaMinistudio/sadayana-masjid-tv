import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/islamic_colors.dart';
import '../../../../core/theme/islamic_typography.dart';
import '../../../cubits/settings/settings_cubit.dart';
import '../../../cubits/settings/settings_state.dart';
import '../../../widgets/focusable_widget.dart';

/// Section pengaturan Informasi Kas Masjid.
///
/// Menampilkan toggle aktif/nonaktif dan 3 input numerik:
/// Saldo Kas, Pemasukan Periode Ini, dan Pengeluaran Periode Ini.
/// Semua perubahan disimpan otomatis via [SettingsCubit].
///
/// Ref: Plan feature-treasury-info-1.md Phase 5 (TASK-015 s.d. TASK-022)
class TreasurySection extends StatefulWidget {
  const TreasurySection({super.key});

  @override
  State<TreasurySection> createState() => _TreasurySectionState();
}

class _TreasurySectionState extends State<TreasurySection> {
  late final TextEditingController _balanceController;
  late final TextEditingController _incomeController;
  late final TextEditingController _expenseController;

  // skipTraversal: true → tidak masuk D-pad traversal, tapi masih bisa
  // difokuskan secara programatik via requestFocus() untuk membuka keyboard.
  final FocusNode _balanceFocusNode = FocusNode(skipTraversal: true);
  final FocusNode _incomeFocusNode = FocusNode(skipTraversal: true);
  final FocusNode _expenseFocusNode = FocusNode(skipTraversal: true);

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _balanceController = TextEditingController();
    _incomeController = TextEditingController();
    _expenseController = TextEditingController();
  }

  @override
  void dispose() {
    _balanceController.dispose();
    _incomeController.dispose();
    _expenseController.dispose();
    _balanceFocusNode.dispose();
    _incomeFocusNode.dispose();
    _expenseFocusNode.dispose();
    super.dispose();
  }

  /// Inisialisasi controller dari state yang sudah loaded — hanya sekali.
  void _initControllers(SettingsLoaded state) {
    if (_initialized) return;
    _initialized = true;
    _balanceController.text = state.settings.treasuryBalance.toString();
    _incomeController.text = state.settings.treasuryIncome.toString();
    _expenseController.text = state.settings.treasuryExpense.toString();
  }

  /// Format integer ke string Rupiah: 12500000 → "Rp 12.500.000"
  /// Ref: TASK-022, GUD-001
  String _formatRupiah(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) =>
          previous is! SettingsLoaded && current is SettingsLoaded,
      listener: (context, state) {
        if (state is SettingsLoaded) {
          _initControllers(state);
        }
      },
      builder: (context, state) {
        if (state is! SettingsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final settings = state.settings;
        final cubit = context.read<SettingsCubit>();
        _initControllers(state);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: ikon + judul
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: IslamicColors.goldAmber,
                  size: 28.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Informasi Kas Masjid',
                  style: IslamicTypography.heading(),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Tampilkan informasi kas masjid di layar utama. '
              'Admin dapat mengisi saldo, pemasukan, dan pengeluaran secara manual.',
              style: IslamicTypography.subtitle(
                color: IslamicColors.textSecondary,
              ),
            ),
            SizedBox(height: 32.h),

            // Scrollable content area
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toggle: Aktifkan tampilan kas di layar utama — TASK-017
                    FocusableWidget(
                      onSelect: () {
                        cubit.updateTreasuryEnabled(
                          !settings.isTreasuryEnabled,
                        );
                      },
                      builder: (isFocused) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: IslamicColors.glassWhite,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isFocused
                                  ? IslamicColors.goldAmber
                                  : IslamicColors.glassBorder,
                              width: isFocused ? 2.0 : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tampilkan Info Kas di Layar Utama',
                                style: IslamicTypography.body(
                                  color: IslamicColors.textPrimary,
                                ),
                              ),
                              Switch.adaptive(
                                value: settings.isTreasuryEnabled,
                                onChanged: (val) =>
                                    cubit.updateTreasuryEnabled(val),
                                activeThumbColor: IslamicColors.goldAmber,
                                activeTrackColor: IslamicColors.goldAmber
                                    .withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Aktifkan untuk menampilkan informasi kas di layar utama.',
                      style: IslamicTypography.body(
                        color: IslamicColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    Divider(color: IslamicColors.glassBorder),
                    SizedBox(height: 24.h),

                    // Input groups — disabled (opacity 0.4) saat toggle OFF — TASK-018
                    // ExcludeFocus: mencegah TextField mendapat fokus via D-pad
                    // saat kas dinonaktifkan.
                    ExcludeFocus(
                      excluding: !settings.isTreasuryEnabled,
                      child: IgnorePointer(
                        ignoring: !settings.isTreasuryEnabled,
                        child: Opacity(
                          opacity: settings.isTreasuryEnabled ? 1.0 : 0.4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Input Group 1: Saldo Kas — TASK-019
                              _buildInputGroup(
                                label: 'Saldo Kas (Rp)',
                                icon: Icons.account_balance_wallet,
                                iconColor: IslamicColors.goldAmber,
                                controller: _balanceController,
                                textFocusNode: _balanceFocusNode,
                                onChanged: (val) {
                                  setState(() {});
                                  cubit.updateTreasuryBalance(
                                    int.tryParse(val) ?? 0,
                                  );
                                },
                              ),
                              SizedBox(height: 24.h),

                              // Input Group 2: Pemasukan — TASK-020
                              _buildInputGroup(
                                label: 'Pemasukan Periode Ini (Rp)',
                                icon: Icons.arrow_upward,
                                iconColor: IslamicColors.success,
                                controller: _incomeController,
                                textFocusNode: _incomeFocusNode,
                                onChanged: (val) {
                                  setState(() {});
                                  cubit.updateTreasuryIncome(
                                    int.tryParse(val) ?? 0,
                                  );
                                },
                              ),
                              SizedBox(height: 24.h),

                              // Input Group 3: Pengeluaran — TASK-021
                              _buildInputGroup(
                                label: 'Pengeluaran Periode Ini (Rp)',
                                icon: Icons.arrow_downward,
                                iconColor: IslamicColors.warning,
                                controller: _expenseController,
                                textFocusNode: _expenseFocusNode,
                                onChanged: (val) {
                                  setState(() {});
                                  cubit.updateTreasuryExpense(
                                    int.tryParse(val) ?? 0,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Auto-save indicator
                    if (state.isSaving)
                      Row(
                        children: [
                          SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Menyimpan...',
                            style: IslamicTypography.body(
                              color: IslamicColors.textMuted,
                            ),
                          ),
                        ],
                      )
                    else if (state.lastSavedField != null)
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: IslamicColors.success,
                            size: 16.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Tersimpan otomatis',
                            style: IslamicTypography.body(
                              color: IslamicColors.success,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Membangun satu input group dengan pola Android TV:
  /// - [FocusableWidget] sebagai target D-pad (kuning saat focused)
  /// - Tekan OK/Select → [textFocusNode.requestFocus()] membuka keyboard
  /// - [TextField] dibungkus [ExcludeFocus] agar tidak terjangkau traversal D-pad
  Widget _buildInputGroup({
    required String label,
    required IconData icon,
    required Color iconColor,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required FocusNode textFocusNode,
  }) {
    final rawValue = int.tryParse(controller.text) ?? 0;
    return FocusableWidget(
      onSelect: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          textFocusNode.requestFocus();
        });
      },
      builder: (isFocused) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: IslamicColors.glassWhite,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isFocused
                  ? IslamicColors.goldAmber
                  : IslamicColors.glassBorder,
              width: isFocused ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    label,
                    style: IslamicTypography.body(
                      color: isFocused
                          ? IslamicColors.goldAmber
                          : IslamicColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isFocused) ...[
                    const Spacer(),
                    Text(
                      'Tekan OK untuk edit',
                      style: IslamicTypography.body(
                        color: IslamicColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 8.h),
              TextField(
                focusNode: textFocusNode,
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: IslamicTypography.body(color: IslamicColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: IslamicTypography.body(
                    color: IslamicColors.textMuted,
                  ),
                  filled: true,
                  fillColor: IslamicColors.glassWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: IslamicColors.glassBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: IslamicColors.glassBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: IslamicColors.goldAmber,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                ),
                onChanged: onChanged,
              ),
              SizedBox(height: 6.h),
              Text(
                'Preview: ${_formatRupiah(rawValue)}',
                style: IslamicTypography.body(color: IslamicColors.textMuted),
              ),
            ],
          ),
        );
      },
    );
  }
}
