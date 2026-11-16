import 'package:flutter/material.dart';

class AppBrandLogo extends StatelessWidget {
  final double size;
  final bool showTile;

  const AppBrandLogo({
    super.key,
    this.size = 48,
    this.showTile = true,
  });

  @override
  Widget build(BuildContext context) {
    final u = size / 100; // 1 unit = 1% scaling

    Widget bar(double x, double y, double w, double h, Color color) {
      return Positioned(
        left: x * u,
        top: y * u,
        width: w * u,
        height: h * u,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4 * u),
          ),
        ),
      );
    }

    final bars = SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Bar 1: Soft Periwinkle
          bar(22, 52, 14, 26, const Color(0xFFC7D2FE)),
          // Bar 2: Crisp Pure White
          bar(43, 38, 14, 40, Colors.white),
          // Bar 3: Vivid Emerald Green (Growth!)
          bar(64, 24, 14, 54, const Color(0xFF10B981)),
        ],
      ),
    );

    if (!showTile) return bars;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24 * u), // Modern squircle
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
            blurRadius: size * 0.28,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: bars,
    );
  }
}