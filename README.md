# 🐍 SnakeBite AI Assistant# Flutter



AI-powered mobile application for snake species identification and emergency treatment guidance.A modern Flutter-based mobile application utilizing the latest mobile development technologies and tools for building responsive cross-platform applications.



## 🎯 Features## 📋 Prerequisites



- **📸 Snake Identification**: AI-based species classification (135 species)- Flutter SDK (^3.29.2)

- **🩸 Bite Detection**: Determine if bite is venomous- Dart SDK

- **💬 AI Medical Assistant**: LLM-powered chat for emergency guidance- Android Studio / VS Code with Flutter extensions

- **📋 Treatment Protocols**: Evidence-based first aid for 99 species- Android SDK / Xcode (for iOS development)

- **🏥 Emergency Services**: Quick access to nearby hospitals

- **📱 Offline Fallback**: Basic functionality without internet## 🛠️ Installation



## 🏗️ Architecture1. Install dependencies:

```bash

### Mobile App (Flutter)flutter pub get

- Cross-platform iOS & Android```

- Real-time camera integration

- RESTful API communication2. Run the application:

- Offline mode support```bash

flutter run

### Backend Server (FastAPI)```

- **Species Classifier**: FastAI model (173 MB)

- **Bite Detector**: DenseNet-121 PyTorch (27 MB)## 📁 Project Structure

- **LLM Chat**: Mistral 7B (4 GB, optional)

- **Data**: 135 species + 99 treatment protocols```

flutter_app/

## 🚀 Quick Start├── android/            # Android-specific configuration

├── ios/                # iOS-specific configuration

### 1. Start Backend Server├── lib/

```powershell│   ├── core/           # Core utilities and services

cd Integrate_detect│   │   └── utils/      # Utility classes

.\start_server.ps1│   ├── presentation/   # UI screens and widgets

```│   │   └── splash_screen/ # Splash screen implementation

│   ├── routes/         # Application routing

Server runs on: `http://192.168.137.1:8000`│   ├── theme/          # Theme configuration

│   ├── widgets/        # Reusable UI components

### 2. Configure Mobile App│   └── main.dart       # Application entry point

Edit `lib/config/api_config.dart`:├── assets/             # Static assets (images, fonts, etc.)

```dart├── pubspec.yaml        # Project dependencies and configuration

static const String baseUrl = 'http://YOUR_IP:8000';└── README.md           # Project documentation

``````



### 3. Run Mobile App## 🧩 Adding Routes

```powershell

flutter run -d <device-id>To add new routes to the application, update the `lib/routes/app_routes.dart` file:

```

```dart

## 📁 Project Structureimport 'package:flutter/material.dart';

import 'package:package_name/presentation/home_screen/home_screen.dart';

See [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) for detailed file organization.

class AppRoutes {

```  static const String initial = '/';

snakebite_ai_assistant/  static const String home = '/home';

├── lib/                    # Flutter app source

├── Integrate_detect/       # Backend server  static Map<String, WidgetBuilder> routes = {

│   ├── app.py             # FastAPI server    initial: (context) => const SplashScreen(),

│   ├── src/               # Python modules    home: (context) => const HomeScreen(),

│   ├── models/            # ML models (excluded from git)    // Add more routes as needed

│   ├── archive/           # Data files  }

│   └── start_server.ps1   # Server startup}

├── android/               # Android config```

├── ios/                   # iOS config

├── assets/                # App assets## 🎨 Theming

└── web/                   # Web support

```This project includes a comprehensive theming system with both light and dark themes:



## 📊 Data Files```dart

// Access the current theme

| File | Purpose | Size | Required |ThemeData theme = Theme.of(context);

|------|---------|------|----------|

| `model.pkl` | Snake species classifier | 173 MB | ✅ Yes |// Use theme colors

| `snake_bite_best_densenet.pth` | Bite detection | 27 MB | ✅ Yes |Color primaryColor = theme.colorScheme.primary;

| `species.csv` | Species metadata | <1 MB | ✅ Yes |```

| `snakebite_treatment_*.xlsx` | Treatment protocols | <1 MB | ✅ Yes |

| `mistral-7b-*.gguf` | LLM for chat | 4 GB | ⚠️ Optional |The theme configuration includes:

- Color schemes for light and dark modes

## 🔧 Requirements- Typography styles

- Button themes

### Mobile App- Input decoration themes

- Flutter SDK 3.0+- Card and dialog themes

- Android Studio / Xcode

- Physical device or emulator## 📱 Responsive Design



### BackendThe app is built with responsive design using the Sizer package:

- Python 3.11+

- PyTorch```dart

- FastAPI// Example of responsive sizing

- 8+ GB RAM (for LLM)Container(

  width: 50.w, // 50% of screen width

## 🌐 API Endpoints  height: 20.h, // 20% of screen height

  child: Text('Responsive Container'),

| Endpoint | Method | Purpose |)

|----------|--------|---------|```

| `/health` | GET | Server status |## 📦 Deployment

| `/predict_species` | POST | Species identification |

| `/predict_bite` | POST | Venomous bite detection |Build the application for production:

| `/chat` | POST | AI medical assistant |

```bash

## 🔒 Security Notice# For Android

flutter build apk --release

**Development Setup** (Current):

- API Key: `changeme`# For iOS

- CORS: `*` (all origins)flutter build ios --release

- No authentication```



**For Production**:
- Use secure API keys
- Restrict CORS origins
- Add user authentication
- Implement rate limiting
- Use HTTPS

## 🛠️ Development

### Backend
```powershell
cd Integrate_detect
pip install -r requirements.txt
python -m uvicorn app:app --reload --host 0.0.0.0 --port 8000
```

### Mobile App
```powershell
flutter pub get
flutter run
```

### Hot Reload
- Backend: Auto-reloads on file changes
- Mobile: Press `r` in terminal

## 📝 Configuration

### Backend (`Integrate_detect/.env`)
```env
API_KEY=changeme
ALLOWED_ORIGINS=*
LLM_MODEL_PATH=models/mistral-7b-instruct-v0.2.Q4_K_M.gguf
```

### Mobile (`lib/config/api_config.dart`)
```dart
class ApiConfig {
  static const String baseUrl = 'http://192.168.137.1:8000';
  static const String apiKey = 'changeme';
}
```

## 🚨 Important Notes

- ⚠️ **Server Required**: Snake detection needs backend server running
- 📡 **Network**: Phone must connect to laptop's mobile hotspot
- 💾 **Large Files**: ML models (~4+ GB) excluded from git
- 🏥 **Medical Disclaimer**: For emergency reference only - seek professional medical help

## 📄 License

AI-Based SnakeBite Detection & Treatment Aid

---

**Platform**: Flutter + FastAPI  
**AI Models**: FastAI, DenseNet-121, Mistral 7B  
**Repository**: AI_Based_SnakeBite_Detection_TreatmentAid
