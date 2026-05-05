<p align="center">
  <img src="https://raw.githubusercontent.com/aminechaib/apisvflutter/main/business-card-icon.png" width="200" alt="ACScanner">
  <h1>ACScanner - Business Card Mobile App</h1>
  <img src="https://img.shields.io/badge/Flutter-3.24-blue.svg?style=for-the-badge" alt="Flutter">
  <img src="https://img.shields.io/badge/State-Provider-green.svg?style=for-the-badge" alt="Provider">
  <img src="https://img.shields.io/badge/OCR-MLKit-orange.svg?style=for-the-badge" alt="Google MLKit">
  <img src="https://img.shields.io/badge/Backend-Laravel_API-purple.svg?style=for-the-badge" alt="Laravel Backend">
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/aminechaib/apisvflutter/main/ag_logo_icon_white.svg" width="30" alt="Algeria"> 
  <strong><a href="https://github.com/aminechaib">Amine Chaib</a></strong><br>
  🇩🇿 DZ Fullstack Developer
</p>

## 📱 Overview

**ACScanner** is a cross-platform Flutter mobile app for scanning business cards. 

**Seamless Integration**:
- 📸 Camera/Gallery → Google MLKit OCR (local text extraction)
- 🚀 Submit to [Laravel OCR API Backend](../apisv) for AI structuring (Mistral)
- 📋 List/Edit/Delete extracted contacts
- 🔄 Real-time sync with backend

**Platforms**: Android • iOS • Web • Windows

## ✨ Features
- ✅ Image picker + on-device OCR (Google MLKit)
- ✅ Backend upload: `/api/process-card` (image/text)
- ✅ Contact CRUD via Provider state management
- ✅ Custom UI: Contact list/detail/edit screens
- ✅ Error handling (network/offline)
- ✅ Branded splash/icons (AG logo)

## 🏗 Architecture
```
Camera/MLKit OCR → ApiService (http) → Laravel Backend
                           ↓
Provider (ChangeNotifier) → UI Screens (List/Detail/Edit)
```

**Backend Repo**: [../apisv](https://github.com/aminechaib/apisv) (Laravel 12 API)

## 📱 Screenshots
![Demo](https://raw.githubusercontent.com/aminechaib/apisvflutter/main/flutter_01.png)

## 🚀 Quick Start

1. **Clone & Setup**
   ```bash
   cd ../apisvflutter
   flutter pub get
   ```

2. **Backend** (sibling dir)
   ```bash
   cd ../apisv  # Laravel API
   php artisan serve  # http://localhost:8000
   php artisan queue:work
   ```

3. **Config API** (lib/api/api_service.dart)
   ```dart
   // Local dev
   const _baseUrl = 'http://192.168.100.11/';
   // or Production: 'https://card.sarlpro.com'
   ```

4. **Run**
   ```bash
   flutter run
   ```

## 🛠 Tech Stack
| Frontend | State | API | OCR | Backend |
|----------|-------|-----|-----|---------|
| Flutter 3+ | Provider | http | MLKit Text | Laravel 12 API |

**Dependencies** (pubspec.yaml): image_picker, provider, http, intl, google_mlkit_text_recognition

## 📱 Screens
- **ContactListScreen**: Paginated list from `/api/contacts`
- **ContactDetailScreen**: View contact + image
- **ContactEditScreen**: Update via PUT `/api/contacts/{id}`

## 🤝 Backend API
Links to Laravel OCR API:
- `GET /api/contacts` → List validated
- `POST /api/process-card` → Upload image/text
- `PUT /api/contacts/{id}` → Edit
- `DELETE /api/contacts/{id}`

Full docs: [Backend README](https://github.com/aminechaib/apisv/blob/main/README.md)

## 🔧 Build & Release
```bash
flutter build apk --release
flutter build ios --release
flutter build web
flutter build windows
```

## 🤝 Contributing
- `flutter analyze`
- `flutter test`
- PR welcome!

## 📄 License
MIT © 2024 Amine Chaib 🇩🇿

<div align="center">
  <img src="https://komarev.com/ghpvc/?username=aminechaib&label=Profile%20views&color=0e75b6&style=flat">
</div>

**⭐ Made with Flutter & Laravel**
