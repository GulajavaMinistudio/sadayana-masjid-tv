# 🕌 Miqotul Khoir TV

![Platform: Android TV](https://img.shields.io/badge/platform-Android%20TV-green)
![Framework: Flutter](https://img.shields.io/badge/framework-Flutter-blue)
![Architecture: Clean Architecture](https://img.shields.io/badge/architecture-Clean%20Architecture-purple)
![Status: Production Ready](https://img.shields.io/badge/status-Production%20Ready-green)
![License: GPL v3](https://img.shields.io/badge/license-GPL%20v3-blue)
[![Get it on Google Play](https://img.shields.io/badge/Google%20Play-Get%20it%20on-black?logo=google-play&logoColor=white)](https://play.google.com/store/apps/details?id=gulajava.mini.miqotul_khoir_tv&pli=1)

Aplikasi **jam masjid digital** dan papan informasi jadwal sholat berbasis Android TV. Dirancang untuk menggantikan jam jadwal sholat konvensional di masjid atau musala dengan tampilan yang indah dan mudah dibaca dari jarak jauh.

Dapatkan aplikasi resminya di [Google Play Store](https://play.google.com/store/apps/details?id=gulajava.mini.miqotul_khoir_tv&pli=1).

Dirancang dengan prinsip **Offline-First** — cukup masukkan koordinat lokasi satu kali, dan aplikasi ini menghitung jadwal sholat secara **presisi abadi** tanpa perlu terhubung ke internet. Kompatibel dengan **TV Android**, **TV Pintar**, dan **Kotak Dekoder**.

---

## ✨ Fitur Utama

### 🕐 Jadwal Sholat Real-Time (Offline)

- Kalkulasi astronomis menggunakan library `adhan-dart` — **100% offline**
- Mendukung 7 waktu sholat: **Subuh, Syuruq, Dhuha, Dzuhur, Ashar, Maghrib, Isya**
- Standar **Kemenag RI (SIHAT)** — Subuh 20°, Isya 18°, Ihtiyat bawaan +2 menit
- Koreksi Ketinggian Tempat (**DPL/Elevasi**) — akurasi Syuruq & Maghrib untuk kota dataran tinggi
- Koreksi manual (Ihtiyat) per waktu sholat (-30 s/d +30 menit)
- **Penanganan Jum'at** — label, durasi iqomah, dan durasi layar mati khusus hari Jumat
- Konversi tanggal Hijriah dengan adjustment manual (H-1 / H+1)

### 🔄 State Machine — 9 Mode Tampilan Otomatis

| State                    | Trigger                                                   | Tampilan                                                               |
| ------------------------ | --------------------------------------------------------- | ---------------------------------------------------------------------- |
| **Standby**              | Default                                                   | Jam besar, tanggal, jadwal sholat, running text                        |
| **Pre-Adzan**            | H-N menit sebelum waktu sholat (default 10, dapat diatur) | Countdown timer + highlight jadwal terkait                             |
| **Adzan**                | Waktu sholat tiba                                         | Visual "SAATNYA ADZAN"                                                 |
| **Iqomah**               | Setelah adzan selesai                                     | Countdown timer iqomah (durasi per sholat)                             |
| **Sholat**               | Timer iqomah habis                                        | Layar gelap / jam redup (OLED safe)                                    |
| **Slideshow Pengumuman** | Periodik sesuai interval                                  | Full-screen gambar pengumuman (maks 3 slot gambar)                     |
| **Jadwal Imam**          | Periodik sesuai interval                                  | Full-screen jadwal imam sholat hari ini (maks 10 imam, support Jum'at) |
| **Kata Mutiara**         | Periodik sesuai interval                                  | Full-screen ayat Al-Quran / Hadits terjemahan                          |
| **Mode Hemat Daya**      | Jam malam yang dikonfigurasi (cross-midnight support)     | Layar hitam, jam digital redup, info Subuh, anti burn-in drift         |

### 📺 Dioptimalkan untuk Android TV

- **D-Pad Navigation First** — semua elemen fokusable via remote control
- Resolusi 16:9 Landscape (1920×1080 FHD)
- Anti screen burn-in mechanism (gradient shift periodik)
- Minimum tap target 48×48 logical pixels (accessibility)

### 🎨 Islamic Glassmorphism Design

- Tema **Deep Emerald Green** dengan aksen **Gold/Amber**
- Efek glassmorphism (backdrop blur + semi-transparent)
- Typography menggunakan font **Poppins** via Google Fonts
- Responsive UI dengan `flutter_screenutil`

### ⚙️ Setup Wizard & Settings

- **4-step first-run wizard**: Welcome → Identitas Masjid → Lokasi → Konfirmasi
- Pilih kota dari database **514 kota, 34 provinsi** Indonesia (pre-populated, termasuk data elevasi)
- Menu settings dengan **15 kategori**: Identitas Masjid, Koreksi Waktu (Ihtiyat), Durasi Iqomah,
  Pengaturan Dhuha, Durasi Tampilan, Alarm Tanda Waktu, Running Text, Keamanan (PIN),
  Informasi Kas, Kata Mutiara, Slideshow Pengumuman, Jadwal Imam Sholat, Mode Hemat Daya,
  Reset Data, Tentang Aplikasi
- Menu settings dilindungi PIN opsional (SHA-256)
- **Informasi Kas Masjid** — tampilkan saldo, pemasukan, pengeluaran di layar utama (opsional)
- **Alarm Tanda Waktu** — bunyi alarm otomatis beberapa detik sebelum Adzan dan/atau Iqomah
  (5–15 detik, konfigurasi independen untuk Pre-Adzan dan Pre-Iqomah)
- **Mode Hemat Daya Tengah Malam** — screensaver otomatis jam malam dengan anti burn-in drift,
  window waktu lintas tengah malam dapat dikonfigurasi
- Running text (marquee) yang dapat diedit

---

## 🏗️ Arsitektur

Proyek ini menggunakan **Clean Architecture** dengan layer yang terpisah jelas:

```
lib/
├── core/              # Utilities, constants, theme system
│   └── theme/         # Islamic colors, typography, ThemeData
├── data/              # SQLite models, repositories, data sources
│   ├── datasources/   # DatabaseHelper, local data sources
│   ├── models/        # Data models (fromMap/toMap)
│   ├── repositories/  # Repository implementations
│   └── services/      # AudioAlertServiceImpl dan service konkret lain
├── domain/            # Business logic (pure Dart, zero infra imports)
│   ├── entities/      # Immutable domain entities
│   ├── repositories/  # Abstract repository interfaces
│   ├── services/      # Abstract service interfaces (AudioAlertService)
│   └── usecases/      # Business use cases
└── presentation/      # UI layer
    ├── cubits/        # State management (Cubit)
    ├── pages/         # Screen layouts dan halaman settings
    └── widgets/       # Reusable UI components
```

### Prinsip Arsitektur

- **Dependency Rule** — outer layer depends on inner, never reverse
- **State Management** — Cubit (dari `flutter_bloc`)
- **Data Persistence** — SQLite offline-first, single source of truth
- **Repository Pattern** — abstraksi akses data via interface

---

## 📦 Tech Stack

| Kategori               | Package                                       | Kegunaan                                         |
| ---------------------- | --------------------------------------------- | ------------------------------------------------ |
| **Framework**          | Flutter (Dart SDK ^3.11.0)                    | UI framework                                     |
| **Database**           | `sqflite`                                     | SQLite lokal                                     |
| **State Management**   | `flutter_bloc` / Cubit                        | Reactive state                                   |
| **Prayer Calculation** | `adhan`                                       | Kalkulasi astronomi                              |
| **Calendar**           | `hijri`                                       | Konversi tanggal Hijriah                         |
| **UI Scaling**         | `flutter_screenutil`                          | Responsive (1920×1080 baseline)                  |
| **Typography**         | `google_fonts`                                | Poppins font (bundled offline, no runtime fetch) |
| **Running Text**       | `marquee`                                     | Horizontal scrolling ticker                      |
| **Formatting**         | `intl`                                        | Format tanggal & angka Rupiah (id_ID)            |
| **Equality**           | `equatable`                                   | Value equality untuk entities                    |
| **Security**           | `crypto`                                      | SHA-256 PIN hashing                              |
| **Audio**              | `audioplayers`                                | Alarm audio pre-adzan & pre-iqomah               |
| **Analytics**          | `firebase_analytics` + `firebase_crashlytics` | Usage analytics & crash reporting                |
| **Error Handling**     | `error_stack`                                 | Formatted stack trace logging                    |

---

## 📊 Status Implementasi

|   #   | Plan                         | Scope                                                                                                  | Status |
| :---: | ---------------------------- | ------------------------------------------------------------------------------------------------------ | :----: |
|  01   | Database Infrastructure      | DatabaseHelper, DDL, migration v1-v9, seed 514 kota                                                    |   ✅    |
|  02   | Data Layer                   | Entities, models, repositories, PIN hashing                                                            |   ✅    |
|  03   | Theme System                 | Colors, typography, ThemeData, ScreenUtil, TV safe area                                                |   ✅    |
|  04   | UI Components                | GlassmorphismCard, FocusableWidget, IslamicBackground, RunningText                                     |   ✅    |
|  05   | Prayer Calculation           | PrayerTime entities, CalculateUseCase, Kemenag SIHAT, DPL                                              |   ✅    |
|  06   | Prayer Cubit                 | PrayerTimeCubit, states, midnight timer                                                                |   ✅    |
|  07   | State Evaluation             | DisplayState classes (7 states), EvaluateUseCase                                                       |   ✅    |
|  08   | Display State Machine        | DisplayStateCubit, tick timer, power recovery                                                          |   ✅    |
|  09   | Setup Wizard Logic           | SetupWizardCubit, validation, step navigation                                                          |   ✅    |
|  10   | Setup Wizard UI              | 4 step pages, city picker, prayer preview                                                              |   ✅    |
|  11   | Settings Logic               | SettingsCubit, auto-save, PIN management                                                               |   ✅    |
|  12   | Settings UI                  | Menu pages, DPadStepper, PinInput, 13 categories                                                       |   ✅    |
|  13   | Main Display UI              | 7 layout states, AnimatedSwitcher, D-Pad menu access                                                   |   ✅    |
|   —   | Kemenag Method Fix           | Ganti MUIS → SIHAT, fix ihtiyat bawaan +2 menit                                                        |   ✅    |
|   —   | Elevation/DPL                | Koreksi ketinggian tempat untuk akurasi Maghrib/Syuruq                                                 |   ✅    |
|   —   | Jum'at Handling              | Label dinamis, durasi layar & iqomah khusus Jum'at                                                     |   ✅    |
|   —   | Treasury/Kas Masjid          | Widget informasi saldo kas di Standby Layout                                                           |   ✅    |
|   —   | Rebranding                   | SMD → Miqotul Khoir TV, seluruh dokumen & kode                                                         |   ✅    |
|   —   | Kata Mutiara Islam           | WisdomQuoteState (state ke-6), katalog 11 item Quran & Hadits, Settings UI, preview page               |   ✅    |
|   —   | Mode Hemat Daya Tengah Malam | MidnightStandbyState (state ke-7), screensaver, anti burn-in, window konfigurasi cross-midnight        |   ✅    |
|   —   | Alarm Tanda Waktu            | Audio alert pre-adzan & pre-iqomah, AudioAlertService (DIP), konfigurasi 5–15 detik                    |   ✅    |
|   —   | Slideshow Pengumuman         | SlideshowAnnouncementState, 3 slot gambar, manajemen file lokal, Settings UI, migrasi v10              |   ✅    |
|   —   | Jadwal Imam Sholat           | ImamScheduleState (state ke-9), tabel imams+imam_schedules, FK enforcement, Settings CRUD, migrasi v11 |   ✅    |

> **Legend**: ✅ Completed

### Test Coverage

| Layer                                                                                 |  Tests   |
| ------------------------------------------------------------------------------------- | :------: |
| Data (models, repositories, database)                                                 |   80+    |
| Theme (colors, typography, theme)                                                     |    42    |
| Domain & Business Logic (Prayer, State, Setup, Settings, Jum'at, Wisdom, Alarm, Imam) |   125+   |
| Widgets & Presentation (Cubit, UI components, widgets)                                |   175+   |
| **Total**                                                                             | **400+** |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ^3.11.0
- Android Studio / VS Code
- Android TV emulator atau perangkat fisik

### Instalasi

```bash
# Clone repository
git clone https://github.com/GulajavaMinistudio/miqotul-khoir-tv.git
cd miqotul-khoir-tv

# Install dependencies
flutter pub get

# Run tests
flutter test --reporter=expanded

# Run di Android TV emulator
flutter run
```

---

## 📁 Dokumentasi

| Dokumen                                                              | Deskripsi                                                   |
| -------------------------------------------------------------------- | ----------------------------------------------------------- |
| [`Product_Requirement_Document.md`](Product_Requirement_Document.md) | PRD lengkap dengan functional & non-functional requirements |
| [`docs/SPECIFICATION_OVERVIEW.md`](docs/SPECIFICATION_OVERVIEW.md)   | Overview 6 technical specifications                         |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)                       | Peta arsitektur kanonik: topologi, seams, invariant         |
| [`docs/ARCHITECTURE_PATTERNS.md`](docs/ARCHITECTURE_PATTERNS.md)     | State machine, offline-first, timer patterns                |
| [`docs/UI_UX_GUIDE.md`](docs/UI_UX_GUIDE.md)                         | Android TV design, ScreenUtil, glassmorphism                |
| [`docs/TESTING_GUIDE.md`](docs/TESTING_GUIDE.md)                     | Testing strategies (SQLite, Cubit, widget)                  |
| [`plan/README.md`](plan/README.md)                                   | Index 12 implementation plans                               |

---

## 🎯 Target Users

- **Admin DKM (Primary Operator)** — Mengatur jadwal sholat dan konten via remote TV
- **Jamaah (Viewer)** — Melihat waktu sholat, iqomah, dan informasi masjid

---

## 🫶 Dukung Pengembangan

Jika kamu menyukai aplikasi ini dan ingin tetap berlanjut pengembangannya,
silahkan donasi seikhlasnya melalui Saweria berikut ini.

<a href="https://saweria.co/GulajavaMinistudio" target="_blank">
  <img src="assets/images/saweria_png_yellow.png" alt="QR Code Donasi Saweria - Gulajava Ministudio" width="280">
</a>

[☕ Donasi via Saweria — saweria.co/GulajavaMinistudio](https://saweria.co/GulajavaMinistudio)

---

## 📄 License

Proyek ini dilisensikan di bawah **GNU General Public License v3.0 (GPL-3.0)**.

Artinya Anda bebas untuk:
- ✅ Menggunakan, mempelajari, dan memodifikasi kode ini
- ✅ Mendistribusikan ulang kode ini
- ✅ Menggunakan untuk keperluan komersial

Dengan syarat:
- 📋 Kode turunan (modifikasi) **wajib** dilisensikan dengan GPL v3 juga
- 📋 Source code wajib tersedia / open source

Lihat file [LICENSE](LICENSE) untuk teks lengkap lisensi.
