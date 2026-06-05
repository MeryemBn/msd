import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiClient {
  static const String baseUrl = 'http://192.168.1.3:8080';

  final Dio dio;
  
  // Configuration renforcée pour Android (évite les pertes de clés)
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  
  bool _isRefreshing = false;
  final List<Map<String, dynamic>> _retryQueue = [];

  ApiClient()
      : dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 13),
      contentType: 'application/json',
    ),
  ) {

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (!options.path.contains('/api/auth/')) {
          final token = await _storage.read(key: 'access_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401 && !e.requestOptions.path.contains('/api/auth/')) {

          if (!_isRefreshing) {
            _isRefreshing = true;

            try {
              final refreshToken = await _storage.read(key: 'refresh_token');
              
              if (refreshToken == null || refreshToken.isEmpty) {
                _isRefreshing = false;
                debugPrint("⚠️ Aucun refresh token, redirection login...");
                return handler.next(e);
              }

              debugPrint("🔄 Tentative de rafraîchissement du token...");
              
              final response = await Dio().post(
                '$baseUrl/api/auth/refresh',
                data: {'refreshToken': refreshToken},
              );

              final newAccessToken = response.data['accessToken'];
              final newRefreshToken = response.data['refreshToken'];

              if (newAccessToken != null) {
                await _storage.write(key: 'access_token', value: newAccessToken);
                if (newRefreshToken != null) {
                  await _storage.write(key: 'refresh_token', value: newRefreshToken);
                }

                _isRefreshing = false;

                // Rejouer la requête
                e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                final retryResponse = await dio.fetch(e.requestOptions);

                for (var request in _retryQueue) {
                  request['options'].headers['Authorization'] = 'Bearer $newAccessToken';
                  final res = await dio.fetch(request['options']);
                  request['handler'].resolve(res);
                }
                _retryQueue.clear();

                return handler.resolve(retryResponse);
              } else {
                throw Exception('Réponse refresh invalide');
              }
            } catch (err) {
              debugPrint("❌ Échec rafraîchissement : $err");
              _isRefreshing = false;
              _retryQueue.clear();
              
              // On ne vide tout que si le token est vraiment mort (401 ou 400)
              if (err is DioException && (err.response?.statusCode == 401 || err.response?.statusCode == 400)) {
                await _storage.deleteAll();
              }
              return handler.next(e);
            }
          } else {
            _retryQueue.add({
              'options': e.requestOptions,
              'handler': handler,
            });
            return;
          }
        }
        return handler.next(e);
      },
    ));

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint(obj.toString()),
    ));
  }
}

final apiClient = ApiClient();
final apiClientProvider = Provider<ApiClient>((ref) => apiClient);
