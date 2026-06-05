import '../core/network/api_client.dart';
import '../features/sos/shared/models/sos_type.dart';

class SosOption {
  final SosType type;
  final String name;

  SosOption({required this.type, required this.name});

  factory SosOption.fromJson(Map<String, dynamic> json) {
    return SosOption(
      type: SosType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SosType.doctor,
      ),
      name: json['name'] ?? '',
    );
  }
}

class SosService {
  final ApiClient apiClient;

  SosService(this.apiClient);

  Future<List<SosOption>> getAvailableSosOptions(String patientId) async {
    try {
      final response = await apiClient.dio.get('/api/patients/$patientId/sos-options');
      final data = response.data;
      if (data is List) {
        return data.map((json) => SosOption.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> bookSosRequest(String patientId, SosType type, Map<String, dynamic> data) async {
    try {
      await apiClient.dio.post('/api/patients/$patientId/sos-requests', data: {
        'type': type.name,
        ...data,
      });
    } catch (e) {
      rethrow;
    }
  }
}
