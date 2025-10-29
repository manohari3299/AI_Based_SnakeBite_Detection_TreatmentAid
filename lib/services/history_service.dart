import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const String _historyKey = 'identification_history';
  static final HistoryService _instance = HistoryService._internal();
  
  factory HistoryService() => _instance;
  
  HistoryService._internal();

  // Save identification to history
  Future<void> saveIdentification(Map<String, dynamic> identification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> history = await getHistory();
      
      // Add new identification at the beginning
      history.insert(0, {
        ...identification,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      // Keep only last 100 identifications
      if (history.length > 100) {
        history = history.sublist(0, 100);
      }
      
      // Save to shared preferences
      final jsonString = jsonEncode(history);
      await prefs.setString(_historyKey, jsonString);
    } catch (e) {
      print('Error saving to history: $e');
    }
  }

  // Get all history
  Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_historyKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('Error loading history: $e');
      return [];
    }
  }

  // Delete a specific identification
  Future<void> deleteIdentification(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> history = await getHistory();
      
      history.removeWhere((item) => item['id'] == id);
      
      final jsonString = jsonEncode(history);
      await prefs.setString(_historyKey, jsonString);
    } catch (e) {
      print('Error deleting from history: $e');
    }
  }

  // Delete multiple identifications
  Future<void> deleteMultiple(Set<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> history = await getHistory();
      
      history.removeWhere((item) => ids.contains(item['id']));
      
      final jsonString = jsonEncode(history);
      await prefs.setString(_historyKey, jsonString);
    } catch (e) {
      print('Error deleting multiple from history: $e');
    }
  }

  // Clear all history
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      print('Error clearing history: $e');
    }
  }

  // Get history count
  Future<int> getHistoryCount() async {
    final history = await getHistory();
    return history.length;
  }
}
