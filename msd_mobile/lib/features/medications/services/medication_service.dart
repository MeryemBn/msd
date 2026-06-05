import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../models/medication.dart';
import '../models/intake_log.dart';

class MedicationService {
  final Dio _dio = apiClient.dio;

  Future<List<Medication>> getMyMedications() async {
    try {
      final response = await _dio.get('/api/medications');
      return (response.data as List).map((m) => Medication.fromJson(m)).toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Retrieves intake logs for a specific date or a range of dates.
  /// If [endDate] is provided, it fetches all logs between [startDate] and [endDate].
  Future<List<IntakeLog>> getDailyIntakes(DateTime startDate, {DateTime? endDate}) async {
    try {
      final startStr = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
      final Map<String, dynamic> params = {'date': startStr};
      
      if (endDate != null) {
        params['endDate'] = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
      }

      final response = await _dio.get('/api/medications/intakes', 
        queryParameters: params
      );
      return (response.data as List).map((l) => IntakeLog.fromJson(l)).toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Medication> addMedication(Medication medication) async {
    try {
      final response = await _dio.post('/api/medications', data: medication.toJson());
      return Medication.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Medication> updateMedicationStock(String id, int currentStock) async {
    try {
      final response = await _dio.patch('/api/medications/$id', data: {
        'currentStock': currentStock,
      });
      return Medication.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<void> updateIntake({
    required String logId,
    String? status,
    TimeOfDay? slotTime,
    DateTime? actualTakenDateTime,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (status != null) data['status'] = status.toUpperCase();
      if (slotTime != null) {
        data['slotTime'] = "${slotTime.hour.toString().padLeft(2, '0')}:${slotTime.minute.toString().padLeft(2, '0')}:00";
      }
      if (actualTakenDateTime != null) {
        data['actualTakenDateTime'] = actualTakenDateTime.toIso8601String();
      }

      await _dio.patch('/api/medications/intakes/$logId', data: data);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  void _handleDioError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final errorData = e.response?.data;
      final message = errorData is Map ? (errorData['message'] ?? 'Une erreur est survenue') : 'Erreur ${e.response?.statusCode}';
      throw Exception(message);
    } else {
      throw Exception('Impossible de contacter le serveur.');
    }
  }
}

final medicationService = MedicationService();
