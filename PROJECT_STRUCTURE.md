# 🐍 SnakeBite AI Assistant - Project Structure

AI-powered snakebite detection and treatment aid mobile application.

## 📁 Project Organization

```
snakebite_ai_assistant/
├── lib/                          # Flutter app source code
│   ├── core/                     # Core utilities and constants
│   ├── config/                   # API configuration
│   ├── presentation/             # UI screens and widgets
│   ├── routes/                   # Navigation routes
│   ├── services/                 # API services (backend communication)
│   ├── theme/                    # App theming
│   ├── widgets/                  # Reusable widgets
│   └── main.dart                 # App entry point
│
├── Integrate_detect/             # Backend server (FastAPI)
│   ├── src/                      # Source code
│   │   ├── model_loader.py       # Load ML models and data
│   │   ├── treatment_utils.py    # Treatment recommendation logic
│   │   └── chat_utils.py         # Chat formatting utilities
│   ├── scripts/                  # Utility scripts
│   │   ├── client_example.py     # API client example
│   │   └── test_chat_local.py    # Local chat testing
│   ├── models/                   # ML model files (4+ GB, excluded from git)
│   │   ├── model.pkl             # Snake species classifier (FastAI)
│   │   ├── snake_bite_best_densenet.pth  # Bite detector (DenseNet-121)
│   │   └── mistral-7b-instruct-v0.2.Q4_K_M.gguf  # LLM for chat (optional)
│   ├── archive/                  # Data files
│   │   ├── species.csv           # 135 snake species metadata
│   │   └── snakebite_treatment_aid_100species.csv.xlsx  # 99 treatment protocols
│   ├── app.py                    # FastAPI server
│   ├── start_server.ps1          # Server startup script
│   ├── requirements.txt          # Python dependencies
│   └── .env                      # Environment variables (excluded from git)
│
├── android/                      # Android-specific configuration
├── ios/                          # iOS-specific configuration
├── assets/                       # App assets (images, icons)
├── web/                          # Web platform support
│
├── pubspec.yaml                  # Flutter dependencies
├── env.json                      # Environment configuration
└── README.md                     # Main project documentation
```

## 🚀 Quick Start

### 1. **Backend Server**
```powershell
cd Integrate_detect
.\start_server.ps1
```
Server runs on: `http://192.168.137.1:8000`

### 2. **Mobile App**
```powershell
flutter run -d <device-id>
```

## 🔑 Key Components

### **Mobile App (Flutter)**
- **Camera Integration**: Capture snake photos in real-time
- **Species Identification**: Send photos to backend for AI classification
- **Chat Assistant**: LLM-powered medical guidance
- **Treatment Protocols**: Evidence-based first aid instructions
- **Offline Fallback**: Basic functionality without internet

### **Backend Server (FastAPI)**
- **Species Classification**: FastAI model (135 species)
- **Bite Detection**: DenseNet-121 (venomous vs non-venomous)
- **LLM Chat**: Mistral 7B for intelligent medical advice
- **Treatment Database**: 99 species-specific protocols
- **RESTful API**: JSON responses for mobile integration

## 📊 Data Files

| File | Purpose | Size | Location |
|------|---------|------|----------|
| `model.pkl` | Snake species classifier | 173 MB | `Integrate_detect/models/` |
| `snake_bite_best_densenet.pth` | Bite detection | 27 MB | `Integrate_detect/models/` |
| `mistral-7b-*.gguf` | LLM for chat (optional) | 4 GB | `Integrate_detect/models/` |
| `species.csv` | Species metadata | <1 MB | `Integrate_detect/archive/` |
| `snakebite_treatment_*.xlsx` | Treatment protocols | <1 MB | `Integrate_detect/archive/` |

## 🔧 Configuration

### **API Configuration** (`lib/config/api_config.dart`)
```dart
static const String baseUrl = 'http://192.168.137.1:8000';
static const String apiKey = 'changeme';
```

### **Environment Variables** (`Integrate_detect/.env`)
```env
API_KEY=changeme
ALLOWED_ORIGINS=*
LLM_MODEL_PATH=models/mistral-7b-instruct-v0.2.Q4_K_M.gguf
```

## 📝 API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/health` | GET | Server health check |
| `/predict_species` | POST | Snake species identification |
| `/predict_bite` | POST | Venomous bite detection |
| `/chat` | POST | AI medical assistant |

## 🎯 Development Workflow

1. **Start Backend**: Run `start_server.ps1` in `Integrate_detect/`
2. **Configure Network**: Update `api_config.dart` with your laptop's IP
3. **Connect Phone**: Join phone to laptop's mobile hotspot
4. **Run App**: Execute `flutter run -d <device-id>`
5. **Test Features**: Take photo → Get identification → Chat with AI

## 🚨 Important Notes

- **Server must be running** before using the app (no offline snake detection)
- **Mobile hotspot required** for phone-to-laptop communication
- **Large model files** (~4+ GB) excluded from git - download separately
- **Treatment file** is critical for medical guidance - keep updated

## 📦 Dependencies

### **Flutter** (`pubspec.yaml`)
- `camera`: Photo capture
- `dio`: HTTP API client
- `connectivity_plus`: Network status monitoring
- `fluttertoast`: User notifications

### **Python** (`requirements.txt`)
- `fastapi`: Web framework
- `torch`/`torchvision`: PyTorch for DenseNet
- `fastai`: Snake classifier
- `llama-cpp-python`: LLM inference (optional)
- `pandas`: Data processing

## 🔒 Security

**Current Setup (Development)**:
- API Key: `changeme` (hardcoded)
- CORS: `*` (allows all origins)
- No authentication or rate limiting

**For Production**:
- Use secure API keys
- Restrict CORS to specific origins
- Add user authentication
- Implement rate limiting
- Use HTTPS instead of HTTP

## 📄 License

AI-Based SnakeBite Detection & Treatment Aid

---

**Repository**: AI_Based_SnakeBite_Detection_TreatmentAid  
**Platform**: Flutter (Mobile) + FastAPI (Backend)  
**AI Models**: FastAI, DenseNet-121, Mistral 7B
