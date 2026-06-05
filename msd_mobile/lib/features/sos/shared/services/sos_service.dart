import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/models/auth_user.dart';
import '../models/sos_request.dart';
import '../models/sos_type.dart';
import '../models/review.dart';

/**
 * Service gérant les interactions avec l'API pour la fonctionnalité SOS.
 */
class SosService {
  final Dio _dio = apiClient.dio;

  /**
   * Envoie une nouvelle demande SOS au serveur.
   */
  Future<SosRequest> createSosRequest(SosRequest request, SosType type) async {
    try {
      final response = await _dio.post(
        '/api/sos-requests',
        data: request.toApiJson(type),
      );
      return SosRequest.fromApiJson(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /**
   * Récupère la liste des demandes SOS de l'utilisateur connecté.
   */
  Future<List<SosRequest>> getMySosRequests({String? status}) async {
    try {
      final Map<String, dynamic> params = {};
      if (status != null) params['status'] = status;

      final response = await _dio.get(
        '/api/sos-requests',
        queryParameters: params,
      );
      
      final dynamic responseData = response.data;
      if (responseData == null) return [];
      
      final List<dynamic> data = responseData is List ? responseData : [];
      return data.map((json) => SosRequest.fromApiJson(json)).toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /**
   * Rechercher des professionnels elligibles avec filtres avancés.
   */
  Future<List<UserProfile>> searchProfessionals({
    required String serviceType,
    String? specialty,
    String? ambulanceType,
    double? latitude,
    double? longitude,
    double? maxDistance,
  }) async {
    try {
      final response = await _dio.get(
        '/api/professional/search',
        queryParameters: {
          'serviceType': serviceType,
          if (specialty != null) 'specialty': specialty,
          if (ambulanceType != null) 'ambulanceType': ambulanceType,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (maxDistance != null) 'maxDistance': maxDistance,
        },
      );
      final List<dynamic> data = response.data ?? [];
      return data.map((json) => UserProfile.fromJson(json)).toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /**
   * Récupère les créneaux horaires disponibles pour un professionnel donné à une date donnée.
   */
  Future<List<DateTime>> getAvailableSlots({
    required int professionalId,
    required DateTime date,
  }) async {
    try {
      final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await _dio.get(
        '/api/professional/$professionalId/available-slots',
        queryParameters: {
          'date': dateString,
        },
      );
      final List<dynamic> data = response.data ?? [];
      return data.map((slot) => DateTime.parse(slot as String)).toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /**
   * Calcule le prix final pour une mission.
   */
  Future<double> calculatePrice({
    required String professionalId,
    required String serviceType,
    String? specialty,
    String? ambulanceType,
    required String interventionMode,
    double? distanceKm,
  }) async {
    try {
      final response = await _dio.get(
        '/api/pricing/calculate',
        queryParameters: {
          'professionalId': professionalId,
          'serviceType': serviceType,
          if (specialty != null) 'specialty': specialty,
          if (ambulanceType != null) 'ambulanceType': ambulanceType,
          'interventionMode': interventionMode,
          if (distanceKm != null) 'distanceKm': distanceKm,
        },
      );
      return (response.data['price'] as num).toDouble();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /**
   * Récupère le prix moyen pour un service donné (Estimation SOS).
   */
  Future<double> getAveragePrice({
    required String serviceType,
    String? specialty,
    String? ambulanceType,
    required String interventionMode,
  }) async {
    try {
      final response = await _dio.get(
        '/api/pricing/average-price',
        queryParameters: {
          'serviceType': serviceType,
          if (specialty != null) 'specialty': specialty,
          if (ambulanceType != null) 'ambulanceType': ambulanceType,
          'interventionMode': interventionMode,
        },
      );
      return (response.data['averagePrice'] as num).toDouble();
    } on DioException catch (e) {
      _handleDioError(e);
      return 0.0;
    }
  }

  /**
   * Met à jour le statut d'une demande.
   */
  Future<SosRequest> updateSosStatus(String requestId, String newStatus) async {
    try {
      final response = await _dio.patch(
        '/api/sos-requests/$requestId/status',
        data: {'status': newStatus},
      );
      return SosRequest.fromApiJson(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /**
   * Soumet un avis pour une intervention.
   */
  Future<void> submitReview({
    required String sosRequestId,
    required int rating,
    String? comment,
  }) async {
    try {
      await _dio.post(
        '/api/reviews',
        data: {
          'sosRequestId': sosRequestId,
          'rating': rating,
          'comment': comment,
        },
      );
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /**
   * Récupère les avis d'un professionnel (pour lui-même).
   */
  Future<List<Review>> getMyProfessionalReviews() async {
    try {
      final response = await _dio.get('/api/reviews/mine');
      final List<dynamic> data = response.data ?? [];
      return data.map((json) => Review.fromJson(json)).toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /**
   * Récupère les avis pour un professionnel spécifique par son ID.
   */
  Future<List<Review>> getReviewsByProfessionalId(int professionalId) async {
    try {
      final response = await _dio.get('/api/reviews/professional/$professionalId');
      final List<dynamic> data = response.data ?? [];
      return data.map((json) => Review.fromJson(json)).toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  void _handleDioError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final errorData = e.response?.data;
      final message = errorData is Map 
          ? (errorData['message'] ?? 'Une erreur inattendue est survenue') 
          : 'Erreur serveur (${e.response?.statusCode})';
      throw Exception(message);
    } else {
      throw Exception('Connexion au serveur impossible.');
    }
  }
}

final sosService = SosService();
