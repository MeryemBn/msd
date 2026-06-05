import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../models/professional_review.dart';
import '../providers/admin_provider.dart';
import '../../auth/models/auth_user.dart';

class ProfessionalReviewDetailScreen extends ConsumerStatefulWidget {
  final ProfessionalReview review;
  const ProfessionalReviewDetailScreen({super.key, required this.review});

  @override
  ConsumerState<ProfessionalReviewDetailScreen> createState() => _ProfessionalReviewDetailScreenState();
}

class _ProfessionalReviewDetailScreenState extends ConsumerState<ProfessionalReviewDetailScreen> {
  final _rejectionController = TextEditingController();

  @override
  void dispose() {
    _rejectionController.dispose();
    super.dispose();
  }

  void _showRejectionDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.adminRejectionReasonTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _rejectionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: l10n.adminRejectionHint,
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark ? AppTheme.fieldBgDark : Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (_rejectionController.text.trim().isEmpty) return;
              ref.read(adminProvider.notifier).rejectProfessional(
                widget.review.professionalInfoId, 
                _rejectionController.text.trim()
              );
              Navigator.pop(context);
              context.pop();
            },
            child: Text(l10n.adminConfirmRejection, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    
    // Check if the professional is pending
    final isPending = review.status == ValidationStatus.PENDING;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppTheme.textDark),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.adminReviewTitle, style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSummary(review, isDark, l10n),
            const SizedBox(height: 32),
            Row(
              children: [
                const Icon(Icons.description_rounded, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(l10n.adminSupportingDocs, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppTheme.textDark)),
              ],
            ),
            const SizedBox(height: 16),
            ...review.documents.map((doc) => _buildEnhancedDocCard(doc, isDark, l10n, locale)).toList(),
            const SizedBox(height: 40),
            if (isPending) 
              _buildActionButtons(isDark, l10n)
            else
              _buildStatusBanner(review.status, isDark, l10n),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(ValidationStatus status, bool isDark, AppLocalizations l10n) {
    final isValidated = status == ValidationStatus.VALIDATED;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isValidated ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isValidated ? Colors.green : Colors.red),
      ),
      child: Row(
        children: [
          Icon(isValidated ? Icons.check_circle : Icons.cancel, color: isValidated ? Colors.green : Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isValidated ? l10n.adminProAlreadyValidated : l10n.adminProAlreadyRejected,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isValidated ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSummary(ProfessionalReview review, bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: AppTheme.primary.withOpacity(0.1),
            child: Text(review.firstName[0].toUpperCase(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primary)),
          ),
          const SizedBox(height: 16),
          Text(review.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(review.email, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          _buildInfoGrid(review, l10n),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(ProfessionalReview review, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(child: _buildMiniInfo(l10n.adminServiceLabel, review.serviceType ?? 'N/A')),
        Expanded(child: _buildMiniInfo(l10n.adminSpecTypeLabel, review.specialty ?? review.ambulanceType ?? 'N/A')),
      ],
    );
  }

  Widget _buildMiniInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(
          value, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEnhancedDocCard(doc, bool isDark, AppLocalizations l10n, String locale) {
    String displayOcr = doc.ocrResult ?? "";
    if (displayOcr.contains("🔍 TEXTE BRUT EXTRAIT :")) {
      displayOcr = displayOcr.split("🔍 TEXTE BRUT EXTRAIT :")[0].trim();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.file_present_rounded, color: AppTheme.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(doc.documentType.replaceAll('_', ' '), 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                Text(DateFormat('dd MMM', locale).format(doc.uploadedAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showFullScreenImage(doc.fullUrl),
            child: Container(
              height: 220,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(image: NetworkImage(doc.fullUrl), fit: BoxFit.cover),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.6), Colors.transparent]),
                ),
                child: const Align(alignment: Alignment.bottomRight, child: Padding(padding: EdgeInsets.all(12), child: Icon(Icons.zoom_in_rounded, color: Colors.white))),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withOpacity(0.2) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.blueAccent),
                      const SizedBox(width: 8),
                      Text("MSD SMART ANALYTICS", 
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blue.shade700, letterSpacing: 1)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayOcr.isNotEmpty ? displayOcr : l10n.adminNoOcrData,
                    style: TextStyle(
                      fontSize: 13, 
                      color: isDark ? Colors.blue.shade100 : Colors.blue.shade900, 
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: () => _showRejectionDialog(l10n),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent, 
                side: const BorderSide(color: Colors.redAccent, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
              ),
              child: Text(l10n.adminRejectAction, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                ref.read(adminProvider.notifier).validateProfessional(widget.review.professionalInfoId);
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                elevation: 8,
                shadowColor: AppTheme.primary.withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
              ),
              child: Text(l10n.adminValidateAction, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  void _showFullScreenImage(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            InteractiveViewer(child: Center(child: Image.network(url, fit: BoxFit.contain))),
            Positioned(
              top: 40, right: 20,
              child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)),
            ),
          ],
        ),
      ),
    );
  }
}
