import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LivelyBackground extends StatelessWidget {
  const LivelyBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primary = Theme.of(context).primaryColor;
    final secondary = isDark
        ? const Color(0xFF8B5CF6)
        : const Color(0xFF00ACC1);
    final accent = isDark ? const Color(0xFFF472B6) : const Color(0xFF4FC3F7);

    return Stack(
      children: [
        // Base Background
        Container(color: Theme.of(context).scaffoldBackgroundColor),

        // Deep Gradient
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.8, -0.6),
              radius: 1.5,
              colors: [
                primary.withOpacity(isDark ? 0.2 : 0.1),
                Theme.of(context).scaffoldBackgroundColor,
              ],
            ),
          ),
        ),

        // Starfield / Micro-dots Effect
        ...List.generate(30, (i) {
          final random = math.Random(i);
          final top = random.nextDouble() * size.height;
          final left = random.nextDouble() * size.width;
          final dotSize = 1.0 + random.nextDouble() * 2.0;

          return Positioned(
            top: top,
            left: left,
            child:
                Container(
                      width: dotSize,
                      height: dotSize,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (random.nextBool())
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                        ],
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(duration: (2000 + random.nextInt(3000)).ms)
                    .then()
                    .fadeOut(duration: (2000 + random.nextInt(3000)).ms),
          );
        }),

        // Animated Blob 1 (Top Left)
        Positioned(
          top: -size.height * 0.2,
          left: -size.width * 0.2,
          child: _AnimatedBlob(
            size: size.width * 0.9,
            color: primary.withOpacity(0.25),
            duration: 12.seconds,
            moveOffset: const Offset(80, 60),
          ),
        ),

        // Animated Blob 2 (Bottom Right)
        Positioned(
          bottom: -size.height * 0.2,
          right: -size.width * 0.2,
          child: _AnimatedBlob(
            size: size.width * 1.2,
            color: secondary.withOpacity(0.2),
            duration: 15.seconds,
            moveOffset: const Offset(-100, -80),
          ),
        ),

        // Animated Blob 3 (Floating in middle)
        Positioned(
          top: size.height * 0.3,
          left: size.width * 0.3,
          child: _AnimatedBlob(
            size: size.width * 0.8,
            color: accent.withOpacity(0.12),
            duration: 10.seconds,
            moveOffset: const Offset(-40, 40),
          ),
        ),

        // Glassmorphism Blur
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }
}

class _AnimatedBlob extends StatelessWidget {
  final double size;
  final Color color;
  final Duration duration;
  final Offset moveOffset;

  const _AnimatedBlob({
    required this.size,
    required this.color,
    required this.duration,
    required this.moveOffset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color, Colors.transparent]),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.4, 1.4),
          duration: duration,
          curve: Curves.easeInOut,
        )
        .move(
          begin: Offset.zero,
          end: moveOffset,
          duration: duration,
          curve: Curves.easeInOut,
        );
  }
}
