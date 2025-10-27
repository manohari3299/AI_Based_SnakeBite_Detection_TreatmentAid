# 🚀 How to Run SnakeBite AI on Your Phone

This guide will help you run the SnakeBite AI mobile app on your connected Android/iOS device.

## 📋 Prerequisites

1. **USB Debugging Enabled** (Android)
   - Go to Settings → About Phone → Tap "Build Number" 7 times
   - Go to Settings → Developer Options → Enable "USB Debugging"

2. **Backend Server Running**
   - The Python FastAPI backend must be running on your laptop
   - Models must be downloaded and placed in correct directories

## 🔧 Step 1: Start the Backend Server

### Option A: Using PowerShell Script (Recommended)
```powershell
cd c:\Users\aryan\Desktop\snakebite_ai_assistant\Integrate_detect
.\start_backend.ps1
```

### Option B: Manual Setup
```powershell
cd c:\Users\aryan\Desktop\snakebite_ai_assistant\Integrate_detect

# Create and activate virtual environment (first time only)
python -m venv .venv
.\.venv\Scripts\Activate.ps1

# Install dependencies (first time only)
pip install --upgrade pip
pip install -r requirements.txt

# Start server
uvicorn app:app --host 0.0.0.0 --port 8000 --reload
```

## 🌐 Step 2: Configure Network Settings

### Find Your Computer's IP Address
```powershell
ipconfig
```
Look for "IPv4 Address" under your active network adapter (e.g., `192.168.1.100`)

### Update Flutter App Configuration

**File:** `lib/services/api_service.dart`

**Line 18-19:** Change the base URL:

```dart
// FOR ANDROID EMULATOR:
static const String _baseUrl = 'http://10.0.2.2:8000';

// FOR PHYSICAL DEVICE (Replace with YOUR laptop's IP):
static const String _baseUrl = 'http://192.168.1.100:8000';  // ← Your IP here!
```

**Make sure your phone and laptop are on the same WiFi network!**

## 📱 Step 3: Run the Flutter App

### Check Connected Device
```powershell
cd c:\Users\aryan\Desktop\snakebite_ai_assistant
flutter devices
```

You should see your phone listed. Example:
```
RMX2001 (mobile) • ABCD1234 • android-arm64 • Android 11 (API 30)
```

### Run on Physical Device
```powershell
flutter run
```

Or select your device in VS Code:
1. Press `Ctrl+Shift+P`
2. Type "Flutter: Select Device"
3. Choose your connected phone
4. Press `F5` or click "Run" → "Start Debugging"

## 🔍 Step 4: Test the Integration

### 1. Check Backend Health
Open browser on your laptop: `http://localhost:8000/health`
Should return: `{"status":"ok"}`

### 2. Test Mobile App Features

#### A. Species Identification
1. Open app → Tap "Take Photo" or "EMERGENCY" button
2. Take a photo of a snake (or any image for testing)
3. Wait for analysis (loading spinner will show)
4. View results with species name, confidence, and metadata

#### B. Chat Assistant
1. Navigate to Chat tab or "Chat Assistant"
2. Type a question: "What are venomous snake symptoms?"
3. AI will respond using the LLM from your backend
4. Try quick actions: "Identify Symptoms", "Find Hospital", etc.

## 🐛 Troubleshooting

### Problem: "Cannot connect to server"

**Solution 1:** Check network connectivity
```powershell
# On your laptop, verify server is running
curl http://localhost:8000/health

# From your phone's browser, navigate to:
http://YOUR_LAPTOP_IP:8000/health
```

**Solution 2:** Firewall settings
- Windows: Allow Python through Windows Firewall
- Settings → Windows Security → Firewall → Allow an app

**Solution 3:** Verify same network
- Laptop and phone must be on same WiFi
- Corporate networks may block device-to-device communication

### Problem: "Service unavailable. Models may not be loaded."

**Solution:** Ensure model files exist in correct paths:
```
Integrate_detect/
├── models/
│   ├── model.pkl                              ← Snake classifier
│   ├── snake_bite_best_densenet.pth          ← Bite classifier
│   └── mistral-7b-instruct-v0.2.Q2_K.gguf   ← LLM (optional)
├── archive/
│   ├── species.csv                            ← Species metadata
│   └── snakebite_treatment_aid_100species.csv.xlsx  ← Treatment data
```

### Problem: Models taking too long to load

**Temporary Solution:** Skip LLM during testing
```powershell
$env:SKIP_MODEL_LOADING = "1"
uvicorn app:app --host 0.0.0.0 --port 8000 --reload
```

Note: This will disable AI chat, but species identification will still work.

### Problem: App builds but crashes on startup

**Solution:** Check Flutter dependencies
```powershell
flutter clean
flutter pub get
flutter run
```

## 📊 Verify Integration is Working

### ✅ Backend Indicators:
- Terminal shows: `INFO: Application startup complete.`
- No errors about missing model files
- API responds to `/health` endpoint

### ✅ Mobile App Indicators:
- Status banner shows "Online" (green indicator)
- Taking photo shows "Analyzing image..." loading
- Chat shows "AI Medical Assistant (LLM)" as source
- Results page displays species information from API

## 🎯 Hot Reload During Development

### Backend (Python):
- Server auto-reloads on file changes (thanks to `--reload` flag)
- Just save changes to `.py` files

### Frontend (Flutter):
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

## 📝 API Endpoints Being Used

| Endpoint | Purpose | Used By |
|----------|---------|---------|
| `GET /health` | Check server status | App initialization |
| `POST /predict_species` | Identify snake species | Camera capture → Results |
| `POST /predict_bite` | Detect venomous bite | Camera capture (optional) |
| `POST /chat` | AI assistant queries | Chat screen |

## 🔒 Security Note

Current setup uses:
- API Key: `changeme` (update in production!)
- CORS: `*` (allows all origins - restrict for production)

For production deployment, update:
- `.env` file with secure API key
- CORS settings to specific origins
- Add rate limiting and authentication

## 📞 Need Help?

Common commands reference:
```powershell
# Check Flutter doctor
flutter doctor

# List devices
flutter devices

# Check logs (while app is running)
flutter logs

# Build for release
flutter build apk  # Android
flutter build ios  # iOS

# Backend logs
# They appear in the terminal where uvicorn is running
```

---

**Happy Testing! 🐍📱**
