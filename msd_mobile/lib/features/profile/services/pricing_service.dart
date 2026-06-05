import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/revenue_stats.dart';

class PricingService {
  final ApiClient _apiClient;

  PricingService(this._apiClient);

  Future<RevenueStats> getRevenueStats() async {
    try {
      final response = await _apiClient.dio.get('/api/professional/revenue/stats');
      return RevenueStats.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des statistiques de revenus');
    }
  }

  Future<List<dynamic>> getMyPrices() async {
    try {
      final response = await _apiClient.dio.get('/api/pricing/professional/my-prices');
      return response.data;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des tarifs');
    }
  }

  Future<void> setPrice({
    required String serviceType,
    String? specialty,
    String? ambulanceType,
    required String interventionMode,
    required double price,
    double extraKmPrice = 0,
    int kmRadiusIncluded = 0,
  }) async {
    try {
      await _apiClient.dio.post('/api/pricing/professional/set-price', data: {
        'serviceType': serviceType,
        'specialty': specialty,
        'ambulanceType': ambulanceType,
        'interventionMode': interventionMode,
        'price': price,
        'extraKmPrice': extraKmPrice,
        'kmRadiusIncluded': kmRadiusIncluded,
      });
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Erreur lors de la mise à jour du prix');
      }
      throw Exception('Erreur lors de la mise à jour du prix');
    }
  }
}

final pricingServiceProvider = Provider<PricingService>((ref) {
  return PricingService(ref.watch(apiClientProvider));
});
