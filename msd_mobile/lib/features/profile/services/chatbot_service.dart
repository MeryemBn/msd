import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class ChatbotService {
  final ApiClient _apiClient;

  ChatbotService(this._apiClient);

  /// Demande une réponse au chatbot (Non-streaming pour plus de stabilité)
  Future<Map<String, dynamic>> askChatbot(String message, String language) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/chatbot/ask',
        data: {
          'message': message,
          'language': language,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 45),
          connectTimeout: const Duration(seconds: 15),
        ),
      );

      if (response.data != null && response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }
      throw Exception('Format de réponse invalide');
    } on DioException catch (e) {
      print('Chatbot DioException: ${e.type} - ${e.message}');
      throw Exception(e.response?.data['error'] ?? 'Erreur lors de la connexion au chatbot');
    } catch (e) {
      print('Chatbot Unknown Error: $e');
      rethrow;
    }
  }
}
