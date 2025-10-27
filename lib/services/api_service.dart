import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  ApiService._internal();

  late final Dio _dio;
  
  // Configuration is now loaded from api_config.dart
  // See lib/config/api_config.template.dart for setup instructions
  static String get _baseUrl => ApiConfig.baseUrl;
  static String get _apiKey => ApiConfig.apiKey;
  
  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_apiKey.isNotEmpty) 'X-API-KEY': _apiKey,
        },
      ),
    );

    // Add logging interceptor for debugging
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }
  }

  /// Health check endpoint
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Predict snake species from image
  Future<Map<String, dynamic>> predictSpecies(
    File imageFile, {
    String? userId,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/predict_species',
        data: formData,
        options: Options(
          headers: {
            if (userId != null) 'user_id': userId,
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Predict if bite is venomous
  Future<Map<String, dynamic>> predictBite(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/predict_bite',
        data: formData,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Chat with AI assistant
  Future<Map<String, dynamic>> chat({
    required String message,
    String? userId,
    String? conversationId,
    String? speciesName,
    String? region,
    String? symptoms,
  }) async {
    try {
      final response = await _dio.post(
        '/chat',
        data: {
          'message': message,
          if (userId != null) 'user_id': userId,
          if (conversationId != null) 'conversation_id': conversationId,
          if (speciesName != null) 'species_name': speciesName,
          if (region != null) 'region': region,
          if (symptoms != null) 'symptoms': symptoms,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors
  String _handleError(DioException error) {
    if (error.response != null) {
      // Server responded with error
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;
      
      if (statusCode == 401) {
        return 'Authentication failed. Please check API key.';
      } else if (statusCode == 503) {
        return 'Service unavailable. Models may not be loaded.';
      } else if (data is Map && data.containsKey('detail')) {
        return data['detail'].toString();
      }
      return 'Server error: $statusCode';
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Please ensure backend is running.';
    }
    return 'Network error: ${error.message}';
  }

  /// Update base URL (useful for switching between emulator and physical device)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }
}
