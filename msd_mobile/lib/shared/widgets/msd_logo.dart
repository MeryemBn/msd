import 'package:flutter/material.dart';

class MsdLogo extends StatelessWidget {
  final double size;
  const MsdLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3DD6C0), Color(0xFF2DBFAD)],
        ),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Icon(
        Icons.favorite_outline,
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }
}