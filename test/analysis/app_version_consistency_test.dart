// Manifest-parity oracle and anti-regression guard for the single-source-
// of-truth version display seam.
//
// Spec: docs/spec/about-page-version-drift-spec.md (REQ-002, REQ-005)
// Plan: docs/plan/about-page-version-drift-plan.md (TASK-002)
//
// Three verification seams live here:
//   1. Manifest-parity oracle (AC-002) — AppVersion must equal the `version:`
//      field parsed from pubspec.yaml on disk. Parsing the manifest (rather
//      than comparing two app-internal constants) keeps the oracle external,
//      so it still detects a Flutter toolchain that stops injecting the
//      FLUTTER_BUILD_NAME / FLUTTER_BUILD_NUMBER dart-defines.
//   2. Parser edge cases (AC-014) — a manifest without a `+` segment yields
//      a `null` build number without throwing; the value is always split on
//      the FIRST `+` only.
//   3. Exhaustive two-value proof (AC-003) — the absent-manifest branch
//      cannot be instantiated (`bool.hasEnvironment` is constant-folded), so
//      it is proven by exhaustion: each display member can only ever hold
//      the raw manifest value or the non-numeric `unavailable` placeholder.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:miqotul_khoir_tv/core/app_version.dart';

/// Result of parsing the manifest's `version:` field.
///
/// [buildNumber] is `null` when the manifest declares a name-only version
/// (no `+` segment) — the mixed state is representable and reachable
/// (Spec AC-014).
class ParsedManifestVersion {
  const ParsedManifestVersion(this.name, this.buildNumber);

  final String? name;
  final String? buildNumber;
}

/// Parses one manifest `version:` declaration line, splitting on the FIRST
/// `+` only (Spec §7 Dimension Checks). `+` separates the build name from
/// the build number — it is NOT a semver pre-release marker.
ParsedManifestVersion parseManifestVersionLine(String line) {
  final colonIndex = line.indexOf(':');
  if (colonIndex < 0) {
    return const ParsedManifestVersion(null, null);
  }
  final value = line.substring(colonIndex + 1).trim();
  if (value.isEmpty) {
    return const ParsedManifestVersion(null, null);
  }
  final plusIndex = value.indexOf('+');
  if (plusIndex < 0) {
    return ParsedManifestVersion(value, null);
  }
  return ParsedManifestVersion(
    value.substring(0, plusIndex),
    value.substring(plusIndex + 1),
  );
}

/// Reads every line of `pubspec.yaml` resolved from the working directory.
///
/// Throws — never silently skips — when the manifest is missing or
/// unreadable (Spec §7 CAUTION, CON-007): a skipped guard test is worse
/// than no guard test.
List<String> readManifestLines() {
  final file = File('pubspec.yaml');
  if (!file.existsSync()) {
    throw StateError(
      'pubspec.yaml not found from CWD "${Directory.current.path}" — the '
      'manifest-parity oracle cannot execute and MUST fail loudly',
    );
  }
  try {
    return file.readAsLinesSync();
  } on FileSystemException catch (error) {
    throw StateError(
      'pubspec.yaml exists but is unreadable: ${error.message} — the '
      'manifest-parity oracle cannot execute and MUST fail loudly',
    );
  }
}

/// Returns the first non-comment `version:` declaration line, or `null` when
/// the manifest declares no version at all (AC-003's absent-manifest case).
String? findVersionLine(List<String> lines) {
  for (final line in lines) {
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('version:')) {
      return trimmed;
    }
  }
  return null;
}

/// Lexical state used by the Dart comment stripper.
enum _LexerState { code, singleQuoted, doubleQuoted }

/// Strips `//`-style (including `///` doc) and `/* */` block comments from
/// Dart source while leaving string literals intact — so a `https://` URL
/// inside a string can never truncate the continuation of a marker-bearing
/// line (Plan TASK-008 step 2; `splash_page.dart`'s lower-case "versi lama"
/// comment must be neutralised before marker matching).
String stripDartComments(String source) {
  final buffer = StringBuffer();
  var state = _LexerState.code;
  var isRawString = false;
  var blockCommentDepth = 0;
  var index = 0;
  while (index < source.length) {
    final char = source[index];
    final next = index + 1 < source.length ? source[index + 1] : '';
    if (state == _LexerState.code) {
      if (blockCommentDepth == 0 && char == '/' && next == '/') {
        while (index < source.length && source[index] != '\n') {
          index += 1;
        }
        continue;
      }
      if (char == '/' && next == '*') {
        blockCommentDepth += 1;
        index += 2;
        continue;
      }
      if (blockCommentDepth > 0) {
        if (char == '*' && next == '/') {
          blockCommentDepth -= 1;
          index += 2;
          continue;
        }
        // Preserve line structure inside block comments so the stripped
        // output stays line-aligned with the original for diagnostics.
        if (char == '\n') {
          buffer.write(char);
        }
        index += 1;
        continue;
      }
      if (char == "'") {
        isRawString = false;
        state = _LexerState.singleQuoted;
      } else if (char == '"') {
        isRawString = false;
        state = _LexerState.doubleQuoted;
      } else if (char == 'r' && (next == "'" || next == '"')) {
        isRawString = true;
        state = next == "'"
            ? _LexerState.singleQuoted
            : _LexerState.doubleQuoted;
        // Consume BOTH the raw prefix and the opening quote here — leaving
        // the quote for the next iteration would close the string early and
        // let comment stripping resume mid-string.
        buffer.write(char);
        buffer.write(next);
        index += 2;
        continue;
      }
    } else {
      if (!isRawString && char == r'\') {
        // Only a non-raw string honours backslash escapes; both halves are
        // written verbatim so nothing is silently consumed.
        buffer.write(char);
        if (index + 1 < source.length) {
          buffer.write(source[index + 1]);
        }
        index += 2;
        continue;
      }
      if ((state == _LexerState.singleQuoted && char == "'") ||
          (state == _LexerState.doubleQuoted && char == '"')) {
        state = _LexerState.code;
      }
    }
    buffer.write(char);
    index += 1;
  }
  return buffer.toString();
}

/// Plan TASK-008 step 3: the capitalised rendered markers, kept as TWO
/// separate patterns (a single `a | b` alternation would hide which marker
/// fired in failure messages — see the Knowledge Base note on pipe
/// semantics).
final RegExp _versionMarker = RegExp(r'Versi ');
final RegExp _buildMarker = RegExp(r'Build ');

/// Plan TASK-008 step 5: the shipped defect shape is a DECLARATION MEMBER
/// (both halves: `version = '1.2.2'` AND `buildNumber = '5'`). Structure,
/// never a literal-shape regex.
final RegExp _displayMember = RegExp(
  r'static\s+const\s+String\s+(?:version|buildNumber)\b',
);

final RegExp _importDirective = RegExp(
  "^import\\s+['\"]([^'\"]*)['\"]",
  multiLine: true,
);

/// Recursively enumerates every Dart file under [root]. Throws loudly when
/// the root or any nested listing cannot be read (CON-007 — never skip).
List<File> enumerateDartFiles(Directory root) {
  if (!root.existsSync()) {
    throw StateError(
      '${root.path} does not exist — the structural scan cannot execute '
      'and MUST fail loudly',
    );
  }
  final files = <File>[];
  final pending = <Directory>[root];
  while (pending.isNotEmpty) {
    final directory = pending.removeLast();
    for (final entity in directory.listSync(followLinks: false)) {
      if (entity is Directory) {
        pending.add(entity);
      } else if (entity is File && entity.path.endsWith('.dart')) {
        files.add(entity);
      }
    }
  }
  return files;
}

/// Reads a source file, converting any unreadable state into a loud
/// [StateError] instead of a silent skip (Plan TASK-008, CON-007).
String readDartSource(File file) {
  try {
    return file.readAsStringSync();
  } on FileSystemException catch (error) {
    throw StateError(
      '${file.path} is unreadable: ${error.message} — the structural scan '
      'cannot execute and MUST fail loudly',
    );
  }
}

/// Returns every import path declared in [dartCode].
List<String> dartImportPaths(String dartCode) => _importDirective
    .allMatches(dartCode)
    .map((match) => match.group(1)!)
    .toList();

void main() {
  group('Manifest-parity oracle (AC-002, REQ-002)', () {
    test('AppVersion equals the pubspec.yaml version field', () {
      final lines = readManifestLines();
      final line = findVersionLine(lines);
      expect(
        line,
        isNotNull,
        reason:
            'pubspec.yaml declares no version: field — the manifest-parity '
            'invariant is undefined and MUST fail loudly rather than skip',
      );
      final parsed = parseManifestVersionLine(line!);
      expect(
        parsed.name,
        isNotNull,
        reason: 'A declaration line without a value cannot be verified',
      );
      expect(
        AppVersion.displayName,
        parsed.name,
        reason: 'REQ-002: the rendered version must equal the manifest name',
      );
      if (parsed.buildNumber == null) {
        // Name-only manifest: both sides must degrade to null/placeholder
        // together — never assert a comparison that cannot even be formed.
        expect(AppVersion.buildNumber, isNull);
        expect(AppVersion.displayBuildNumber, AppVersion.unavailable);
      } else {
        expect(
          AppVersion.buildNumber,
          parsed.buildNumber,
          reason: 'the raw build number must equal the manifest value',
        );
        expect(
          AppVersion.displayBuildNumber,
          parsed.buildNumber,
          reason:
              'REQ-002: the rendered build number must equal the manifest '
              'value',
        );
      }
    });

    test('manifest file is locatable from the test working directory', () {
      // Plan B-2 trigger probe: File('pubspec.yaml') depends on the runner's
      // CWD. Resolve the current-directory chain upward should the default
      // ever break — bounded, and it still fails loudly at the end.
      var directory = Directory.current;
      var found = File(
        '${directory.path}${Platform.pathSeparator}pubspec.yaml',
      ).existsSync();
      var depth = 0;
      while (!found && depth < 3) {
        directory = directory.parent;
        found = File(
          '${directory.path}${Platform.pathSeparator}pubspec.yaml',
        ).existsSync();
        depth += 1;
      }
      expect(
        found,
        isTrue,
        reason:
            'pubspec.yaml was not reachable within 3 levels of the runner CWD '
            '"${Directory.current.path}" — Plan B-2 (bounded upward walk) '
            'applies',
      );
    });
  });

  group('Manifest parser edge cases (AC-014, REQ-005)', () {
    test('name-only value splits without a build number, no throw', () {
      final parsed = parseManifestVersionLine('version: 1.4.4');
      expect(parsed.name, '1.4.4');
      expect(parsed.buildNumber, isNull);
    });

    test('name+build value splits on the first + only', () {
      final parsed = parseManifestVersionLine('version: 1.4.4+15');
      expect(parsed.name, '1.4.4');
      expect(parsed.buildNumber, '15');
    });

    test('inner + characters stay with the build number segment', () {
      final parsed = parseManifestVersionLine('version: 1.4.4+1+2');
      expect(parsed.name, '1.4.4');
      expect(parsed.buildNumber, '1+2');
    });

    test('whitespace around the value is tolerated', () {
      final parsed = parseManifestVersionLine('version:   1.4.4+15  ');
      expect(parsed.name, '1.4.4');
      expect(parsed.buildNumber, '15');
    });

    test('an empty value yields nulls without throwing', () {
      final parsed = parseManifestVersionLine('version:');
      expect(parsed.name, isNull);
      expect(parsed.buildNumber, isNull);
    });

    test('a missing version key is reported, not skipped', () {
      expect(
        findVersionLine(['name: demo', 'environment:']),
        isNull,
        reason: 'the caller must fail loudly when no version key exists',
      );
    });
  });

  group('Exhaustive two-value proof (AC-003, AC-014, RISK-002)', () {
    test('displayName is either the build name or unavailable placeholder', () {
      // The absent-manifest branch cannot be instantiated, so the invariant
      // is proven over the only two values each display member can take.
      // A re-introduced hardcoded fallback (e.g. '1.2.2') fails immediately.
      expect(
        AppVersion.displayName,
        anyOf(equals(AppVersion.buildName), equals(AppVersion.unavailable)),
      );
      expect(
        AppVersion.displayBuildNumber,
        anyOf(equals(AppVersion.buildNumber), equals(AppVersion.unavailable)),
      );
    });

    test('unavailable placeholder is non-empty and non-numeric', () {
      // Invariant I2: the fallback must be recognisably NOT a version, so
      // an absent manifest is diagnosable rather than silently wrong.
      expect(AppVersion.unavailable, isNotEmpty);
      expect(AppVersion.unavailable, isNot(matches(RegExp(r'^\d+(\.\d+)*$'))));
    });

    test('build name is null or non-empty (empty-string define defence)', () {
      // RISK-002: `--dart-define=FLUTTER_BUILD_NAME=` yields '' and would
      // otherwise defeat the `?? unavailable` fallback.
      expect(AppVersion.buildName, anyOf(isNull, isNotEmpty));
      expect(AppVersion.buildNumber, anyOf(isNull, isNotEmpty));
    });
  });

  group('Structural anti-regression scan (AC-011, CON-006 — Plan TASK-008)', () {
    test('comment stripper removes comments but keeps string literals', () {
      final source =
          "const cat = 'https://example.com/a//b'; // note: lowercase versi\n"
          "/* block: Versi fake */\n"
          "const marker = 'Build 15';\n"
          "const versionLine = 'Versi 1.0';";
      final stripped = stripDartComments(source);
      expect(
        stripped,
        isNot(contains('note: lowercase')),
        reason: 'line comments must be removed',
      );
      expect(
        stripped,
        isNot(contains('block: Versi')),
        reason: 'block comments must be removed',
      );
      expect(
        stripped,
        contains('https://example.com/a//b'),
        reason: 'a `//` inside a string literal must survive stripping',
      );
      expect(_buildMarker.hasMatch(stripped), isTrue);
      expect(_versionMarker.hasMatch(stripped), isTrue);
    });

    test('raw-string escape sequences do not swallow the line', () {
      final source =
          "final digits = r'\\d+\\s+'; // comment\nfinal line = 'Versi 9.9.9';";
      final stripped = stripDartComments(source);
      expect(stripped, isNot(contains('// comment')));
      expect(stripped, contains("'Versi 9.9.9'"));
    });

    test('the shipped defect shape is detected as a declaration member', () {
      const defect =
          "class _AppInfo {"
          "  static const String version = '1.2.2';"
          "  static const String buildNumber = '5';"
          "}";
      expect(
        _displayMember.allMatches(defect).length,
        2,
        reason: 'BOTH halves of the shipped defect must be detected',
      );
    });

    test(
      'every marker-bearing presentation file imports the AppVersion seam',
      () {
        // Plan TASK-008 step 4. The closed-set variant (allowlist of
        // consumers) was rejected as brittle — the invariant is open-ended:
        // marker ⇒ import, plus the known consumer pinned separately.
        final root = Directory('lib/presentation');
        final misfits = <String>[];
        for (final file in enumerateDartFiles(root)) {
          final code = stripDartComments(readDartSource(file));
          final isMarkerBearing =
              _versionMarker.hasMatch(code) || _buildMarker.hasMatch(code);
          if (!isMarkerBearing) {
            continue;
          }
          final importsSeam = dartImportPaths(
            code,
          ).any((path) => path.endsWith('core/app_version.dart'));
          if (!importsSeam) {
            misfits.add(
              '${file.path} is marker-bearing but imports only '
              '[${dartImportPaths(code).join(', ')}]',
            );
          }
        }
        expect(
          misfits,
          isEmpty,
          reason:
              'a version/build display surface must read from '
              'core/app_version.dart, never restate the value',
        );
      },
    );

    test(
      'no presentation file declares a version/buildNumber display member',
      () {
        // Plan TASK-008 step 5 — covers both the version and the bare
        // build-number half of the defect by construction.
        final root = Directory('lib/presentation');
        final offenders = <String>[];
        for (final file in enumerateDartFiles(root)) {
          if (_displayMember.hasMatch(
            stripDartComments(readDartSource(file)),
          )) {
            offenders.add(file.path);
          }
        }
        expect(
          offenders,
          isEmpty,
          reason:
              'a re-introduced `static const String version/buildNumber` '
              'MUST fail this scan',
        );
      },
    );

    test('the known consumer about_section.dart imports AppVersion', () {
      // Plan TASK-008 step 6 — the marker scan is open-ended, so pin the
      // known surface explicitly.
      final file = File(
        'lib/presentation/pages/settings/sections/about_section.dart',
      );
      final imports = dartImportPaths(stripDartComments(readDartSource(file)));
      expect(
        imports.any((path) => path.endsWith('core/app_version.dart')),
        isTrue,
        reason: 'the render site must bind to the seam',
      );
    });

    test('lib/core/app_version.dart imports only the services package', () {
      // Plan TASK-008 step 7 — CON-006's dependency-direction invariant,
      // checked mechanically instead of claimed.
      final file = File('lib/core/app_version.dart');
      expect(dartImportPaths(readDartSource(file)), [
        'package:flutter/services.dart',
      ], reason: 'no data/domain/presentation, no sqflite, no firebase');
    });

    test('the scan fails loudly when the scanned root is missing', () {
      // CON-007 — an unreachable scan must throw, never silently pass.
      expect(
        () => enumerateDartFiles(Directory('lib/presentation/does-not-exist')),
        throwsStateError,
      );
    });
  });
}
