import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/islamic_colors.dart';
import '../../../../core/theme/islamic_typography.dart';
import '../../../../domain/entities/imam.dart';
import '../../../../domain/entities/imam_schedule_display.dart';
import '../../../../domain/entities/settings.dart';
import '../../../../domain/repositories/imam_repository.dart';
import '../../../../domain/repositories/imam_schedule_repository.dart';
import '../../../cubits/display_state/display_state_cubit.dart';
import '../../../cubits/imam_schedule/imam_schedule_cubit.dart';
import '../../../cubits/imam_schedule/imam_schedule_state.dart';
import '../../../cubits/settings/settings_cubit.dart';
import '../../../cubits/settings/settings_state.dart';
import '../../../widgets/dpad_stepper.dart';
import '../../../widgets/focusable_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TASK-027 — Section wrapper: BlocProvider<ImamScheduleCubit> lokal
// ─────────────────────────────────────────────────────────────────────────────

/// Menampilkan pengaturan jadwal imam sholat berjamaah.
///
/// Menyediakan [ImamScheduleCubit] lokal via [BlocProvider] sehingga cubit
/// tidak mencemari scope global. [ImamRepository], [ImamScheduleRepository],
/// dan [DisplayStateCubit] dibaca dari ancestor context.
///
/// Ref: TASK-027 through TASK-035 (Phase 7 — Jadwal Imam Sholat Berjamaah)
class ImamScheduleSection extends StatelessWidget {
  const ImamScheduleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ImamScheduleCubit>(
      create: (ctx) => ImamScheduleCubit(
        imamRepository: ctx.read<ImamRepository>(),
        scheduleRepository: ctx.read<ImamScheduleRepository>(),
        displayStateCubit: ctx.read<DisplayStateCubit>(),
      )..loadAll(),
      child: const _ImamScheduleSectionContent(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TASK-028 through TASK-035 — Konten utama section
// ─────────────────────────────────────────────────────────────────────────────

class _ImamScheduleSectionContent extends StatefulWidget {
  const _ImamScheduleSectionContent();

  @override
  State<_ImamScheduleSectionContent> createState() =>
      _ImamScheduleSectionContentState();
}

class _ImamScheduleSectionContentState
    extends State<_ImamScheduleSectionContent> {
  /// Hari yang sedang ditampilkan di grid jadwal: 1=Senin, ..., 7=Minggu.
  int _selectedDay = 1;

  static const Map<int, String> _dayNames = {
    1: 'Senin',
    2: 'Selasa',
    3: 'Rabu',
    4: 'Kamis',
    5: "Jum'at",
    6: 'Sabtu',
    7: 'Minggu',
  };

  static String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        if (settingsState is! SettingsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final settings = settingsState.settings;
        final settingsCubit = context.read<SettingsCubit>();
        final enabled = settings.isImamScheduleEnabled;
        final locked = settings.isImamScheduleLocked;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TASK-028: Header
            _buildHeader(),
            SizedBox(height: 6.h),
            Text(
              'Tampilkan jadwal imam sholat berjamaah secara periodik di layar utama.',
              style: IslamicTypography.subtitle(
                color: IslamicColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),

            // TASK-029: Toggle aktifkan jadwal imam
            _buildToggleEnabled(settings, settingsCubit),
            SizedBox(height: 18.h),

            // Seluruh konten di bawah dinonaktifkan saat toggle OFF
            Expanded(
              child: SingleChildScrollView(
                child: ExcludeFocus(
                  excluding: !enabled,
                  child: IgnorePointer(
                    ignoring: !enabled,
                    child: Opacity(
                      opacity: enabled ? 1.0 : 0.4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TASK-031, 032: DPadStepper konfigurasi tampilan
                          _buildConfigBlock(settings, settingsCubit),
                          SizedBox(height: 50.h),

                          // TASK-033: DPadStepper jam aktif (4 stepper, Column)
                          _buildJamAktifBlock(settings, settingsCubit),
                          SizedBox(height: 16.h),
                          Divider(color: IslamicColors.glassBorder, height: 1),
                          SizedBox(height: 16.h),

                          // TASK-030: Toggle kunci jadwal + Area CRUD
                          // hasImams: kunci hanya boleh aktif jika ada imam terdaftar
                          // effectiveLocked: lock hanya berlaku jika ada data imam
                          BlocBuilder<ImamScheduleCubit, ImamScheduleState>(
                            builder: (context, imamState) {
                              final hasImams =
                                  imamState is ImamScheduleLoaded &&
                                  imamState.imams.isNotEmpty;
                              final effectiveLocked = locked && hasImams;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildToggleLocked(
                                    settings,
                                    settingsCubit,
                                    canLock: hasImams,
                                  ),
                                  SizedBox(height: 16.h),

                                  // Area CRUD — dinonaktifkan hanya jika terkunci
                                  // DAN ada data imam yang perlu dilindungi
                                  ExcludeFocus(
                                    excluding: effectiveLocked,
                                    child: IgnorePointer(
                                      ignoring: effectiveLocked,
                                      child: Opacity(
                                        opacity: effectiveLocked ? 0.4 : 1.0,
                                        child: () {
                                          if (imamState
                                                  is ImamScheduleInitial ||
                                              imamState
                                                  is ImamScheduleLoading) {
                                            return const Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(24),
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            );
                                          }
                                          if (imamState is ImamScheduleError) {
                                            return _buildError(
                                              context,
                                              imamState.message,
                                            );
                                          }
                                          if (imamState is ImamScheduleLoaded) {
                                            return _buildCrudContent(
                                              context,
                                              imamState,
                                              context.read<ImamScheduleCubit>(),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        }(),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ───────────────────── TASK-028 Header ──────────────────────────────────

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.mosque, color: IslamicColors.goldAmber, size: 38.sp),
        SizedBox(width: 12.w),
        Text('Jadwal Imam Sholat', style: IslamicTypography.heading()),
      ],
    );
  }

  // ───────────────────── TASK-029 Toggle Aktif ────────────────────────────

  Widget _buildToggleEnabled(Settings settings, SettingsCubit settingsCubit) {
    return FocusableWidget(
      autofocus: true,
      onSelect: () => settingsCubit.updateImamScheduleEnabled(
        !settings.isImamScheduleEnabled,
      ),
      builder: (isFocused) => Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
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
              'Aktifkan Jadwal Imam',
              style: IslamicTypography.body(color: IslamicColors.textPrimary),
            ),
            Switch.adaptive(
              value: settings.isImamScheduleEnabled,
              onChanged: null,
              activeThumbColor: IslamicColors.goldAmber,
              activeTrackColor: IslamicColors.goldAmber.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────── TASK-030 Toggle Kunci ────────────────────────────

  Widget _buildToggleLocked(
    Settings settings,
    SettingsCubit settingsCubit, {
    bool canLock = true,
  }) {
    return ExcludeFocus(
      excluding: !canLock,
      child: Opacity(
        opacity: canLock ? 1.0 : 0.5,
        child: FocusableWidget(
          onSelect: canLock
              ? () => settingsCubit.updateImamScheduleLocked(
                  !settings.isImamScheduleLocked,
                )
              : null,
          builder: (isFocused) => Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kunci Jadwal',
                      style: IslamicTypography.body(
                        color: IslamicColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ).copyWith(fontSize: 30.sp, height: 1.2),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      !canLock
                          ? 'Tambah imam terlebih dahulu untuk mengunci'
                          : settings.isImamScheduleLocked
                          ? 'Jadwal terkunci — tidak dapat diubah'
                          : 'Jadwal dapat diubah sewaktu-waktu',
                      style: IslamicTypography.body(
                        color: IslamicColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ).copyWith(fontSize: 24.sp, height: 1.25),
                    ),
                  ],
                ),
                Switch.adaptive(
                  value: settings.isImamScheduleLocked,
                  onChanged: null,
                  activeThumbColor: IslamicColors.goldAmber,
                  activeTrackColor: IslamicColors.goldAmber.withValues(
                    alpha: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────── TASK-031, 032 DPadStepper konfigurasi ────────────

  Widget _buildConfigBlock(Settings settings, SettingsCubit settingsCubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Konfigurasi Tampilan',
          style: IslamicTypography.body(
            color: IslamicColors.textPrimary,
            fontWeight: FontWeight.w700,
          ).copyWith(fontSize: 30.sp, height: 1.2),
        ),
        SizedBox(height: 12.h),
        // TASK-031: Interval tampil (5–60 menit, step 5)
        DPadStepper(
          label: 'Tampil Setiap',
          value: settings.imamScheduleIntervalMinutes,
          minValue: 5,
          maxValue: 60,
          step: 5,
          suffix: 'menit',
          onChanged: settingsCubit.updateImamScheduleIntervalMinutes,
        ),
        SizedBox(height: 12.h),
        // TASK-032: Durasi tampil (10–120 detik, step 5)
        DPadStepper(
          label: 'Lama Tampil',
          value: settings.imamScheduleDurationSeconds,
          minValue: 10,
          maxValue: 120,
          step: 5,
          suffix: 'detik',
          onChanged: settingsCubit.updateImamScheduleDurationSeconds,
        ),
      ],
    );
  }

  // ───────────────────── TASK-033 Jam aktif (4 DPadStepper, WAJIB Column) ─

  Widget _buildJamAktifBlock(Settings settings, SettingsCubit settingsCubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info bar ringkasan jam aktif
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: IslamicColors.glassOverlay,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: IslamicColors.glassBorder),
          ),
          child: Row(
            children: [
              Icon(
                Icons.schedule,
                color: IslamicColors.textSecondary,
                size: 30.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Aktif ${_pad(settings.imamScheduleStartHour)}:${_pad(settings.imamScheduleStartMinute)}'
                ' – ${_pad(settings.imamScheduleEndHour)}:${_pad(settings.imamScheduleEndMinute)}',
                style: IslamicTypography.body(
                  color: IslamicColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ).copyWith(fontSize: 28.sp, height: 1.2),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Jam Aktif Tampil',
          style: IslamicTypography.body(
            color: IslamicColors.textPrimary,
            fontWeight: FontWeight.w700,
          ).copyWith(fontSize: 34.sp, height: 1.2),
        ),
        SizedBox(height: 12.h),

        // CRITICAL: Gunakan Column, bukan Row (DPadStepper mengonsumsi ArrowLeft/Right)
        // Ref: AGENTS.md — DPadStepper Layout Constraint
        DPadStepper(
          label: 'Dari Jam',
          value: settings.imamScheduleStartHour,
          minValue: 0,
          maxValue: 23,
          suffix: '',
          onChanged: settingsCubit.updateImamScheduleStartHour,
        ),
        SizedBox(height: 12.h),
        DPadStepper(
          label: 'Menit Mulai',
          value: settings.imamScheduleStartMinute,
          minValue: 0,
          maxValue: 59,
          step: 5,
          suffix: '',
          onChanged: settingsCubit.updateImamScheduleStartMinute,
        ),
        SizedBox(height: 16.h),
        DPadStepper(
          label: 'Sampai Jam',
          value: settings.imamScheduleEndHour,
          minValue: 0,
          maxValue: 23,
          suffix: '',
          onChanged: settingsCubit.updateImamScheduleEndHour,
        ),
        SizedBox(height: 12.h),
        DPadStepper(
          label: 'Menit Selesai',
          value: settings.imamScheduleEndMinute,
          minValue: 0,
          maxValue: 59,
          step: 5,
          suffix: '',
          onChanged: settingsCubit.updateImamScheduleEndMinute,
        ),
      ],
    );
  }

  // ───────────────────── TASK-034, 035 Area CRUD ──────────────────────────

  Widget _buildCrudContent(
    BuildContext context,
    ImamScheduleLoaded state,
    ImamScheduleCubit cubit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.h),
        // TASK-034: Daftar imam master
        _buildImamListBlock(context, state, cubit),
        SizedBox(height: 16.h),
        Divider(color: IslamicColors.glassBorder, height: 1),
        SizedBox(height: 16.h),
        // TASK-035: Grid jadwal mingguan
        _buildWeeklyScheduleBlock(context, state, cubit),
        SizedBox(height: 24.h),
      ],
    );
  }

  // ─────────── TASK-034: Daftar imam master (CRUD) ────────────────────────

  Widget _buildImamListBlock(
    BuildContext context,
    ImamScheduleLoaded state,
    ImamScheduleCubit cubit,
  ) {
    final imams = state.imams;
    final canAdd = imams.length < 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daftar Imam',
              style: IslamicTypography.body(
                color: IslamicColors.textPrimary,
                fontWeight: FontWeight.w700,
              ).copyWith(fontSize: 30.sp, height: 1.2),
            ),
            Text(
              '${imams.length}/10',
              style: IslamicTypography.body(
                color: imams.length < 10
                    ? IslamicColors.textSecondary
                    : IslamicColors.warning,
                fontWeight: FontWeight.w600,
              ).copyWith(fontSize: 28.sp, height: 1.2),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Tombol Tambah Imam
        ExcludeFocus(
          excluding: !canAdd,
          child: Opacity(
            opacity: canAdd ? 1.0 : 0.4,
            child: FocusableWidget(
              onSelect: canAdd
                  ? () => _showAddImamDialog(context, cubit)
                  : null,
              builder: (isFocused) => Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isFocused
                      ? IslamicColors.goldAmber.withValues(alpha: 0.15)
                      : IslamicColors.glassWhite,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isFocused
                        ? IslamicColors.goldAmber
                        : IslamicColors.glassBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_add,
                      color: isFocused
                          ? IslamicColors.goldAmber
                          : IslamicColors.textSecondary,
                      size: 32.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Tambah Imam',
                      style: IslamicTypography.body(
                        color: isFocused
                            ? IslamicColors.goldAmber
                            : IslamicColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),

        if (imams.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Text(
              'Belum ada imam terdaftar. Tambah imam terlebih dahulu.',
              style: IslamicTypography.body(
                color: IslamicColors.textMuted,
                fontWeight: FontWeight.w600,
              ).copyWith(fontSize: 28.sp, height: 1.3),
            ),
          )
        else
          ...imams.map(
            (imam) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: _ImamListTile(
                imam: imam,
                onEdit: () => _showEditImamDialog(context, cubit, imam),
                onDelete: () => _showDeleteConfirmDialog(context, cubit, imam),
              ),
            ),
          ),
      ],
    );
  }

  // ─────────── TASK-035: Grid jadwal mingguan ──────────────────────────────

  Widget _buildWeeklyScheduleBlock(
    BuildContext context,
    ImamScheduleLoaded state,
    ImamScheduleCubit cubit,
  ) {
    final slots = state.weeklySchedule[_selectedDay] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Jadwal Mingguan',
              style: IslamicTypography.body(
                color: IslamicColors.textSecondary,
                fontWeight: FontWeight.w700,
              ).copyWith(fontSize: 30.sp, height: 1.2),
            ),
            FocusableWidget(
              onSelect: () => _showClearDayConfirmDialog(context, cubit),
              builder: (isFocused) => Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isFocused
                        ? IslamicColors.goldAmber
                        : IslamicColors.glassBorder,
                  ),
                ),
                child: Text(
                  'Kosongkan Hari',
                  textAlign: TextAlign.center,
                  style: IslamicTypography.body(
                    color: isFocused
                        ? IslamicColors.goldAmber
                        : IslamicColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ).copyWith(fontSize: 28.sp, height: 1.2),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Tab 7 hari (horizontal scroll — FocusableWidget biasa, bukan DPadStepper)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(7, (index) {
              final day = index + 1;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: _DayTab(
                  dayName: _dayNames[day]!,
                  isSelected: _selectedDay == day,
                  onSelect: () => setState(() => _selectedDay = day),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 12.h),

        // Slot sholat untuk hari yang dipilih
        if (slots.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Text(
              'Belum ada slot jadwal untuk hari ini.',
              style: IslamicTypography.body(color: IslamicColors.textMuted),
            ),
          )
        else
          ...slots.map((slot) {
            if (slot.prayerName == 'jumat') {
              // Jumat: 2 baris — Khatib dan Imam
              return Column(
                children: [
                  _ScheduleSlotTile(
                    label: "Jumat\n(Khatib)",
                    personName: slot.khatibName ?? 'Khatib belum diisi',
                    isEmpty: slot.khatibName == null,
                    maxLines: 2,
                    onSelect: () => _showImamPickerDialog(
                      context: context,
                      cubit: cubit,
                      imams: state.imams,
                      slot: slot,
                      isKhatib: true,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  _ScheduleSlotTile(
                    label: "Jumat\n(Imam)",
                    personName: slot.imamName ?? 'Imam belum diisi',
                    isEmpty: slot.imamName == null,
                    maxLines: 2,
                    onSelect: () => _showImamPickerDialog(
                      context: context,
                      cubit: cubit,
                      imams: state.imams,
                      slot: slot,
                      isKhatib: false,
                    ),
                  ),
                  SizedBox(height: 6.h),
                ],
              );
            } else {
              return Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: _ScheduleSlotTile(
                  label: slot.prayerLabel,
                  personName: slot.imamName ?? 'Imam belum diisi',
                  isEmpty: slot.imamName == null,
                  onSelect: () => _showImamPickerDialog(
                    context: context,
                    cubit: cubit,
                    imams: state.imams,
                    slot: slot,
                    isKhatib: false,
                  ),
                ),
              );
            }
          }),
      ],
    );
  }

  // ─────────── Error state ─────────────────────────────────────────────────

  Widget _buildError(BuildContext context, String message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: IslamicColors.error, size: 32.sp),
          SizedBox(height: 8.h),
          Text(
            message,
            style: IslamicTypography.body(color: IslamicColors.error),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          FocusableWidget(
            autofocus: true,
            onSelect: () => context.read<ImamScheduleCubit>().loadAll(),
            builder: (isFocused) => Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isFocused
                      ? IslamicColors.goldAmber
                      : IslamicColors.glassBorder,
                ),
              ),
              child: Text(
                'Coba Lagi',
                style: IslamicTypography.body(
                  color: isFocused
                      ? IslamicColors.goldAmber
                      : IslamicColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────── Dialog methods ───────────────────────────────────────────────

  Future<void> _showAddImamDialog(
    BuildContext context,
    ImamScheduleCubit cubit,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _ImamNameDialog(
        title: 'Tambah Imam',
        confirmLabel: 'Tambah',
        onConfirm: (name) => cubit.addImam(name),
      ),
    );
  }

  Future<void> _showEditImamDialog(
    BuildContext context,
    ImamScheduleCubit cubit,
    Imam imam,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _ImamNameDialog(
        title: 'Edit Imam',
        confirmLabel: 'Simpan',
        initialName: imam.name,
        onConfirm: (name) => cubit.updateImam(
          Imam(id: imam.id, name: name, isActive: imam.isActive),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmDialog(
    BuildContext context,
    ImamScheduleCubit cubit,
    Imam imam,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _ConfirmDialog(
        title: 'Hapus Imam',
        message:
            'Hapus "${imam.name}"? Slot jadwal yang menggunakan imam ini akan dikosongkan otomatis.',
        confirmLabel: 'Hapus',
        isDestructive: true,
      ),
    );
    if (confirmed == true) cubit.deleteImam(imam.id);
  }

  Future<void> _showClearDayConfirmDialog(
    BuildContext context,
    ImamScheduleCubit cubit,
  ) async {
    final dayName = _dayNames[_selectedDay]!;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _ConfirmDialog(
        title: 'Kosongkan Jadwal',
        message: 'Kosongkan seluruh jadwal hari $dayName?',
        confirmLabel: 'Kosongkan',
        isDestructive: true,
      ),
    );
    if (confirmed == true) cubit.clearDay(_selectedDay);
  }

  /// Menampilkan dialog picker imam untuk satu slot jadwal.
  ///
  /// [slot] berisi data slot yang akan diubah.
  /// [isKhatib] menentukan apakah yang dipilih adalah khatib (Jumat) atau imam.
  ///
  /// Saat menyimpan, nilai ID yang tidak diubah dipreservasi untuk menghindari
  /// penghapusan data yang tidak disengaja (Khatib tidak terhapus saat memilih Imam).
  Future<void> _showImamPickerDialog({
    required BuildContext context,
    required ImamScheduleCubit cubit,
    required List<Imam> imams,
    required ImamScheduleDisplay slot,
    required bool isKhatib,
  }) async {
    final prayerLabel = isKhatib
        ? 'Khatib ${slot.prayerLabel}'
        : slot.prayerLabel;
    final currentId = isKhatib ? slot.khatibId : slot.imamId;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _ImamPickerDialog(
        prayerLabel: prayerLabel,
        dayName: _dayNames[slot.dayOfWeek]!,
        imams: imams,
        currentImamId: currentId,
        onPick: (selectedId) => cubit.setSchedule(
          dayOfWeek: slot.dayOfWeek,
          prayerName: slot.prayerName,
          // Preserve nilai yang tidak diubah agar data tidak hilang
          imamId: isKhatib ? slot.imamId : selectedId,
          khatibId: isKhatib ? selectedId : slot.khatibId,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Komponen UI lokal
// ─────────────────────────────────────────────────────────────────────────────

/// Tab satu hari pada jadwal mingguan.
class _DayTab extends StatelessWidget {
  final String dayName;
  final bool isSelected;
  final VoidCallback onSelect;

  const _DayTab({
    required this.dayName,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return FocusableWidget(
      onSelect: onSelect,
      builder: (isFocused) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        constraints: BoxConstraints(minWidth: 120.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? IslamicColors.goldAmber.withValues(alpha: 0.25)
              : isFocused
              ? IslamicColors.glassWhite
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? IslamicColors.goldAmber
                : isFocused
                ? IslamicColors.goldAmber.withValues(alpha: 0.5)
                : IslamicColors.glassBorder,
          ),
        ),
        child: Text(
          dayName,
          textAlign: TextAlign.center,
          style: IslamicTypography.caption(
            color: isSelected
                ? IslamicColors.goldAmber
                : IslamicColors.textSecondary,
            fontWeight: FontWeight.w700,
          ).copyWith(fontSize: 26.sp, height: 1.2),
        ),
      ),
    );
  }
}

/// Satu baris slot sholat dalam grid jadwal.
class _ScheduleSlotTile extends StatelessWidget {
  final String label;
  final String personName;
  final bool isEmpty;
  final VoidCallback onSelect;
  final int maxLines;

  const _ScheduleSlotTile({
    required this.label,
    required this.personName,
    required this.isEmpty,
    required this.onSelect,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return FocusableWidget(
      onSelect: onSelect,
      builder: (isFocused) => Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isFocused
              ? IslamicColors.goldAmber.withValues(alpha: 0.1)
              : IslamicColors.glassWhite,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isFocused
                ? IslamicColors.goldAmber
                : IslamicColors.glassBorder,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 150.w,
              child: Text(
                label,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style:
                    IslamicTypography.body(
                      color: IslamicColors.textSecondary,
                    ).copyWith(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                personName,
                style:
                    IslamicTypography.body(
                      color: isEmpty
                          ? IslamicColors.textMuted
                          : IslamicColors.textPrimary,
                    ).copyWith(
                      fontSize: 30.sp,
                      fontWeight: isEmpty ? FontWeight.w500 : FontWeight.w600,
                      height: 1.2,
                      fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                    ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isFocused
                  ? IslamicColors.goldAmber
                  : IslamicColors.textMuted,
              size: 38.sp,
            ),
          ],
        ),
      ),
    );
  }
}

/// Satu baris imam dalam daftar master (dengan tombol edit & hapus).
class _ImamListTile extends StatelessWidget {
  final Imam imam;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ImamListTile({
    required this.imam,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: IslamicColors.glassWhite,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: IslamicColors.glassBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.person, color: IslamicColors.textMuted, size: 30.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              imam.name,
              style: IslamicTypography.body(color: IslamicColors.textPrimary),
            ),
          ),
          // Tombol Edit
          FocusableWidget(
            onSelect: onEdit,
            builder: (isFocused) => Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.r),
                color: isFocused
                    ? IslamicColors.goldAmber.withValues(alpha: 0.15)
                    : Colors.transparent,
                border: Border.all(
                  color: isFocused
                      ? IslamicColors.goldAmber
                      : Colors.transparent,
                ),
              ),
              child: Icon(
                Icons.edit,
                color: isFocused
                    ? IslamicColors.goldAmber
                    : IslamicColors.textSecondary,
                size: 30.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Tombol Hapus
          FocusableWidget(
            onSelect: onDelete,
            builder: (isFocused) => Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.r),
                color: isFocused
                    ? IslamicColors.error.withValues(alpha: 0.15)
                    : Colors.transparent,
                border: Border.all(
                  color: isFocused ? IslamicColors.error : Colors.transparent,
                ),
              ),
              child: Icon(
                Icons.delete_outline,
                color: isFocused
                    ? IslamicColors.error
                    : IslamicColors.textSecondary,
                size: 30.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Dialog input nama imam (tambah atau edit).
///
/// Menggunakan [StatefulWidget] agar [TextEditingController] dan [FocusNode]
/// bisa di-dispose dengan benar.
///
/// Menerapkan pola D-Pad TextField dari AGENTS.md:
/// `FocusNode(skipTraversal: true)` + `addPostFrameCallback` untuk membuka IME.
class _ImamNameDialog extends StatefulWidget {
  final String title;
  final String confirmLabel;
  final String? initialName;
  final ValueChanged<String> onConfirm;

  const _ImamNameDialog({
    required this.title,
    required this.confirmLabel,
    required this.onConfirm,
    this.initialName,
  });

  @override
  State<_ImamNameDialog> createState() => _ImamNameDialogState();
}

class _ImamNameDialogState extends State<_ImamNameDialog> {
  late final TextEditingController _controller;
  late final FocusNode _fieldFocusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
    // skipTraversal: true — D-pad tidak auto-landing di sini,
    // tapi requestFocus() programatik tetap berfungsi.
    _fieldFocusNode = FocusNode(skipTraversal: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _fieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: IslamicColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: IslamicColors.glassBorder),
      ),
      child: Padding(
        padding: EdgeInsets.all(28.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: IslamicTypography.heading()),
            SizedBox(height: 20.h),

            // TextField (AGENTS.md: D-Pad TextField pattern)
            FocusableWidget(
              autofocus: true,
              onSelect: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _fieldFocusNode.requestFocus();
                });
              },
              builder: (isFocused) => Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: IslamicColors.glassWhite,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isFocused
                        ? IslamicColors.goldAmber
                        : IslamicColors.glassBorder,
                    width: isFocused ? 2.0 : 1.0,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _fieldFocusNode,
                  maxLength: 60,
                  style:
                      IslamicTypography.body(
                        color: IslamicColors.textPrimary,
                      ).copyWith(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                  decoration: InputDecoration(
                    hintText: 'Nama imam / ustadz',
                    hintStyle:
                        IslamicTypography.body(
                          color: IslamicColors.textMuted,
                        ).copyWith(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                    counterText: '',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _fieldFocusNode.unfocus(),
                ),
              ),
            ),
            SizedBox(height: 4.h),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (_, value, _) => Text(
                '${value.text.length}/60',
                style: IslamicTypography.caption(
                  color: Colors.white,
                ).copyWith(fontSize: 26.sp),
                textAlign: TextAlign.right,
              ),
            ),
            SizedBox(height: 16.h),

            // Tombol aksi — pakai Dialog biasa (bukan AlertDialog) per AGENTS.md
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _DialogButton(
                  label: 'Batal',
                  fontSize: 28.sp,
                  minHeight: 56.h,
                  fontWeight: FontWeight.bold,
                  onSelect: () => Navigator.of(context).pop(),
                ),
                SizedBox(width: 12.w),
                _DialogButton(
                  label: widget.confirmLabel,
                  isPrimary: true,
                  fontSize: 28.sp,
                  minHeight: 56.h,
                  fontWeight: FontWeight.bold,
                  onSelect: () {
                    final name = _controller.text.trim();
                    if (name.isNotEmpty) {
                      widget.onConfirm(name);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog pemilih imam untuk satu slot jadwal.
///
/// Menampilkan daftar imam + opsi "Kosongkan" di posisi teratas.
class _ImamPickerDialog extends StatelessWidget {
  final String prayerLabel;
  final String dayName;
  final List<Imam> imams;
  final int? currentImamId;
  final ValueChanged<int?> onPick;

  const _ImamPickerDialog({
    required this.prayerLabel,
    required this.dayName,
    required this.imams,
    required this.currentImamId,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: IslamicColors.surfaceDark,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 32.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: IslamicColors.glassBorder),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 640.h, maxWidth: 800.w),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pilih $prayerLabel', style: IslamicTypography.heading()),
              SizedBox(height: 4.h),
              Text(
                dayName,
                style: IslamicTypography.caption(
                  color: IslamicColors.textSecondary,
                ).copyWith(fontSize: 32.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16.h),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    // Opsi kosongkan slot
                    _ImamPickerItem(
                      name: '— Kosongkan —',
                      isSelected: currentImamId == null,
                      isDestructive: true,
                      autofocus: currentImamId == null,
                      onSelect: () {
                        onPick(null);
                        Navigator.of(context).pop();
                      },
                    ),
                    ...imams.map(
                      (imam) => _ImamPickerItem(
                        name: imam.name,
                        isSelected: currentImamId == imam.id,
                        autofocus: currentImamId == imam.id,
                        onSelect: () {
                          onPick(imam.id);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Align(
                alignment: Alignment.centerRight,
                child: _DialogButton(
                  label: 'Batal',
                  onSelect: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Satu item di dalam [_ImamPickerDialog].
class _ImamPickerItem extends StatelessWidget {
  final String name;
  final bool isSelected;
  final bool isDestructive;
  final bool autofocus;
  final VoidCallback onSelect;

  const _ImamPickerItem({
    required this.name,
    required this.onSelect,
    this.isSelected = false,
    this.isDestructive = false,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: FocusableWidget(
        autofocus: autofocus,
        onSelect: onSelect,
        builder: (isFocused) => Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected
                ? IslamicColors.goldAmber.withValues(alpha: 0.15)
                : isFocused
                ? IslamicColors.glassWhite
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isSelected
                  ? IslamicColors.goldAmber
                  : isFocused
                  ? IslamicColors.goldAmber.withValues(alpha: 0.5)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: IslamicTypography.body(
                    color: isDestructive
                        ? IslamicColors.error
                        : isSelected
                        ? IslamicColors.goldAmber
                        : IslamicColors.textPrimary,
                  ).copyWith(fontSize: 30.sp, fontWeight: FontWeight.w500),
                ),
              ),
              if (isSelected)
                Icon(Icons.check, color: IslamicColors.goldAmber, size: 28.sp),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog konfirmasi untuk aksi destruktif (hapus imam, kosongkan jadwal).
///
/// Menggunakan [Dialog] biasa (bukan [AlertDialog]) per AGENTS.md — menghindari
/// masalah layout FocusableWidget pada `AlertDialog.actions` yang menggunakan
/// `OverflowBar`.
class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final bool isDestructive;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: IslamicColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: IslamicColors.glassBorder),
      ),
      child: Padding(
        padding: EdgeInsets.all(28.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: IslamicTypography.heading()),
            SizedBox(height: 12.h),
            Text(
              message,
              style: IslamicTypography.body(color: IslamicColors.textSecondary),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _DialogButton(
                  label: 'Batal',
                  autofocus: true,
                  onSelect: () => Navigator.of(context).pop(false),
                ),
                SizedBox(width: 12.w),
                _DialogButton(
                  label: confirmLabel,
                  isPrimary: true,
                  isDestructive: isDestructive,
                  onSelect: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Tombol aksi di dalam dialog.
class _DialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onSelect;
  final bool isPrimary;
  final bool isDestructive;
  final bool autofocus;
  final double? fontSize;
  final double? minHeight;
  final FontWeight? fontWeight;

  const _DialogButton({
    required this.label,
    required this.onSelect,
    this.isPrimary = false,
    this.isDestructive = false,
    this.autofocus = false,
    this.fontSize,
    this.minHeight,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return FocusableWidget(
      autofocus: autofocus,
      onSelect: onSelect,
      builder: (isFocused) {
        final activeColor = isDestructive
            ? IslamicColors.error
            : IslamicColors.goldAmber;
        return Container(
          constraints: minHeight != null
              ? BoxConstraints(minHeight: minHeight!)
              : null,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isPrimary
                ? isFocused
                      ? activeColor
                      : activeColor.withValues(alpha: 0.75)
                : isFocused
                ? IslamicColors.glassWhite
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isFocused ? activeColor : IslamicColors.glassBorder,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style:
                IslamicTypography.body(
                  color: isPrimary
                      ? IslamicColors.darkBackground
                      : IslamicColors.textPrimary,
                ).copyWith(
                  fontSize: fontSize,
                  fontWeight: fontWeight ?? FontWeight.w600,
                  height: 1.2,
                ),
          ),
        );
      },
    );
  }
}
