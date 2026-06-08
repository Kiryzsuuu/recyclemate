# RecycleMate 🌿

**Platform Marketplace Sosial untuk Barang Upcycle**

Hubungkan pengrajin kreatif dengan kolektor barang daur ulang di seluruh Indonesia.

---

## Tech Stack

| Layer | Teknologi |
|-------|-----------|
| Mobile App | Flutter (Dart) |
| Backend API | Node.js + Express |
| Database | MongoDB Atlas |
| Email | Nodemailer + Gmail SMTP |
| Auth | JWT (JSON Web Token) |

---

## Cara Menjalankan

### 1. Start Backend

```bash
cd backend
npm install      # hanya pertama kali
node server.js   # atau klik start-backend.bat
```

Backend akan berjalan di: `http://localhost:3000`

### 2. Jalankan Flutter

```bash
flutter pub get  # hanya pertama kali
flutter run
```

> **Note untuk device fisik:** Ubah `baseUrl` di `lib/services/api_service.dart` dan `lib/services/auth_service.dart` dari `10.0.2.2` ke IP lokal komputer kamu (misal: `192.168.1.5`).

---

## Fitur

### 🛍️ Marketplace
- Browse produk upcycle (dari MongoDB — bukan dummy data)
- Search & filter berdasarkan material (Plastik, Kayu, Kaca, Kain, Logam)
- Detail produk dengan info pengrajin

### 🔐 Autentikasi
- Register akun baru (Pembeli / Pengrajin)
- Login dengan JWT token
- Browse tanpa login (tapi beli/donasi perlu login)

### 👤 My Profile
- Edit profil (nama, kota, telepon, bio)
- Riwayat pesanan + status
- Riwayat donasi + status
- Pengajuan refund

### 🛠️ Kelola Produk (Pengrajin)
- Tambah produk baru
- Edit produk
- Hapus produk

### 🎁 Donasi Barang
- Upload barang bekas untuk didonasikan ke pengrajin

### 📧 Email Notifikasi (Otomatis)
- Welcome email saat register
- Konfirmasi pesanan (ke buyer + seller)
- Konfirmasi donasi
- Notifikasi refund request
- Update status pesanan

---

## API Endpoints

```
POST   /api/auth/register        # Register
POST   /api/auth/login           # Login
GET    /api/auth/profile         # Get profile (auth)
PUT    /api/auth/profile         # Update profile (auth)
PUT    /api/auth/change-password # Change password (auth)

GET    /api/products             # List produk (public)
GET    /api/products/:id         # Detail produk (public)
POST   /api/products             # Buat produk (auth, crafter)
PUT    /api/products/:id         # Edit produk (auth, owner)
DELETE /api/products/:id         # Hapus produk (auth, owner)
GET    /api/products/my/products # Produkku (auth)

POST   /api/orders               # Buat pesanan (auth)
GET    /api/orders               # Pesananku (auth)
PUT    /api/orders/:id/status    # Update status (auth)
POST   /api/orders/:id/refund    # Ajukan refund (auth)

POST   /api/donations            # Kirim donasi (auth)
GET    /api/donations            # Donasiku (auth)
PUT    /api/donations/:id        # Update donasi (auth)
DELETE /api/donations/:id        # Batal donasi (auth)
```

---

## Struktur Proyek

```
recyclemate/
├── backend/              # Node.js API
│   ├── models/           # MongoDB schemas
│   ├── routes/           # API routes
│   ├── middleware/       # JWT auth
│   ├── utils/            # Mailer
│   ├── .env              # Config (jangan di-commit!)
│   └── server.js         # Entry point
├── lib/                  # Flutter app
│   ├── models/           # Dart data models
│   ├── services/         # API & Auth services
│   └── screens/          # UI screens
└── start-backend.bat     # Script startup
```
