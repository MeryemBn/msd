import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../sos/shared/models/review.dart';
import '../../sos/shared/services/sos_service.dart';

class ProfessionalReviewsScreen extends ConsumerStatefulWidget {
  final int? professionalId;
  final String? professionalName;

  const ProfessionalReviewsScreen({
    super.key,
    this.professionalId,
    this.professionalName,
  });

  @override
  ConsumerState<ProfessionalReviewsScreen> createState() => _ProfessionalReviewsScreenState();
}

class _ProfessionalReviewsScreenState extends ConsumerState<ProfessionalReviewsScreen> {
  List<Review>? _reviews;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = widget.professionalId != null
          ? await sosService.getReviewsByProfessionalId(widget.professionalId!)
          : await sosService.getMyProfessionalReviews();
      
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    
    final title = widget.professionalName != null 
        ? l10n.proReviewsOf(widget.professionalName!) 
        : l10n.proReviewsTitle;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _error != null
              ? Center(child: Text(l10n.errorPrefix(_error!)))
              : (_reviews == null || _reviews!.isEmpty)
                  ? _buildEmptyState(context, isDark, l10n)
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _reviews!.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) => _ReviewCard(review: _reviews![index], locale: locale),
                    ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 64, color: isDark ? Colors.white12 : Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            l10n.proNoReviewsYet,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textGrey),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              widget.professionalId != null 
                ? l10n.proNoReviewsProDesc
                : l10n.proNoReviewsMeDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textGrey),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  final String locale;
  const _ReviewCard({required this.review, required this.locale});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedDate = DateFormat('dd MMM yyyy HH:mm', locale).format(review.createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.fieldBgDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.patientFullName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                formattedDate,
                style: const TextStyle(color: AppTheme.textGrey, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: Colors.amber,
                size: 18,
              );
            }),
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
