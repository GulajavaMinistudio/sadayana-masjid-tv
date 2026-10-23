import 'package:flutter/services.dart';

/// Immutable holder for the application's build identity.
///
/// The values are compile-time constants injected by the Flutter tool from
/// `pubspec.yaml`'s `version:` field (via the `FLUTTER_BUILD_NAME` and
/// `FLUTTER_BUILD_NUMBER` dart-defines). They therefore always describe the
/// code that is actually running.
///
/// Dependency direction: Flutter SDK only — no import of `data`, `domain`,
/// or `presentation` (Spec CON-006 / §4.2).
final class AppVersion {
  const AppVersion._();

  /// The build name — the part of `version:` before the `+` separator.
  /// `null` when the manifest declares no version.
  static const String? buildName = appBuildName;

  /// The build number — the part of `version:` after the `+` separator.
  /// `null` when the manifest declares no build number.
  static const String? buildNumber = appBuildNumber;

  /// Placeholder rendered when the manifest declares no version.
  ///
  /// Deliberately non-numeric so an absent version is visibly absent
  /// rather than silently wrong (Invariant I2).
  static const String unavailable = 'tidak tersedia';

  /// The version to display, or [unavailable] when the manifest has none.
  static const String displayName = buildName ?? unavailable;

  /// The build number to display, or [unavailable] when the manifest has
  /// none.
  static const String displayBuildNumber = buildNumber ?? unavailable;
}
