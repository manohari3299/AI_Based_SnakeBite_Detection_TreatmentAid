# 📱 Connecting Your Android Phone for Flutter Development

Your phone is currently not detected by Flutter. Here's how to fix it:

## ✅ Step 1: Enable Developer Options

1. **Open Settings** on your Android phone
2. **Go to "About Phone"** (or "About Device")
3. **Find "Build Number"** 
4. **Tap "Build Number" 7 times** rapidly
   - You'll see a message: "You are now a developer!"

## ✅ Step 2: Enable USB Debugging

1. **Go back to Settings**
2. **Open "Developer Options"** (usually in System or Advanced settings)
3. **Enable "USB Debugging"**
4. **Also enable:**
   - "Stay awake" (keeps screen on while charging)
   - "Install via USB" (allows app installation from computer)

## ✅ Step 3: Connect Phone to Computer

1. **Use a good USB cable** (must support data transfer, not just charging)
2. **Connect phone to computer**
3. **On your phone, you'll see a popup:**
   - "Allow USB debugging?"
   - **Check "Always allow from this computer"**
   - **Tap "Allow"**

## ✅ Step 4: Verify Connection

Run this command in PowerShell:
```powershell
cd c:\Users\aryan\Desktop\snakebite_ai_assistant
flutter devices
```

You should now see your phone listed like:
```
RMX2001 (mobile) • ABCD1234 • android-arm64 • Android 11 (API 30)
```

## 🔧 Troubleshooting: Phone Still Not Detected

### Option A: Install ADB Drivers (Most Common Fix)

1. **Download Google USB Driver:**
   - Visit: https://developer.android.com/studio/run/win-usb
   - Or install via Android Studio

2. **Update Driver in Device Manager:**
   - Open Device Manager (Win+X → Device Manager)
   - Look for your phone (might show as "Unknown Device" or "ADB Interface")
   - Right-click → Update Driver → Browse → Select Google USB Driver folder

### Option B: Try Different USB Port

- Try USB 2.0 ports instead of USB 3.0
- Some USB 3.0 ports have connectivity issues

### Option C: Change USB Mode on Phone

When you connect your phone, check the notification:
1. Tap the "USB" notification
2. Select "File Transfer" or "MTP" mode
3. (NOT "Charging only")

### Option D: Restart ADB

```powershell
cd c:\Users\aryan\Desktop\snakebite_ai_assistant
flutter doctor
adb devices
adb kill-server
adb start-server
adb devices
```

## 🪟 Alternative: Run on Windows Desktop (Quick Testing)

While you troubleshoot the phone connection, you can test the app on Windows:

```powershell
cd c:\Users\aryan\Desktop\snakebite_ai_assistant
flutter run -d windows
```

**Note:** Camera features work differently on desktop, but you can test:
- Gallery/file picker functionality
- API integration with backend
- Chat assistant
- UI layout and navigation

## 📋 Quick Checklist

- [ ] Developer Options enabled
- [ ] USB Debugging enabled
- [ ] USB cable supports data transfer
- [ ] "Allow USB debugging" popup accepted on phone
- [ ] Google USB Drivers installed (if needed)
- [ ] Phone is in "File Transfer" mode
- [ ] ADB recognizes device (`adb devices`)
- [ ] Flutter detects device (`flutter devices`)

## 💡 Pro Tips

1. **Keep phone unlocked** during first connection
2. **Some phones require OEM-specific drivers** (Samsung, Xiaomi, etc.)
3. **Check manufacturer website** for specific USB drivers
4. **Wireless debugging** (Android 11+):
   - Enable "Wireless debugging" in Developer Options
   - Follow on-screen pairing instructions
   - Run: `adb pair <IP>:<PORT>`

## 🆘 Still Having Issues?

Check Flutter doctor status:
```powershell
flutter doctor -v
```

Look for issues in "Android toolchain" section.

---

**Once your phone is connected, proceed with the integration steps in `RUN_MOBILE_APP.md`**
