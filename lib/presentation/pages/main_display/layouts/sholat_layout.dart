import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/islamic_typography.dart';
import '../../../../domain/entities/display_state.dart';
import '../../../widgets/digital_clock_widget.dart';

/// Layout khusus saat Sholat (Layar diredupkan sepenuhnya untuk burn-in prevention)
class SholatLayout extends StatelessWidget {
  final SholatState state;

  const SholatLayout({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // OverflowBox agar container hitam menutupi seluruh layar,
    // melewati batas TVSafeArea padding di parent.
    return OverflowBox(
      maxWidth: screenSize.width,
      maxHeight: screenSize.height,
      child: Container(
        color: Colors.black,
        width: screenSize.width,
        height: screenSize.height,
        child: Center(
          child: Opacity(
            opacity: 0.85,
            // TASK-010: currentTime dihapus — widget mengelola timer sendiri.
            child: DigitalClockWidget(
              customStyle: IslamicTypography.heading(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
