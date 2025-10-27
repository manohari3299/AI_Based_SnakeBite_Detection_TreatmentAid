// API Configuration Template
// Copy this file to api_config.dart and update with your values
// DO NOT commit api_config.dart to git!

class ApiConfig {
  // IMPORTANT: Replace with your computer's IP address
  // Find it using: ipconfig (Windows) or ifconfig (Mac/Linux)
  // For emulator: use 'http://10.0.2.2:8000'
  // For physical device: use 'http://YOUR_COMPUTER_IP:8000' (e.g., 'http://192.168.1.13:8000')
  static const String baseUrl = 'http://YOUR_COMPUTER_IP:8000';
  
  // Replace with your backend API key (must match backend env.json or .env)
  static const String apiKey = 'your_api_key_here';
}
