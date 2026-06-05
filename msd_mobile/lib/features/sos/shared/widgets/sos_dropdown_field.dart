import 'package:flutter/material.dart';

class SosDropdownField<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabelBuilder;
  final ValueChanged<T?> onChanged;
  final IconData? prefixIcon;

  const SosDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.itemLabelBuilder,
    required this.onChanged,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (prefixIcon != null) ...[
          Row(
            children: [
              Icon(prefixIcon, size: 20, color: isDark ? Colors.white60 : const Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ] else
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              hint: Text(
                hint,
                style: TextStyle(color: isDark ? Colors.white30 : Colors.grey.shade500, fontSize: 15),
              ),
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white30 : Colors.grey.shade400),
              items: items.map((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabelBuilder(item),
                    style: const TextStyle(fontSize: 15),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
