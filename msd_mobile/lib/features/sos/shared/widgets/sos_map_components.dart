import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class PinMarker extends StatelessWidget {
  final Color color;
  const PinMarker({super.key, this.color = const Color(0xFF2DBFAD)});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45,
      height: 55,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ombre du marqueur pour le relief
          Positioned(
            bottom: 4,
            child: Container(
              width: 14,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
              ),
            ),
          ),
          // Corps du marqueur
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  // Bordure TOUJOURS BLANCHE pour le contraste sur carte sombre
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))
                  ],
                ),
                child: const Icon(Icons.location_on, color: Colors.white, size: 20),
              ),
              CustomPaint(
                size: const Size(12, 8),
                painter: _TrianglePainter(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = ui.PaintingStyle.fill;
    final path = ui.Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MapIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isLoading;

  const MapIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isPrimary 
                ? const Color(0xFF2DBFAD) 
                : (isDark ? const Color(0xFF2C2C2C) : Colors.white),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.1), 
                blurRadius: 10, 
                offset: const Offset(0, 4)
              )
            ],
            border: isDark && !isPrimary 
                ? Border.all(color: Colors.white10) 
                : null,
          ),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Icon(
                  icon, 
                  size: 22, 
                  color: isPrimary ? Colors.white : (isDark ? Colors.white70 : Colors.black87)
                ),
        ),
      ),
    );
  }
}
