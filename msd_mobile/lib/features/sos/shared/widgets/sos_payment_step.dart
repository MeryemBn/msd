import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/sos_provider.dart';
import '../models/sos_enums.dart';
import '../models/sos_type.dart';
import '../../../../app/app_theme.dart';
import 'sos_selection_card.dart';

class SosPaymentStep extends ConsumerWidget {
  const SosPaymentStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sosState = ref.watch(sosProvider);
    final paymentMethod = sosState.currentRequest?.paymentMethod ?? PaymentMethod.cash;
    final price = sosState.currentRequest?.price ?? 0.0;
    final estimatedPrice = sosState.estimatedPrice;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTeleconsult = sosState.currentType == SosType.teleconsult;
    final selectedPro = sosState.selectedProfessional;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.payment,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.choosePaymentMethod,
            style: TextStyle(color: isDark ? Colors.white60 : Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          
          if (selectedPro != null) ...[
            // ÉCRAN POUR RENDEZ-VOUS : Affichage du prix réel du professionnel
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_circle_outlined, color: AppTheme.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Tarif de : ${selectedPro.fullName}",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(height: 1),
                  ),
                  Text(
                    l10n.consultationFee,
                    style: TextStyle(color: isDark ? Colors.white60 : Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${NumberFormat("#,##0.00").format(price)} MAD',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Ce prix inclut les frais de déplacement calculés selon votre adresse.",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // ÉCRAN POUR URGENCE (SOS) : Estimation du prix
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.analytics_outlined, color: AppTheme.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        sosState.currentType == SosType.ambulance 
                          ? "Estimation du tarif Ambulance" 
                          : "Estimation du tarif SOS",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : AppTheme.textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if ((estimatedPrice != null && estimatedPrice > 0) || (sosState.currentType == SosType.ambulance && price > 0)) ...[
                    const SizedBox(height: 16),
                    Text(
                      '~ ${NumberFormat("#,##0").format(estimatedPrice ?? price)} MAD',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sosState.currentType == SosType.ambulance
                        ? "Ce prix est une estimation basée sur le type d'ambulance. Le tarif final sera confirmé par le prestataire."
                        : "Ce prix est une moyenne calculée sur les tarifs des professionnels disponibles dans votre zone.",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    Text(
                      "Le tarif final sera fixé par le professionnel qui acceptera votre demande à proximité selon ses propres réglages.",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : AppTheme.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Choix de la méthode de paiement
          if (!isTeleconsult) ...[
            SosSelectionCard(
              title: PaymentMethod.cash.getLabel(l10n),
              subtitle: PaymentMethod.cash.getDescription(l10n),
              icon: Icons.payments_outlined,
              iconColor: const Color(0xFF2DBFAD),
              iconBackgroundColor: const Color(0xFFE8F8F6),
              isSelected: paymentMethod == PaymentMethod.cash,
              onTap: () => ref.read(sosProvider.notifier).updatePaymentMethod(PaymentMethod.cash),
            ),
            const SizedBox(height: 16),
          ],
          
          SosSelectionCard(
            title: PaymentMethod.card.getLabel(l10n),
            subtitle: PaymentMethod.card.getDescription(l10n),
            icon: Icons.credit_card_outlined,
            iconColor: const Color(0xFF4A90D9),
            iconBackgroundColor: const Color(0xFFE3F2FD),
            isSelected: paymentMethod == PaymentMethod.card,
            onTap: () => ref.read(sosProvider.notifier).updatePaymentMethod(PaymentMethod.card),
          ),
        ],
      ),
    );
  }
}
