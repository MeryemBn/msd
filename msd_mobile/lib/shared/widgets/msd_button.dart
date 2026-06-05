import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class MsdButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool showIcon;

  const MsdButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: !isEnabled || isOutlined
              ? null
              : const LinearGradient(
            colors: [Color(0xFF3DD6C0), Color(0xFF2DBFAD)],
          ),
          color: !isEnabled && !isOutlined ? Colors.grey.shade300 : null,
          borderRadius: BorderRadius.circular(16),
          border: isOutlined
              ? Border.all(color: isEnabled ? AppTheme.primary : Colors.grey, width: 1.5)
              : null,
          boxShadow: !isEnabled || isOutlined
              ? null
              : [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isLoading
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: isOutlined
                      ? (isEnabled ? AppTheme.primary : Colors.grey)
                      : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (showIcon) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: isOutlined ? (isEnabled ? AppTheme.primary : Colors.grey) : Colors.white,
                  size: 18,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
