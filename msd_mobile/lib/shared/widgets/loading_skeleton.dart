import 'package:flutter/material.dart';

class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({super.key});

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 0.9).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Opacity(
          opacity: _animation.value,
          child: SingleChildScrollView( // ✅ Ajout du scroll pour éviter l'overflow sur petits écrans
            physics: const NeverScrollableScrollPhysics(), // On empêche le scroll manuel pour garder l'effet skeleton
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(width: 100, height: 14),
                  const SizedBox(height: 6),
                  _SkeletonBox(width: 200, height: 28),
                  const SizedBox(height: 20),
                  _SkeletonBox(width: double.infinity, height: 88, radius: 16),
                  const SizedBox(height: 28),
                  _SkeletonBox(width: 100, height: 12),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _SkeletonBox(height: 110, radius: 16)),
                      const SizedBox(width: 12),
                      Expanded(child: _SkeletonBox(height: 110, radius: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _SkeletonBox(height: 110, radius: 16)),
                      const SizedBox(width: 12),
                      Expanded(child: _SkeletonBox(height: 110, radius: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SkeletonBox(width: double.infinity, height: 72, radius: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const _SkeletonBox({
    this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
