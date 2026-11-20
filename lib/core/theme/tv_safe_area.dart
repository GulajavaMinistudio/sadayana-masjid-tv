import 'package:material_ui/material_ui.dart';

/// TV Safe Area wrapper widget.
///
/// Memberikan 5% margin dari seluruh edge layar sesuai standar
/// Android TV 10-foot UI (REQ-005). Margin dihitung dinamis
/// via [MediaQuery] sehingga bekerja di semua resolusi TV.
///
/// Ref: Plan 03 TASK-027 s.d. TASK-029
///
/// Contoh penggunaan:
/// ```dart
/// TVSafeArea(
///   child: MyContent(),
/// )
/// ```
///
/// Untuk bypass safe area (misal fullscreen background):
/// ```dart
/// TVSafeArea(
///   ignoreSafeArea: true,
///   child: BackgroundWidget(),
/// )
/// ```
class TVSafeArea extends StatelessWidget {
  const TVSafeArea({
    super.key,
    required this.child,
    this.ignoreSafeArea = false,
  });

  /// Widget yang akan dibungkus dengan TV safe area padding.
  final Widget child;

  /// Jika `true`, tidak ada padding yang diterapkan.
  /// Berguna untuk fullscreen background atau overlay widgets.
  final bool ignoreSafeArea;

  /// Persentase safe area dari edge layar (5% = 0.05).
  static const double _safeAreaPercent = 0.05;

  @override
  Widget build(BuildContext context) {
    if (ignoreSafeArea) return child;

    final size = MediaQuery.sizeOf(context);
    final horizontalPadding = size.width * _safeAreaPercent;
    final verticalPadding = size.height * _safeAreaPercent;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: child,
    );
  }
}
