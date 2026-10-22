# Development Workflow Guide - Miqotul Khoir TV

This guide covers development workflows, commit standards, testing procedures, and deployment strategies for the Miqotul Khoir TV (MKT) Flutter project.

> [!IMPORTANT]
> **Peta arsitektur kanonik:** Untuk topologi sistem, Clean Architecture seams, perintah verifikasi (`check:fast` / `check:task` / `check:full`), dan quality ratchet yang aktif, lihat [`docs/ARCHITECTURE.md`](ARCHITECTURE.md) §8. Implementasi aktual di `lib/` adalah sumber kebenaran (source of truth) — contoh kode di panduan ini bersifat ilustratif.

## Git Workflow

### Commit Message Format

Use conventional commit format for consistent versioning and changelog generation:

```text
type(scope): description

Examples:
feat(prayer): implement astronomical prayer time calculation
feat(state): add state machine with 9-state transitions
fix(db): resolve SQLite transaction safety issue
fix(ui): fix D-Pad focus traversal on settings screen
perf(timer): optimize countdown timer memory usage
refactor(cubit): simplify DisplayStateCubit logic
test(sqlite): add 25 unit tests for settings repository
test(prayer): add prayer time calculation edge case tests
style(theme): update Islamic glassmorphism theme colors
docs(readme): update Android TV setup instructions
chore(deps): update adhan-dart to latest version
```

### Commit Types

- **feat**: New feature implementation
- **fix**: Bug fixes
- **perf**: Performance improvements
- **refactor**: Code restructuring without functionality changes
- **test**: Adding or updating tests
- **style**: Code formatting and style changes
- **docs**: Documentation updates
- **chore**: Maintenance tasks and dependency updates

### Branch Naming Convention

```text
feature/feature-name
bugfix/issue-description
hotfix/critical-fix
refactor/code-improvement

Examples:
feature/setup-wizard
feature/iqomah-countdown
bugfix/timer-memory-leak
bugfix/dpad-focus-lost
hotfix/prayer-time-calculation
refactor/state-machine-logic
```

## Testing Workflow

### Basic Testing Commands

```bash
# Run all tests with detailed output (required format)
flutter test --reporter=expanded

# Generate coverage report
flutter test --coverage

# Run specific test categories
flutter test test/domain/              # Domain layer (entities + use cases)
flutter test test/data/                # Data layer (models, repositories, datasources)
flutter test test/presentation/        # Presentation layer (cubits, pages, widgets)
flutter test test/core/                # Theme and TV sizing helpers
flutter test test/analysis/            # Kemenag SIHAT comparison harness

# Run specific test file
flutter test test/data/repositories/settings_repository_impl_test.dart --reporter=expanded

# Run tests with coverage and generate HTML report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

> **Note**: Widget tests yang menggunakan `ScreenUtil` perlu di-wrap dengan `ScreenUtilInit` pada test setup.

### Test Organization

```text
test/
├── domain/                    # Domain layer
│   ├── entities/             # Entity tests
│   └── usecases/             # Use case tests
├── data/                      # Data layer
│   ├── models/                # SQLite row model tests
│   ├── repositories/          # Repository tests (in-memory SQLite)
│   └── datasources/           # Data source tests
├── presentation/              # Presentation layer
│   ├── cubits/                # State management tests (incl. *_lifecycle_test.dart)
│   ├── pages/                 # Page + layout widget tests
│   └── widgets/               # Reusable widget tests
├── core/                      # Theme, typography, colors, TV safe area
├── analysis/                  # Scaffold validation against Kemenag SIHAT
├── preview_test.dart          # Root-level smoke test
└── widget_test.dart           # Root-level smoke test
```

> [!NOTE]
> Mock implementations live next to the tests that consume them (e.g. `MockSettingsRepository` inside the repository test file) rather than in a shared `test/mocks/` folder. There is no `test/unit/`, `test/widget/`, or `test/integration/` directory.

### Testing Best Practices

1. **Use --reporter=expanded flag**: Required for detailed debugging information
2. **Maintain high coverage**: Aim for 90%+ coverage on business logic
3. **Test all state transitions**: Especially for DisplayStateCubit (9-state machine)
4. **Mock SQLite with in-memory DB**: Use proper in-memory database for repository tests
5. **Validate prayer time accuracy**: Test edge cases for astronomical calculation
6. **Test timer lifecycle**: Ensure timers are properly disposed to prevent memory leaks
7. **Test D-Pad navigation**: Validate focus traversal and keyboard events

### Test Naming Convention

```dart
// Format: should_[expected behavior]_when_[condition]
void main() {
  group('DisplayStateCubit', () {
    test('should emit PreAdzanState when 10 minutes before prayer', () {
      // Test implementation
    });
    
    test('should emit AdzanState when prayer time arrives', () {
      // Test implementation
    });
    
    test('should transition from Iqomah to Sholat when countdown ends', () {
      // Test implementation
    });
  });
}
```

## Code Quality Workflow

### Pre-commit Checklist

```bash
# Format code (scoped to lib/ and test/ — `dart format .` crashes on build/ artifacts)
dart format lib test

# Analyze code for issues
dart analyze

# Run tests
flutter test --reporter=expanded

# Check for unused dependencies
flutter pub deps

# Build for Android TV
flutter build apk --debug
```

### Code Review Checklist

Before submitting a PR, ensure:

- [ ] All tests pass with --reporter=expanded
- [ ] Code is properly formatted (dart format lib test)
- [ ] No analyzer warnings (dart analyze)
- [ ] Proper error handling implemented
- [ ] Input validation added where necessary
- [ ] State management follows established patterns (Cubit)
- [ ] SQLite transactions are atomic and safe
- [ ] Timers are properly disposed in dispose() method
- [ ] D-Pad navigation works correctly
- [ ] ScreenUtil extensions digunakan konsisten (`.sp`, `.w`, `.h`, `.r`)
- [ ] Documentation updated if needed
- [ ] Session memory updated (lihat section berikut)

### Session Memory Update

Setiap kali **satu fitur atau fase SDLC selesai dikerjakan**, agent **wajib** menyimpan
kesimpulan/rekap ke `.agents/instructions/memory.instructions.md`. Ini penting karena
setiap fase development dimulai di sesi chat baru — tanpa rekap, konteks akan hilang.

**Yang harus dicatat di memory:**

- Keputusan teknis penting (library, pattern, atau pendekatan yang dipilih)
- Perubahan arsitektur atau konvensi baru yang diterapkan
- Hal-hal yang perlu diingat untuk fase berikutnya (dependency, breaking changes)
- Status implementasi fitur (selesai, partial, atau blocked)

**Format penulisan di memory:**

```markdown
## [Nama Fitur / Fase]

- **Status**: Selesai / In Progress / Blocked
- **Keputusan**: [ringkasan keputusan teknis]
- **Catatan untuk sesi berikutnya**: [hal yang perlu diperhatikan]
```

> **Kapan harus update?**
>
> - Setelah menyelesaikan satu fitur (feature branch merge)
> - Setelah menyelesaikan satu fase SDLC (PRD → Spec → Plan → Code → Test)
> - Ketika ada keputusan teknis signifikan yang mempengaruhi development selanjutnya

## Development Environment Setup

### Required Tools

```bash
# Check Flutter installation
flutter doctor

# Get project dependencies
flutter pub get

# Clean build artifacts
flutter clean

# Run on Android TV emulator
flutter run

# Run on physical Android TV device
flutter run -d <android-tv-id>
```

### IDE Configuration

#### VS Code Extensions

- Flutter
- Dart
- Flutter Tree
- Flutter Widget Snippets
- GitLens
- Error Lens
- SQLite Viewer (untuk inspect database)

#### Recommended Settings

```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.previewFlutterUiGuides": true,
  "dart.previewFlutterUiGuidesCustomTracking": true,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  },
  "files.exclude": {
    "**/*.g.dart": true,
    "**/*.freezed.dart": true
  }
}
```

## SQLite Database Workflow

### Database Migration

When updating the database schema:

```dart
// 1. Update schema version in DatabaseHelper
static const int _dbVersion = 2; // Increment version

// 2. Implement migration in _onUpgrade
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    // Add new column example
    await db.execute('''
      ALTER TABLE settings ADD COLUMN new_field TEXT DEFAULT ''
    ''');
  }
}

// 3. Test migration manually
// - Install app with old schema
// - Upgrade app with new schema
// - Verify data integrity
```

### Database Inspection

```bash
# On Android TV device, pull the database file
adb pull /data/data/gulajava.mini.miqotul_khoir_tv/databases/miqotul_khoir.db .

# Open with SQLite browser or command line
sqlite3 miqotul_khoir.db
```

## Prayer Time Validation Workflow

Validate prayer time accuracy against official sources:

```bash
# 1. Run the app and note calculated prayer times
flutter run

# 2. Compare with official Kemenag website
# https://bimasislam.kemenag.go.id/jadwalshalat

# 3. Adjust manual corrections if needed (±10 minutes max)
# Settings → Koreksi Waktu Sholat

# 4. Verify astronomical calculation
# Test with different coordinates
# Test with edge cases (near poles, equator)
```

## Performance Monitoring

### Development Profiling

```bash
# Run with performance monitoring
flutter run --profile

# Analyze performance
flutter run --trace-startup --profile

# Memory profiling
flutter run --enable-profiling
```

### Build Optimization

```bash
# Release build for Android TV
flutter build apk --release

# Analyze bundle size
flutter build apk --analyze-size

# Build for specific architecture (optimize size)
flutter build apk --target-platform android-arm64 --release
```

## Android TV Deployment

### Debug Build

```bash
# Build debug APK
flutter build apk --debug

# Install to connected Android TV
flutter install

# Run directly on Android TV
flutter run -d <android-tv-id>
```

### Release Build

```bash
# Build signed release APK
flutter build apk --release

# Install release APK
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### Device Setup

```bash
# Enable developer mode on Android TV
# Settings → About → Build Number (click 7 times)

# Enable ADB debugging
# Settings → Developer Options → USB Debugging

# Connect via ADB (Wi-Fi)
adb connect <android-tv-ip>:5555

# Verify connection
adb devices

# Check connected device ID
flutter devices
```

## Continuous Integration

> [!WARNING]
> **Belum ada pipeline CI yang di-check-in.** Workflow di bawah adalah *rekomendasi*, bukan konfigurasi aktif — repo ini tidak memiliki direktori `.github/` sama sekali. Saat ini seluruh quality gate (§8.2 `check:fast` / `check:task` / `check:full`) dijalankan secara lokal oleh developer atau agent.

### GitHub Actions Workflow

Basic CI pipeline for automated testing:

```yaml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - run: dart format --set-exit-if-changed .
      - run: dart analyze
      - run: flutter test --reporter=expanded
      - run: flutter build apk --debug
```

## Common Development Issues

### Timer Memory Leaks

**Problem**: Timers not disposed, causing memory leaks

**Solution**:
```dart
@override
void dispose() {
  _timer?.cancel();
  _timer = null;
  super.dispose();
}
```

### SQLite Transaction Failures

**Problem**: Database locked or corrupted during write

**Solution**: Always use transactions
```dart
await db.transaction((txn) async {
  await txn.update('settings', data, where: 'id = ?', whereArgs: [1]);
});
```

### D-Pad Focus Issues

**Problem**: Focus lost or incorrect traversal order

**Solution**: Explicit focus management
```dart
Focus(
  autofocus: true,
  child: YourWidget(),
)
```

## Related Documentation

- [Architecture Map](ARCHITECTURE.md) - Peta arsitektur kanonik, seams, quality ratchet, dan perintah verifikasi
- [Architecture Patterns](ARCHITECTURE_PATTERNS.md) - State machine, offline-first, prayer calculation patterns
- [Domain Glossary](../CONTEXT.md) - Ubiquitous language dan aturan terminologi
- [Testing Guide](TESTING_GUIDE.md) - Comprehensive testing strategies
- [UI/UX Guide](UI_UX_GUIDE.md) - Android TV design guidelines and D-Pad navigation
- [Execution Workflow](EXECUTION_WORKFLOW.md) - Phased execution with checkpoint gates

---

This workflow ensures consistent development practices and high code quality for the Miqotul Khoir TV project.
