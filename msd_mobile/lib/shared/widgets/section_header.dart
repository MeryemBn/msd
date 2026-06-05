import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String label;

  const SectionHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
      ),
    );
  }
}
