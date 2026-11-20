import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/islamic_colors.dart';
import '../../../../core/theme/islamic_typography.dart';
import '../../../cubits/settings/settings_cubit.dart';
import '../../../cubits/settings/settings_state.dart';
import '../../../widgets/focusable_widget.dart';

/// Section untuk mengedit identitas masjid: nama dan alamat.
///
/// Perubahan disimpan otomatis ke database via [SettingsCubit].
class IdentitySection extends StatefulWidget {
  const IdentitySection({super.key});

  @override
  State<IdentitySection> createState() => _IdentitySectionState();
}

class _IdentitySectionState extends State<IdentitySection> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;

  // skipTraversal: true → tidak masuk D-pad traversal, tapi masih bisa
  // difokuskan secara programatik via requestFocus() untuk membuka keyboard.
  final FocusNode _nameFocusNode = FocusNode(skipTraversal: true);
  final FocusNode _addressFocusNode = FocusNode(skipTraversal: true);

  bool _initialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _nameFocusNode.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  /// Inisialisasi controller dari settings yang sudah loaded.
  void _initControllers(SettingsLoaded state) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = state.settings.mosqueName;
    _addressController.text = state.settings.mosqueAddress;
  }

  Future<void> _save(BuildContext context) async {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();

    if (name.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama masjid minimal 3 karakter'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await context.read<SettingsCubit>().updateIdentity(
        mosqueName: name,
        mosqueAddress: address,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Identitas masjid berhasil disimpan'),
            backgroundColor: IslamicColors.success,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        if (state is SettingsLoaded) {
          _initControllers(state);
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Identitas Masjid',
                style: IslamicTypography.title(
                  color: IslamicColors.goldAmber,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Nama dan alamat akan ditampilkan di pojok kiri atas layar.',
                style: IslamicTypography.body(
                  color: IslamicColors.textSecondary,
                ),
              ),
              SizedBox(height: 32.h),

              // Nama Masjid
              _buildInputGroup(
                label: 'Nama Masjid *',
                controller: _nameController,
                focusNode: _nameFocusNode,
                hint: 'contoh: Masjid Al-Ikhlas',
                maxLines: 1,
              ),
              SizedBox(height: 24.h),

              // Alamat Masjid
              _buildInputGroup(
                label: 'Alamat Masjid',
                controller: _addressController,
                focusNode: _addressFocusNode,
                hint: 'contoh: Jl. Raya No. 1, Bandung',
                maxLines: 2,
                textInputAction: TextInputAction.done,
              ),
              SizedBox(height: 40.h),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : () => _save(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: IslamicColors.goldAmber,
                    foregroundColor: IslamicColors.deepTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Simpan Identitas',
                          style: IslamicTypography.body(
                            color: IslamicColors.deepTeal,
                            fontWeight: FontWeight.bold,
                          ).copyWith(fontSize: 32.sp),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Membangun satu input group dengan pola Android TV:
  /// - [FocusableWidget] sebagai target D-pad (kuning saat focused)
  /// - Tekan OK/Select → [focusNode.requestFocus()] membuka keyboard
  /// - [TextField] dibungkus [ExcludeFocus] agar tidak terjangkau traversal D-pad
  Widget _buildInputGroup({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    int maxLines = 1,
    TextInputAction? textInputAction,
  }) {
    return FocusableWidget(
      onSelect: () {
        // Defer ke frame berikutnya agar key-event selesai diproses terlebih
        // dahulu sebelum IME connection dibuka — ini diperlukan agar keyboard
        // muncul di Android TV saat tombol OK/Select ditekan.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          focusNode.requestFocus();
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
              // FocusNode(skipTraversal: true) sudah cukup mencegah D-pad
              // traversal otomatis mendarat di sini — ExcludeFocus TIDAK
              // dipakai karena akan memblokir requestFocus() programatik juga.
              TextField(
                focusNode: focusNode,
                controller: controller,
                maxLines: maxLines,
                textInputAction: textInputAction,
                onSubmitted: textInputAction == TextInputAction.done
                    ? (_) => focusNode.unfocus()
                    : null,
                style: IslamicTypography.body(color: IslamicColors.textPrimary),
                decoration: InputDecoration(
                  hintText: hint,
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
              ),
            ],
          ),
        );
      },
    );
  }
}
