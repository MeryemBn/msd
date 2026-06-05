import 'package:flutter/material.dart';
import '../../../../app/app_theme.dart';

class SosSelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedBorderColor;

  const SosSelectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    this.isSelected = false,
    required this.onTap,
    this.selectedBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Utilise la couleur passée (rouge/noir) ou la couleur primaire par défaut
    final activeBorderColor = selectedBorderColor ?? AppTheme.primary;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? activeBorderColor 
                : (isDark ? Colors.white10 : Colors.grey.shade200),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (isSelected && !isDark)
              BoxShadow(
                color: activeBorderColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? iconBackgroundColor.withOpacity(0.15) : iconBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: activeBorderColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
