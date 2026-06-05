import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';

class ModalLabel extends StatelessWidget {
  final String text;
  const ModalLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white70 : AppTheme.textDark,
      ),
    );
  }
}

class ModalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool hasError;

  const ModalTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.white38 : AppTheme.textGrey, 
          fontSize: 14,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: hasError 
                ? Colors.redAccent 
                : (isDark ? Colors.white10 : Colors.grey.shade200),
            width: hasError ? 1.5 : 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: hasError 
                ? Colors.redAccent 
                : (isDark ? Colors.white10 : Colors.grey.shade200),
            width: hasError ? 1.5 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: hasError ? Colors.redAccent : AppTheme.primary,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class SlotChip extends StatelessWidget {
  final double width;
  final IconData icon;
  final String label;
  final String time;
  final bool selected;
  final VoidCallback onTap;

  const SlotChip({
    super.key,
    required this.width,
    required this.icon,
    required this.label,
    required this.time,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected 
                ? (isDark ? AppTheme.primary.withOpacity(0.15) : AppTheme.primaryLight)
                : (isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade50),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected 
                  ? AppTheme.primary.withOpacity(0.4) 
                  : (isDark ? Colors.white10 : Colors.grey.shade200),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: selected ? AppTheme.primary : AppTheme.textGrey),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? AppTheme.primary : (isDark ? Colors.white60 : AppTheme.textGrey),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: selected ? AppTheme.primary : (isDark ? Colors.white30 : AppTheme.textGrey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
