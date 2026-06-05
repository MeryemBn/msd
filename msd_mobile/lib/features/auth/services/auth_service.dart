import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';
import '../models/auth_user.dart';

class AuthService {
  final Dio _dio = apiClient.dio;
  
  // Utilisation de la même configuration que ApiClient pour la cohérence
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  Future<TokenResponse> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: LoginRequest(username: username, password: password).toJson(),
      );

      if (response.data is! Map<String, dynamic>) {
        throw Exception('Format de réponse invalide');
      }

      final tokenResponse = TokenResponse.fromJson(response.data);
      await _saveTokens(tokenResponse);

      return tokenResponse;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      throw Exception('Erreur inattendue : ${e.toString()}');
    }
  }

  Future<TokenResponse> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('No refresh token available');
      }

      final response = await _dio.post(
        '/api/auth/refresh',
        data: RefreshRequest(refreshToken: refreshToken).toJson(),
      );

      final tokenResponse = TokenResponse.fromJson(response.data);
      await _saveTokens(tokenResponse);
      return tokenResponse;
    } catch (e) {
      await logout();
      rethrow;
    }
  }

  Future<void> _saveTokens(TokenResponse tokenResponse) async {
    await _storage.write(key: 'access_token', value: tokenResponse.accessToken);
    await _storage.write(key: 'refresh_token', value: tokenResponse.refreshToken);
  }

  Future<void> signup(SignupRequest request) async {
    try {
      await _dio.post('/api/auth/signup', data: request.toJson());
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post('/api/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  void _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      final statusCode = e.response?.statusCode;
      if (data is Map) {
        final message = data['message'] ?? data['error'] ?? 'Une erreur est survenue';
        throw Exception(message);
      } else if (data is String && data.isNotEmpty) {
        throw Exception(data);
      } else {
        throw Exception('Erreur $statusCode');
      }
    } else {
      throw Exception('Impossible de contacter le serveur. Vérifiez votre connexion.');
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }
}

final authService = AuthService();
