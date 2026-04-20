# MAISONLUXE Flutter App

Aplikasi mobile luxury e-commerce berbasis Flutter yang terhubung dengan REST API MAISONLUXE (UTS).

## Fitur

### Wajib
- ✅ Flutter + REST API backend sendiri (MAISONLUXE)
- ✅ Autentikasi JWT (login, register, simpan token, kirim di setiap request)
- ✅ Provider state management
- ✅ Three-state UI: Loading (shimmer), Error (retry), Data (grid produk)
- ✅ Navigasi multi-halaman

### Tambahan
- ✅ CRUD lengkap (tambah, edit, hapus produk)
- ✅ Pencarian produk real-time
- ✅ Filter berdasarkan kategori
- ✅ UI/UX luxury (Google Fonts, gold accent, shimmer loading)
- ✅ Pull-to-refresh
- ✅ Auto-login dari token tersimpan
- ✅ Splash screen

## Arsitektur

```
lib/
├── main.dart
├── theme.dart
├── models/
│   ├── product.dart
│   └── user.dart
├── services/
│   └── api_service.dart      ← HTTP client + JWT header
├── providers/
│   ├── auth_provider.dart    ← AuthStatus: loading/authenticated/error
│   └── product_provider.dart ← ProductStatus: loading/loaded/error
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   ├── product_detail_screen.dart
│   ├── product_form_screen.dart
│   └── profile_screen.dart
└── widgets/
    ├── product_card.dart
    └── shimmer_card.dart
```

## Setup & Menjalankan

### 1. Jalankan Backend (MAISONLUXE)
```bash
cd backend
node index.js
# Server berjalan di http://localhost:5000
```

### 2. Sesuaikan Base URL
Edit `lib/services/api_service.dart`:

```dart
// Untuk emulator Android:
static const String baseUrl = 'http://10.0.2.2:5000';

// Untuk device fisik (cek IP laptop dengan ipconfig/ifconfig):
static const String baseUrl = 'http://192.168.x.x:5000';
```

### 3. Install Dependencies & Jalankan Flutter
```bash
flutter pub get
flutter run
```

## Endpoint API yang Digunakan

| Method | Endpoint | Auth | Fungsi |
|--------|----------|------|--------|
| POST | /api/auth/login | - | Login, dapat accessToken |
| POST | /api/auth/register | - | Registrasi akun baru |
| GET | /api/auth/profile | Bearer | Data profil user |
| POST | /api/auth/logout | - | Logout |
| GET | /api/products | Bearer | Daftar semua produk |
| GET | /api/products/:id | Bearer | Detail produk |
| POST | /api/products | Bearer | Tambah produk |
| PUT | /api/products/:id | Bearer | Edit produk |
| DELETE | /api/products/:id | Bearer | Hapus produk |

## Dependencies

```yaml
provider: ^6.1.2          # State management
http: ^1.2.1               # HTTP requests
shared_preferences: ^2.2.3 # Simpan JWT token
cached_network_image: ^3.3.1
google_fonts: ^6.2.1       # Cormorant Garamond + Lato
shimmer: ^3.0.0            # Loading skeleton
intl: ^0.19.0              # Format harga Rupiah
```

## Nama: [Nama Lengkap]
## NIM: 247006111016
## Kelas: A
## Mata Kuliah: Pengembangan Aplikasi Berbasis Platform
