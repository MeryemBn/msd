import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../network/api_client.dart';

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

  Future<void> makePayment({
    required double amount,
    required String currency,
    String? patientId,
  }) async {
    try {
      // 1. Create Payment Intent via Backend
      final paymentIntentData = await _createPaymentIntentOnBackend(
        amount,
        currency,
        patientId,
      );

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['clientSecret'],
          style: ThemeMode.light,
          merchantDisplayName: 'MSD Mobile',
        ),
      );

      // 3. Display Payment Sheet
      await _displayPaymentSheet();
    } catch (e) {
      debugPrint("Stripe Error: $e");
      rethrow;
    }
  }

  Future<void> _displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (e) {
      debugPrint("Stripe Exception: $e");
      throw Exception(e.error.localizedMessage);
    } catch (e) {
      debugPrint("Error displaying payment sheet: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _createPaymentIntentOnBackend(
      double amount, String currency, String? patientId) async {
    try {
      final response = await apiClient.dio.post(
        '/api/payments/create-payment-intent',
        data: {
          'amount': amount,
          'currency': currency,
          'patientId': patientId,
        },
      );
      return response.data;
    } catch (e) {
      debugPrint("Error creating payment intent on backend: $e");
      rethrow;
    }
  }
}
