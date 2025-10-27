# API Configuration Setup

## For Developers

Before running the app, you need to configure the API settings:

1. **Copy the template file:**
   ```bash
   cp lib/config/api_config.template.dart lib/config/api_config.dart
   ```

2. **Update `lib/config/api_config.dart` with your values:**
   
   - **Find your computer's IP address:**
     - Windows: Run `ipconfig` in PowerShell, look for "IPv4 Address" under your WiFi adapter
     - Mac/Linux: Run `ifconfig` or `ip addr`
   
   - **Update the baseUrl:**
     - For physical device: `http://YOUR_IP:8000` (e.g., `http://192.168.1.13:8000`)
     - For emulator: `http://10.0.2.2:8000`
   
   - **Update the apiKey:**
     - Must match the API_KEY in your backend's `env.json` or `.env` file

3. **Start the backend server:**
   ```bash
   cd Integrate_detect
   # On Windows:
   start_server_simple.bat
   
   # On Mac/Linux:
   python -m uvicorn app:app --host 0.0.0.0 --port 8000 --reload
   ```

4. **Run the Flutter app:**
   ```bash
   flutter run
   ```

## Important Notes

- ✅ `api_config.template.dart` - Commit this file (template for others)
- ❌ `api_config.dart` - DO NOT commit (contains your actual IP/credentials)
- The actual `api_config.dart` is in `.gitignore` to prevent accidental commits
- Update your IP address if you switch networks (home WiFi, mobile hotspot, etc.)

## Backend Model Files

The ML model files are too large for Git and are excluded:
- `Integrate_detect/models/model.pkl` (173 MB)
- `Integrate_detect/models/snake_bite_best_densenet.pth` (27 MB)

You'll need to train or download these models separately.
