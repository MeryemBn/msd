import '../core/network/api_client.dart';
import '../features/home/models/next_dose_info.dart';

class MedicationsService {
  final ApiClient apiClient;

  MedicationsService(this.apiClient);

  Future<NextDoseInfo?> getNextDose(String patientId) async {
    try {
      final response = await apiClient.dio.get('/api/patients/$patientId/next-dose');
      if (response.data != null) {
        return NextDoseInfo.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> markDoseTaken(String patientId, String slotId) async {
    try {
      await apiClient.dio.post('/api/patients/$patientId/doses/$slotId/taken');
    } catch (e) {
      rethrow;
    }
  }
}
