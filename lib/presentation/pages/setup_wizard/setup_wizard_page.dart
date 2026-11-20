import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/tv_safe_area.dart';
import '../../cubits/setup_wizard/setup_wizard.dart';
import '../../widgets/islamic_background.dart';
import '../splash_page.dart';

import '../../widgets/step_indicator_widget.dart';

// Placeholder steps for Phase 1
import 'steps/welcome_step.dart';
import 'steps/identity_step.dart';
import 'steps/location_step.dart';
import 'steps/preview_step.dart';

class SetupWizardPage extends StatelessWidget {
  const SetupWizardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SetupWizardCubit(
        // Inject repository from global provider/locator
        // Assuming SettingsRepository is available via context or locator service locator
        // For now using context.read if SettingsRepository is in main or get_it
        // This line depends on where SettingsRepository is provided.
        // If not provided in main yet (Phase 7), we might need to adjust.
        // Assuming context.read<SettingsRepository>() works if provided up tree.
        context.read(),
      ),
      child: const SetupWizardView(),
    );
  }
}

class SetupWizardView extends StatelessWidget {
  const SetupWizardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SetupWizardCubit, SetupWizardState>(
      listener: (context, state) {
        if (state is SetupWizardCompleted) {
          // Navigate back to SplashPage to let it route to the correct Main Display
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SplashPage()),
            (route) => false,
          );
        } else if (state is SetupWizardError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        int currentStep = 0;
        int totalSteps = 4;

        if (state is SetupWizardInProgress) {
          currentStep = state.currentStep;
          totalSteps = state.totalSteps;
        }

        return Scaffold(
          // Jangan biarkan Scaffold menyusutkan body saat keyboard muncul.
          // Penanganan keyboard dilakukan secara manual via viewInsetsOf padding
          // pada SingleChildScrollView di setiap step yang memiliki TextField.
          resizeToAvoidBottomInset: false,
          body: IslamicBackground(
            child: TVSafeArea(
              child: Column(
                children: [
                  // Top Area: Step Indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: StepIndicatorWidget(
                      currentStep: currentStep,
                      totalSteps: totalSteps,
                    ),
                  ),

                  // Content Area: Steps
                  Expanded(child: _buildStepContent(currentStep)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return const WelcomeStep();
      case 1:
        return const IdentityStep();
      case 2:
        return const LocationStep();
      case 3:
        return const PreviewStep();
      default:
        return const SizedBox.shrink();
    }
  }
}
