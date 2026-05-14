# ♻️ RecycleMate

**Social Marketplace for Upcycled Goods**

RecycleMate adalah platform digital yang menghubungkan kolektor sampah anorganik dengan pengrajin kreatif di Indonesia. Aplikasi ini mendukung ekonomi sirkular dengan memfasilitasi jual-beli dan donasi barang upcycle — barang bekas yang dimodifikasi menjadi produk bernilai tinggi.

---

## 📱 Tampilan Aplikasi

| Splash Screen | Home Screen | Product Detail | Upload/Donasi |
|:---:|:---:|:---:|:---:|
| Onboarding visi app | Grid produk + filter | Detail & beli produk | Form donasi barang |

---

## 🎯 Fitur Utama

- **Splash / Onboarding Screen** — Perkenalan visi dan misi RecycleMate
- **Home Screen** — Grid produk upcycle dengan filter kategori & pencarian real-time
- **Product Detail Screen** — Detail produk, profil pengrajin, tombol beli & hubungi
- **Upload / Donasi Screen** — Form donasi barang bekas dengan counter jumlah

### Fitur Interaktif
- ❤️ Toggle **Favorite** produk (merah/outline)
- 🛒 **Keranjang belanja** dengan badge counter
- 🔔 **Notifikasi** popup
- 🔍 **Pencarian** produk real-time
- 🏷️ **Filter kategori** — Semua, Plastik, Kayu, Kaca, Kain
- 📦 **Quantity selector** di detail produk & form donasi
- 📲 **Hubungi Pengrajin** via WhatsApp / Instagram (bottom sheet)
- ✅ **Success state** setelah submit donasi

---

## 🏗️ Struktur Proyek

```
recyclemate/
├── lib/
│   ├── main.dart                        # Entry point + MaterialApp + routing
│   ├── screens/
│   │   ├── splash_screen.dart           # Onboarding screen
│   │   ├── home_screen.dart             # Home + grid produk (Stateful)
│   │   ├── product_detail_screen.dart   # Detail produk (Stateful)
│   │   └── upload_screen.dart           # Form donasi (Stateful)
│   └── widgets/
│       ├── product_card.dart            # Card produk dengan Stack favorite
│       ├── product_illustration.dart    # Ilustrasi custom per jenis produk
│       ├── category_chip.dart           # Label kategori material
│       ├── custom_button.dart           # Tombol gradient & outlined
│       └── section_title.dart           # Judul section konsisten
├── android/                             # Konfigurasi Android
├── assets/images/                       # Asset gambar
├── pubspec.yaml                         # Dependencies
└── run.bat                              # One-click launcher
```

---

## ✅ Pemenuhan Kriteria Teknis

### Widget Requirements

| Tipe | Widget | Keterangan |
|------|--------|------------|
| **Stateless** | `ProductCard` | Card produk dengan Stack untuk ikon favorite |
| **Stateless** | `CustomButton` | Tombol gradient & outlined variant |
| **Stateless** | `CategoryChip` | Label material (Plastik, Kayu, Kaca, dll) |
| **Stateless** | `SectionTitle` | Judul section dengan accent bar hijau |
| **Stateless** | `ProductIllustration` | Ilustrasi custom per jenis produk |
| **Stateful** | `HomeScreen` | Filter kategori, search, favorites, cart |
| **Stateful** | `ProductDetailScreen` | Favorite toggle, qty selector |
| **Stateful** | `UploadScreen` | Counter donasi + form validation |

### Layout

| Layout | Digunakan di |
|--------|-------------|
| `Column` | Detail produk, form upload, splash layout |
| `Row` | Rating + harga, profil pengrajin, counter |
| `Stack` | Ikon ❤️ di atas gambar produk (ProductCard & Detail) |
| `GridView` | Daftar produk di HomeScreen |
| `ListView` | Scroll konten detail & form |

### Packages

| Package | Kegunaan |
|---------|----------|
| `google_fonts` | Tipografi Poppins di seluruh app |
| `font_awesome_flutter` | Ikon Bell, Cart, Instagram, WhatsApp |

### Widget Tree

```
MaterialApp
└── Scaffold
    ├── SplashScreen (Stateless)
    │   └── CustomButton → /home
    ├── HomeScreen (Stateful)
    │   ├── AppBar → Bell (notif dialog), Cart (cart dialog)
    │   ├── TextField (search)
    │   ├── Row → CategoryChip × 5 (filter aktif)
    │   ├── SectionTitle
    │   └── SliverGrid → ProductCard (Stack: ilustrasi + ❤️)
    ├── ProductDetailScreen (Stateful)
    │   ├── SliverAppBar → Stack (ilustrasi + ❤️ + CategoryChip)
    │   ├── Row (rating + harga)
    │   ├── SectionTitle × 3
    │   ├── CustomButton "Beli Sekarang" → dialog
    │   └── CustomButton "Hubungi Pengrajin" → bottom sheet
    └── UploadScreen (Stateful)
        ├── Form → TextFormField × 2
        ├── Wrap → CategoryChip (pilih material)
        ├── Row → Counter (- / angka / +) ← setState
        └── CustomButton "Kirim Donasi" → success view
```

---

## 🚀 Cara Menjalankan

### Prasyarat

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.0.0
- [Android Studio](https://developer.android.com/studio) (untuk emulator)
- [VS Code](https://code.visualstudio.com/) + ekstensi Flutter

### Langkah

**1. Clone repository**
```bash
git clone https://github.com/Kiryzsuuu/recyclemate.git
cd recyclemate
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Jalankan emulator Android** dari Android Studio (AVD Manager)

**4. Jalankan aplikasi — cukup double-click:**
```
run.bat
```

Atau manual via terminal CMD:
```cmd
set FLUTTER_PREBUILT_ENGINE_VERSION=425cfb54d01a9472b3e81d9e76fd63a4a44cfbcb
flutter run -d emulator-5554 --android-skip-build-dependency-validation
```

> **Catatan:** Gunakan terminal **CMD** (bukan PowerShell) untuk menghindari error `update_engine_version.ps1`.

---

## 🛠️ Tech Stack

| Teknologi | Versi |
|-----------|-------|
| Flutter | 3.41.6 (stable) |
| Dart | 3.11.4 |
| Android Gradle Plugin | 8.7.0 |
| Gradle | 8.9 |
| Min SDK | Android 5.0 (API 21) |
| Target SDK | Android 17 (API 37) |

---

## 🎨 Ilustrasi Produk

Setiap jenis produk memiliki ilustrasi unik yang digambar menggunakan `CustomPainter` — tanpa asset gambar eksternal:

| Produk | Ilustrasi |
|--------|-----------|
| 🍾 Lampu Botol Kaca | Botol dengan efek glow LED |
| 🌸 Vas Botol Kaca | Vas dengan bunga di atas |
| 🪴 Pot Kayu Palet | Pot kayu dengan tanaman |
| 🪑 Kursi Kayu Palet | Kursi dengan serat kayu |
| 👜 Tas Plastik Anyam | Tas dengan motif anyaman |
| 🛋️ Bantal Kain Perca | Bantal patchwork warna-warni |
| 📚 Rak Pipa PVC | Rak dengan buku mini |
| 🪞 Cermin Kayu Drift | Cermin dengan bingkai driftwood |

---

## 👥 Tim Pengembang

| Role | Tugas |
|------|-------|
| Project Manager & UI Designer | Alur navigasi dan aset visual |
| Frontend Developer (Flutter) | Implementasi widget dan navigasi |
| System Analyst | Flowchart dan widget tree |

---

## 📄 Lisensi

Project ini dibuat untuk keperluan akademik (UTS Mobile Programming).

---

<div align="center">
  <p>Dibuat dengan ❤️ untuk lingkungan Indonesia yang lebih bersih</p>
  <p>♻️ <strong>RecycleMate</strong> — Ubah Sampah Jadi Karya</p>
</div>
