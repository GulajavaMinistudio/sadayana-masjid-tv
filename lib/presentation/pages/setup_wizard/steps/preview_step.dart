import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/islamic_colors.dart';
import '../../../../core/theme/islamic_typography.dart';
import '../../../../domain/entities/daily_prayer_times.dart';
import '../../../../domain/entities/settings.dart';
import '../../../../domain/entities/setup_wizard_data.dart';
import '../../../../domain/usecases/calculate_prayer_times_use_case.dart';
import '../../../../domain/repositories/settings_repository.dart';
import '../../../cubits/setup_wizard/setup_wizard_cubit.dart';
import '../../../cubits/setup_wizard/setup_wizard_state.dart';
import '../../../widgets/focusable_widget.dart';
import '../../../widgets/glassmorphism_card.dart';

class PreviewStep extends StatefulWidget {
  const PreviewStep({super.key});

  @override
  State<PreviewStep> createState() => _PreviewStepState();
}

class _PreviewStepState extends State<PreviewStep> {
  late final CalculatePrayerTimesUseCase _useCase;

  DailyPrayerTimes? _prayerTimes;
  SetupWizardData? _lastData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inisialisasi use case dengan repository dari context (sekali saja)
    _useCase = CalculatePrayerTimesUseCase(context.read<SettingsRepository>());
  }

  /// Hitung ulang waktu sholat jika data wizard berubah.
  void _recalculateIfNeeded(SetupWizardData data) {
    if (data == _lastData) return;
    _lastData = data;

    if (!data.isLocationValid) {
      if (mounted) setState(() => _prayerTimes = null);
      return;
    }

    // Buat Settings sementara dari SetupWizardData untuk preview
    final tempSettings = Settings(
      cityName: data.cityName,
      provinceName: data.provinceName,
      latitude: data.latitude,
      longitude: data.longitude,
      timezone: data.timezone,
      calculationMethod: data.calculationMethod,
      elevation: data.elevation,
    );

    try {
      final result = _useCase.executeWithSettings(tempSettings);
      if (mounted) setState(() => _prayerTimes = result);
    } catch (_) {
      if (mounted) setState(() => _prayerTimes = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SetupWizardCubit, SetupWizardState>(
      listener: (context, state) {},
      builder: (context, state) {
        final isCompleting = state is SetupWizardCompleting;

        SetupWizardData data;
        if (state is SetupWizardInProgress) {
          data = state.data;
        } else if (state is SetupWizardCompleting) {
          data = state.data;
        } else {
          data = const SetupWizardData();
        }

        // Hitung ulang jika data berubah (post frame agar tidak setState during build)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _recalculateIfNeeded(data);
        });

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: SizedBox(
                    width: 1000.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Konfirmasi Pengaturan',
                          style: IslamicTypography.heading(
                            color: IslamicColors.goldAmber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Pastikan data di bawah ini sudah benar sebelum menyimpan.',
                          style: IslamicTypography.body(
                            color: IslamicColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 48.h),

                        // Summary Card
                        GlassmorphismCard(
                          child: Padding(
                            padding: EdgeInsets.all(32.w),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Column: Identity & Location
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildSummaryItem(
                                        icon: Icons.mosque,
                                        label: 'Nama Masjid',
                                        value: data.mosqueName.isNotEmpty
                                            ? data.mosqueName
                                            : '-',
                                      ),
                                      SizedBox(height: 24.h),
                                      _buildSummaryItem(
                                        icon: Icons.location_on,
                                        label: 'Alamat',
                                        value: data.mosqueAddress.isNotEmpty
                                            ? data.mosqueAddress
                                            : '-',
                                      ),
                                      SizedBox(height: 24.h),
                                      _buildSummaryItem(
                                        icon: Icons.map,
                                        label: 'Kota / Kabupaten',
                                        value: data.cityName.isNotEmpty
                                            ? data.cityName
                                            : '-',
                                      ),
                                    ],
                                  ),
                                ),
                                // Divider
                                Container(
                                  width: 1.w,
                                  height: 200.h,
                                  color: IslamicColors.glassBorder,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 32.w,
                                  ),
                                ),
                                // Right Column: Prayer Times Preview (calculated)
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Jadwal Sholat Hari Ini',
                                        style: IslamicTypography.title(
                                          color: IslamicColors.goldAmber,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 16.h),
                                      _buildPrayerTimesSection(data),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 48.h),

                        // Navigation Buttons (or Loading)
                        if (isCompleting)
                          Column(
                            children: [
                              const CircularProgressIndicator(
                                color: IslamicColors.goldAmber,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'Menyimpan pengaturan...',
                                style: IslamicTypography.body(
                                  color: IslamicColors.textMuted,
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildNavButton(
                                label: 'Kembali',
                                isPrimary: false,
                                onPressed: () => context
                                    .read<SetupWizardCubit>()
                                    .goToPreviousStep(),
                              ),
                              SizedBox(width: 24.w),
                              _buildNavButton(
                                label: 'Simpan & Selesai',
                                isPrimary: true,
                                onPressed: () => context
                                    .read<SetupWizardCubit>()
                                    .completeSetup(),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPrayerTimesSection(SetupWizardData data) {
    if (!data.isLocationValid) {
      return Text(
        'Pilih kota terlebih dahulu',
        style: IslamicTypography.body(color: IslamicColors.textMuted),
      );
    }

    final times = _prayerTimes;
    if (times == null) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(
            color: IslamicColors.goldAmber,
            strokeWidth: 2,
          ),
        ),
      );
    }

    // Hanya tampilkan 5 waktu utama
    final mainPrayers = [
      times.subuh,
      times.dzuhur,
      times.ashar,
      times.maghrib,
      times.isya,
    ];

    return Column(
      children: mainPrayers
          .map((p) => _buildPrayerTimeRow(p.name, _formatTime(p.time)))
          .toList(),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: IslamicColors.goldAmber, size: 24.w),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: IslamicTypography.caption(
                  color: IslamicColors.textMuted,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: IslamicTypography.title(
                  color: IslamicColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerTimeRow(String name, String time) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              name,
              style: IslamicTypography.body(color: IslamicColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              time,
              style: IslamicTypography.body(color: IslamicColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required String label,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return FocusableWidget(
      onSelect: onPressed,
      builder: (isFocused) {
        final baseColor = isPrimary
            ? IslamicColors.goldAmber
            : IslamicColors.surfaceLight;
        final textColor = isPrimary
            ? IslamicColors.deepTeal
            : IslamicColors.textPrimary;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 280.w,
          height: 56.h,
          decoration: BoxDecoration(
            color: isFocused ? baseColor.withValues(alpha: 0.9) : baseColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isFocused
                  ? IslamicColors.textPrimary
                  : (isPrimary
                        ? Colors.transparent
                        : IslamicColors.glassBorder),
              width: 2.0,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: baseColor.withValues(alpha: 0.5),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                label,
                style: IslamicTypography.title(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
