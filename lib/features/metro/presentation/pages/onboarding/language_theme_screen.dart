import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../bloc/theme_cubit.dart';

class LanguageThemeScreen extends StatelessWidget {
  const LanguageThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          onPressed: () => context.pushReplacement('/onboarding'),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary.withOpacity(0.1),
                  theme.scaffoldBackgroundColor,
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(20),
                  Text(
                    "customization"
                        .tr(), // We might need to add this key or just use title
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ).animate().fadeIn().slideX(),
                  Text(
                    "make_it_yours".tr(), // Add key or hardcode fallback
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const Gap(40),

                  // Language Section
                  Text(
                    "choose_language".tr(),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const Gap(16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOptionCard(
                          context,
                          title: "English",
                          isSelected: context.locale.languageCode == 'en',
                          onTap: () => context.setLocale(const Locale('en')),
                          icon: Icons.language,
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: _buildOptionCard(
                          context,
                          title: "العربية",
                          isSelected: context.locale.languageCode == 'ar',
                          onTap: () => context.setLocale(const Locale('ar')),
                          icon: Icons.translate,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 400.ms),

                  const Gap(40),

                  // Theme Section
                  Text(
                    "choose_theme".tr(),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                  const Gap(16),
                  BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, themeMode) {
                      return Row(
                        children: [
                          Expanded(
                            child: _buildOptionCard(
                              context,
                              title: "Light",
                              isSelected:
                                  themeMode == ThemeMode.light ||
                                  (themeMode == ThemeMode.system &&
                                      MediaQuery.of(
                                            context,
                                          ).platformBrightness ==
                                          Brightness.light), // Simplified logic
                              onTap: () =>
                                  context.read<ThemeCubit>().toggleTheme(false),
                              icon: Icons.wb_sunny_rounded,
                            ),
                          ),
                          const Gap(16),
                          Expanded(
                            child: _buildOptionCard(
                              context,
                              title: "Dark",
                              isSelected: themeMode == ThemeMode.dark,
                              onTap: () =>
                                  context.read<ThemeCubit>().toggleTheme(true),
                              icon: Icons.dark_mode_rounded,
                            ),
                          ),
                        ],
                      );
                    },
                  ).animate().fadeIn(delay: 600.ms),

                  const Gap(60),

                  // Next Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => context.pushReplacement('/permissions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        "next".tr(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.1)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const Gap(12),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
