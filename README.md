# 📖 Al-Quran App

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

Aplikasi Al-Quran digital yang modern dan mudah digunakan, dibangun dengan Flutter. Aplikasi ini menyediakan akses lengkap ke 114 surah Al-Quran dengan berbagai fitur yang memudahkan pengguna dalam membaca dan mempelajari Al-Quran.

## ✨ Fitur Utama

### 📚 Konten Lengkap

- **114 Surah Lengkap** - Semua surah dalam Al-Quran dengan terjemahan Indonesia
- **30 Juz** - Pembagian berdasarkan juz untuk memudahkan membaca
- **Teks Arab** - Tulisan Arab yang jelas dan mudah dibaca
- **Transliterasi** - Pembacaan latin untuk membantu pembelajaran
- **Terjemahan Indonesia** - Terjemahan yang mudah dipahami
- **Audio** - Dengarkan bacaan Al-Quran dari setiap ayat

### 🔍 Pencarian Cerdas

- Cari surah berdasarkan nama (Arab/Latin)
- Cari berdasarkan nomor surah
- Cari berdasarkan terjemahan
- Filter pencarian untuk juz
- Hasil pencarian real-time

### 🔖 Bookmark & Last Read

- Simpan ayat favorit sebagai bookmark
- Otomatis menyimpan posisi terakhir membaca
- Akses cepat ke ayat yang di-bookmark
- Hapus bookmark dengan mudah

### 🎨 Tema & Tampilan

- **Light Mode** - Tema terang untuk siang hari
- **Dark Mode** - Tema gelap untuk kenyamanan mata
- Desain modern dan minimalis
- UI yang responsif dan smooth
- Animasi halus

### ⚡ Performa Tinggi

- **Smart Caching** - Data di-cache secara otomatis
- **Offline Mode** - Baca Al-Quran tanpa internet setelah data ter-cache
- Loading cepat dengan in-memory cache
- Auto-refresh cache setiap 7 hari
- Hemat kuota internet

### 🎵 Audio Player

- Putar audio untuk setiap ayat
- Kontrol play, pause, stop
- Audio berkualitas tinggi

## 📱 Screenshot

_*Screenshots akan ditambahkan di sini*_

## 🚀 Teknologi & Arsitektur

### Framework & Libraries

- **Flutter** - UI Framework
- **GetX** - State Management & Navigation
- **Get Storage** - Local Storage untuk caching
- **SQLite** - Database untuk bookmark
- **Just Audio** - Audio player
- **HTTP** - API calls

### Arsitektur

- **GetX Pattern** - Separation of concerns
- **MVC Architecture** - Model-View-Controller
- **Service Layer** - Caching service
- **Repository Pattern** - Data management

### API

- **Quran API** - [https://quran-api-chi.vercel.app](https://quran-api-chi.vercel.app)
  - GET `/surah` - Daftar semua surah
  - GET `/surah/{id}` - Detail surah dengan ayat
  - GET `/juz/{id}` - Detail juz dengan ayat

## 📦 Instalasi & Setup

### Prasyarat

```bash
Flutter SDK: 3.0 atau lebih baru
Dart SDK: 3.0 atau lebih baru
Android Studio / VS Code
Git
```

### Clone Repository

```bash
git clone https://github.com/yourusername/quranapp.git
cd quranapp
```

### Install Dependencies

```bash
flutter pub get
```

### Run Application

```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Specific device
flutter run -d <device_id>
```

### Build APK

```bash
# Build APK
flutter build apk

# Build App Bundle
flutter build appbundle

# Build dengan split per ABI (ukuran lebih kecil)
flutter build apk --split-per-abi
```

## 📂 Struktur Project

```
lib/
├── main.dart                          # Entry point aplikasi
├── app/
│   ├── contants/
│   │   └── colors.dart               # Theme colors
│   ├── data/
│   │   ├── db/
│   │   │   └── bookmark.dart         # SQLite database manager
│   │   ├── models/
│   │   │   ├── surah.dart           # Model Surah
│   │   │   ├── juz.dart             # Model Juz
│   │   │   └── detailsurah.dart     # Model Detail Surah
│   │   └── services/
│   │       └── quran_cache_service.dart  # Caching service
│   ├── modules/
│   │   ├── home/                    # Home module
│   │   ├── search/                  # Search module
│   │   ├── detail_surah/            # Detail Surah module
│   │   ├── detail_juz/              # Detail Juz module
│   │   └── introduction/            # Introduction module
│   └── routes/
│       ├── app_pages.dart           # Route definitions
│       └── app_routes.dart          # Route names
└── assets/
    ├── images/                      # Image assets
    ├── icon/                        # App icons
    └── lotties/                     # Lottie animations
```

## 🎯 Cara Menggunakan

### 1. Membaca Al-Quran

- Pilih tab **Surah** atau **Juz** di halaman utama
- Tap pada surah/juz yang ingin dibaca
- Scroll untuk membaca ayat-ayat
- Tap icon audio untuk mendengarkan bacaan

### 2. Mencari Surah/Juz

- Tap icon **search** di pojok kanan atas
- Ketik nama surah, nomor, atau terjemahan
- Pilih dari hasil pencarian
- Tab bisa diubah antara Surah dan Juz

### 3. Membuat Bookmark

- Buka surah/juz yang ingin di-bookmark
- Tap icon **bookmark** di samping ayat
- Pilih **Add Bookmark** atau **Last Read**
- Akses bookmark di tab **Bookmark**

### 4. Mengubah Tema

- Tap icon **tema** (palette) di halaman utama
- Tema akan berubah otomatis antara light/dark

## 🔧 Konfigurasi

### Cache Duration

Edit file `quran_cache_service.dart`:

```dart
static const int _cacheDurationDays = 7; // Ubah sesuai kebutuhan
```

### Theme Colors

Edit file `colors.dart`:

```dart
const appPurpleLight1 = Color(0xFFB9A2D8);
const appPurpleDark = Color(0xFF672CBC);
// Tambahkan atau ubah warna sesuai keinginan
```

### Guidelines

- Ikuti struktur code yang ada
- Gunakan GetX pattern
- Tambahkan comment jika diperlukan
