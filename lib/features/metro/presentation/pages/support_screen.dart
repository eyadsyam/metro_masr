import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _launch(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "support_title".tr(),
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // Layer 1: Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryColor.withOpacity(0.1),
                  theme.scaffoldBackgroundColor,
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Image
                  Center(
                    child:
                        Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withOpacity(
                                  0.3,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.support_agent_rounded,
                                size: 64,
                                color: colorScheme.primary,
                              ),
                            )
                            .animate()
                            .scale(duration: 500.ms, curve: Curves.easeOutBack)
                            .fade(duration: 400.ms),
                  ),
                  const Gap(32),

                  // Contact Section
                  Text(
                    "contact_us".tr(),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                  const Gap(20),

                  // Social Links Row
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _socialIcon(
                          context,
                          'assets/images/whatsApp.png',
                          'whatsapp_label'.tr(),
                          () =>
                              _launch(Uri.parse('https://wa.me/201101118616')),
                        ),
                        _socialIcon(
                          context,
                          'assets/images/github.png',
                          'GitHub',
                          () => _launch(
                            Uri.parse('https://github.com/eyadsyam/metro_masr'),
                          ),
                        ),
                        _socialIcon(
                          context,
                          'assets/images/LinkedIn.png',
                          'linkedin_label'.tr(),
                          () => _launch(
                            Uri.parse('https://www.linkedin.com/in/eyad-syam/'),
                          ),
                        ),
                        _socialIcon(
                          context,
                          'assets/images/gmail.png',
                          'email_label'.tr(),
                          () => _launch(
                            Uri(
                              scheme: 'mailto',
                              path: 'eyadsyam124@gmail.com',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms).scale(),
                  const Gap(40),

                  // FAQ Section
                  Text(
                    "faq".tr(),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                  const Gap(16),
                  _faqItem(
                    context,
                    "faq_q1".tr(),
                    "faq_a1".tr(),
                  ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.1),
                  _faqItem(
                    context,
                    "faq_q2".tr(),
                    "faq_a2".tr(),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                  _faqItem(
                    context,
                    "faq_q3".tr(),
                    "faq_a3".tr(),
                  ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.1),
                  const Gap(120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(
    BuildContext context,
    String? assetPath,
    String label,
    VoidCallback onTap, {
    IconData? icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
            ),
            child: Center(
              child: assetPath != null
                  ? Image.asset(
                      assetPath,
                      width: 32,
                      height: 32,
                      color: isDark && assetPath.contains('github')
                          ? Colors.white
                          : null,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.link,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  : Icon(icon, color: Theme.of(context).primaryColor, size: 32),
            ),
          ),
          const Gap(8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqItem(BuildContext context, String q, String a) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        title: Text(
          q,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: colorScheme.onSurface,
          ),
        ),
        iconColor: colorScheme.primary,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              a,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
