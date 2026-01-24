import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:gap/gap.dart';

class SplashScreen extends StatefulWidget {
  final String nextRoute;
  const SplashScreen({super.key, required this.nextRoute});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go(widget.nextRoute);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [colorScheme.background, colorScheme.surface]
                : [colorScheme.surface, colorScheme.background],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Image - displays in original colors
              Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? colorScheme.surface.withOpacity(0.3)
                          : Colors.white.withOpacity(0.9),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                      // No color filter - shows original logo colors
                    ),
                  )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.easeOutBack)
                  .then(delay: 200.ms)
                  .shimmer(
                    duration: 1200.ms,
                    color: colorScheme.primary.withOpacity(0.3),
                  ),

              const Gap(40),

              // App Name
              Text(
                "METRO MASR",
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground,
                  letterSpacing: 3,
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

              const Gap(12),

              Text(
                "Your Daily Guide",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  color: colorScheme.onBackground.withOpacity(0.7),
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w300,
                ),
              ).animate().fadeIn(delay: 800.ms),

              const Gap(80),

              // Bottom Loader
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  color: colorScheme.primary,
                  strokeWidth: 3.5,
                ),
              ).animate().fadeIn(delay: 1000.ms),
            ],
          ),
        ),
      ),
    );
  }
}
