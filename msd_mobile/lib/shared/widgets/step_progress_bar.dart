import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: isDark ? Border.all(color: Colors.white10) : null,
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded, 
              size: 18, 
              color: isDark ? Colors.white : AppTheme.textDark
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            children: List.generate(totalSteps, (index) {
              final isActive = index < currentStep;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.primary
                        : (isDark ? Colors.white12 : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
