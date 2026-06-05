import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../services/sos_service.dart';
import '../../../../app/app_theme.dart';

class SosAvailableSlotsPicker extends StatefulWidget {
  final int professionalId;
  final DateTime? selectedDateTime;
  final Function(DateTime) onSlotSelected;

  const SosAvailableSlotsPicker({
    super.key,
    required this.professionalId,
    required this.selectedDateTime,
    required this.onSlotSelected,
  });

  @override
  State<SosAvailableSlotsPicker> createState() => _SosAvailableSlotsPickerState();
}

class _SosAvailableSlotsPickerState extends State<SosAvailableSlotsPicker>
    with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _availableSlots = [];
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

    if (widget.selectedDateTime != null) {
      _selectedDate = DateTime(
        widget.selectedDateTime!.year,
        widget.selectedDateTime!.month,
        widget.selectedDateTime!.day,
      );
    }
    _fetchAvailableSlots();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      locale: Localizations.localeOf(context),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppTheme.primary,
              brightness: Theme.of(context).brightness,
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && !DateUtils.isSameDay(picked, _selectedDate)) {
      setState(() => _selectedDate = picked);
      _fetchAvailableSlots();
    }
  }

  Future<void> _fetchAvailableSlots() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _animationController.reset();

    try {
      final slots = await sosService.getAvailableSlots(
        professionalId: widget.professionalId,
        date: _selectedDate,
      );

      final now = DateTime.now();
      final filteredSlots = slots.where((s) {
        final isHourMark = s.minute == 0;
        final isFuture = s.isAfter(now.add(const Duration(minutes: 15)));
        return isHourMark && isFuture;
      }).toList();

      if (mounted) {
        setState(() {
          _availableSlots = filteredSlots;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
          _availableSlots = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.chooseDate, Icons.calendar_today_rounded),
        const SizedBox(height: 16),
        _buildDateField(isDark, l10n),
        const SizedBox(height: 32),
        _buildSectionHeader(l10n.availableTimeSlots, Icons.access_time_rounded),
        const SizedBox(height: 16),
        Expanded(
          child: _isLoading
              ? _buildLoadingState()
              : FadeTransition(
            opacity: _fadeAnimation,
            child: _errorMessage != null
                ? _buildErrorState()
                : _buildSlotsView(isDark, l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(bool isDark, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).toString();
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());

    // Format de la date affichée
    final dateLabel = isToday
        ? (locale.startsWith('ar')
        ? "اليوم — ${DateFormat('d MMMM yyyy', locale).format(_selectedDate)}"
        : locale.startsWith('en')
        ? "Today — ${DateFormat('MMMM d, yyyy', locale).format(_selectedDate)}"
        : "Aujourd'hui — ${DateFormat('d MMMM yyyy', locale).format(_selectedDate)}")
        : DateFormat('EEEE d MMMM yyyy', locale).format(_selectedDate);

    return GestureDetector(
      onTap: _pickDate,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primary.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            // Icône calendrier avec fond coloré
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, Color(0xFF2DBFAD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.chooseDate,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary.withOpacity(0.8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dateLabel,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
            // Flèche / indicateur cliquable
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.edit_calendar_rounded,
                color: AppTheme.primary,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotsView(bool isDark, AppLocalizations l10n) {
    if (_availableSlots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: 72,
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noAvailableSlots,
              style: TextStyle(
                color: isDark ? Colors.white70 : AppTheme.textGrey,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tryAnotherDate,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            // Bouton pour changer de date directement depuis l'état vide
            TextButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_month_rounded, color: AppTheme.primary),
              label: Text(
                l10n.chooseDate,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final morning = _availableSlots.where((s) => s.hour < 12).toList();
    final afternoon =
    _availableSlots.where((s) => s.hour >= 12 && s.hour < 18).toList();
    final evening = _availableSlots.where((s) => s.hour >= 18).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (morning.isNotEmpty)
          ..._buildSlotGroupSlivers(
              l10n.morning, morning, Icons.wb_sunny_rounded, Colors.orange, isDark),
        if (afternoon.isNotEmpty)
          ..._buildSlotGroupSlivers(
              l10n.afternoon, afternoon, Icons.wb_cloudy_rounded, Colors.blue, isDark),
        if (evening.isNotEmpty)
          ..._buildSlotGroupSlivers(
              l10n.evening, evening, Icons.nights_stay_rounded, Colors.indigo, isDark),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  List<Widget> _buildSlotGroupSlivers(
      String title,
      List<DateTime> slots,
      IconData icon,
      Color color,
      bool isDark,
      ) {
    return [
      SliverPadding(
        padding: const EdgeInsets.only(top: 28),
        sliver: SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 4),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.grey.shade800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Divider(
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                    thickness: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          delegate: SliverChildBuilderDelegate(
                (context, index) => _buildSlotCard(slots[index], isDark),
            childCount: slots.length,
          ),
        ),
      ),
    ];
  }

  Widget _buildSlotCard(DateTime slot, bool isDark) {
    final isSelected = widget.selectedDateTime != null &&
        widget.selectedDateTime!.hour == slot.hour &&
        DateUtils.isSameDay(widget.selectedDateTime!, slot);

    return GestureDetector(
      onTap: () => widget.onSlotSelected(slot),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary
              : (isDark ? AppTheme.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : (isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.shade200),
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            else if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Center(
          child: Text(
            DateFormat('HH:00').format(slot),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white : AppTheme.textDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final locale = Localizations.localeOf(context).toString();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
          const SizedBox(height: 20),
          Text(
            DateFormat.yMMMMd(locale).format(_selectedDate),
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchAvailableSlots,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text(
                "Réessayer",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}