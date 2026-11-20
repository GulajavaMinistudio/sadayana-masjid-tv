import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/islamic_colors.dart';
import '../../../../core/theme/islamic_typography.dart';
import '../../../cubits/settings/settings_cubit.dart';
import '../../../cubits/settings/settings_state.dart';
import '../../../widgets/running_text_widget.dart';
import '../../../widgets/focusable_widget.dart';
import '../../../widgets/focusable_text_field.dart';

class RunningTextSection extends StatefulWidget {
  const RunningTextSection({super.key});

  @override
  State<RunningTextSection> createState() => _RunningTextSectionState();
}

class _RunningTextSectionState extends State<RunningTextSection> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) {
        if (previous is! SettingsLoaded && current is SettingsLoaded) {
          return true;
        }
        return false;
      },
      listener: (context, state) {
        if (state is SettingsLoaded) {
          if (_controller.text.isEmpty) {
            _controller.text = state.settings.runningText;
          }
        }
      },
      builder: (context, state) {
        if (state is! SettingsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final settings = state.settings;
        final cubit = context.read<SettingsCubit>();

        if (_controller.text.isEmpty && settings.runningText.isNotEmpty) {
          _controller.text = settings.runningText;
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Running Text', style: IslamicTypography.heading()),
              SizedBox(height: 8.h),
              Text(
                'Teks berjalan yang akan ditampilkan di bagian bawah layar masjid. Anda dapat menggunakan keyboard virtual atau fisik.',
                style: IslamicTypography.subtitle(
                  color: IslamicColors.textSecondary,
                ),
              ),
              SizedBox(height: 32.h),

              // Preview Area
              Text('Preview:', style: IslamicTypography.title()),
              SizedBox(height: 16.h),
              Container(
                height: 60.h,
                decoration: BoxDecoration(
                  color: IslamicColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: IslamicColors.glassBorder,
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: RunningTextWidget(
                    text: _controller.text.isEmpty
                        ? settings.runningText
                        : _controller.text,
                    showBackground: false,
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Input TextField
              FocusableTextField(
                controller: _controller,
                hintText: 'Masukkan teks berjalan...',
                maxLines: 4,
                minLines: 1,
                onChanged: (val) {
                  setState(() {});
                },
                onSubmitted: (val) {
                  cubit.updateRunningText(val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Running Text tersimpan: $val'),
                      backgroundColor: IslamicColors.success,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),

              SizedBox(height: 24.h),

              Align(
                alignment: Alignment.centerRight,
                child: FocusableWidget(
                  onSelect: () {
                    cubit.updateRunningText(_controller.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Running Text berhasil disimpan.',
                          style: IslamicTypography.body(
                            color: IslamicColors.surfaceDark,
                          ),
                        ),
                        backgroundColor: IslamicColors.success,
                      ),
                    );
                  },
                  builder: (isFocused) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: IslamicColors.primaryTeal,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isFocused
                              ? IslamicColors.goldAmber
                              : IslamicColors.primaryTeal,
                          width: isFocused ? 2.0 : 1.0,
                        ),
                      ),
                      child: Text(
                        'Simpan',
                        style: IslamicTypography.title(
                          color: IslamicColors.textPrimary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
