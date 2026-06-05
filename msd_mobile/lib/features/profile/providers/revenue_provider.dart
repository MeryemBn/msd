import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/auth_state.dart';
import '../models/revenue_stats.dart';
import '../services/pricing_service.dart';

// Ces providers dépendent maintenant de authProvider.
// Si l'utilisateur change ou se déconnecte, ils sont automatiquement réinitialisés.

final revenueStatsProvider = FutureProvider<RevenueStats>((ref) async {
  final auth = ref.watch(authProvider);
  if (auth.status != AuthStatus.authenticated) throw Exception('Non authentifié');
  
  final pricingService = ref.watch(pricingServiceProvider);
  return pricingService.getRevenueStats();
});

final professionalPricesProvider = FutureProvider<List<dynamic>>((ref) async {
  final auth = ref.watch(authProvider);
  if (auth.status != AuthStatus.authenticated) return [];

  final pricingService = ref.watch(pricingServiceProvider);
  return pricingService.getMyPrices();
});
