import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ...

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "packages".tr(),
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Daily Tickets
                _buildSectionHeader(
                  context,
                  "daily_tickets".tr(),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                _buildTicketCard(
                  context,
                  const Color(0xFFFBC02D),
                  "n_stations".tr(args: ['9']),
                  "8 ${'price_egp'.tr()}",
                ).animate().fadeIn(delay: 100.ms).slideX(),
                _buildTicketCard(
                  context,
                  const Color(0xFF4CAF50),
                  "n_stations".tr(args: ['16']),
                  "10 ${'price_egp'.tr()}",
                ).animate().fadeIn(delay: 150.ms).slideX(),
                _buildTicketCard(
                  context,
                  const Color(0xFFE53935),
                  "n_stations".tr(args: ['23']),
                  "15 ${'price_egp'.tr()}",
                ).animate().fadeIn(delay: 200.ms).slideX(),
                _buildTicketCard(
                  context,
                  const Color(0xFF8E24AA),
                  "n_stations".tr(args: ['23+']),
                  "20 ${'price_egp'.tr()}",
                ).animate().fadeIn(delay: 250.ms).slideX(),
                _buildTicketCard(
                  context,
                  const Color(0xFF1565C0),
                  "Cash Wallet",
                  "80 ${'price_egp'.tr()}", // Card price
                  subtitle: "Charge 40-500 EGP",
                ).animate().fadeIn(delay: 270.ms).slideX(),

                const SizedBox(height: 32),

                // Monthly: Public
                _buildSectionHeader(
                  context,
                  "Monthly (Public)",
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                _buildSubCard(
                  context,
                  "1 Zone (9 Stations)",
                  "310 ${'price_egp'.tr()}",
                  Icons.public_rounded,
                  subtitle: "Saving ~38%",
                ).animate().fadeIn(delay: 320.ms).slideX(),
                _buildSubCard(
                  context,
                  "2 Zones (16 Stations)",
                  "365 ${'price_egp'.tr()}",
                  Icons.public_rounded,
                  subtitle: "Saving ~45%",
                ).animate().fadeIn(delay: 340.ms).slideX(),
                _buildSubCard(
                  context,
                  "3-4 Zones (23 Stations)",
                  "425 ${'price_egp'.tr()}",
                  Icons.public_rounded,
                  subtitle: "Saving ~55%",
                ).animate().fadeIn(delay: 360.ms).slideX(),
                _buildSubCard(
                  context,
                  "5-6 Zones (23+ Stations)",
                  "600 ${'price_egp'.tr()}",
                  Icons.public_rounded,
                  subtitle: "Saving ~40%",
                ).animate().fadeIn(delay: 380.ms).slideX(),

                const SizedBox(height: 32),

                // Quarterly
                _buildSectionHeader(
                  context,
                  "quarterly_sub".tr(),
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                _buildSubCard(
                  context,
                  "public".tr(),
                  "~500 ${'price_egp'.tr()}",
                  Icons.person_rounded,
                ).animate().fadeIn(delay: 420.ms).slideX(),

                // Student & Elderly
                const SizedBox(height: 32),
                _buildSectionHeader(
                  context,
                  "Special Categories",
                ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),

                _buildSubCard(
                  context,
                  "students".tr(),
                  "33 - 41 ${'price_egp'.tr()}",
                  Icons.school_rounded,
                  subtitle: "Quarterly (3 Months)",
                ).animate().fadeIn(delay: 520.ms).slideX(),
                _buildSubCard(
                  context,
                  "elderly".tr() + " (+60)",
                  "Sliding Scale", // 1 month 135
                  Icons.elderly_rounded,
                  subtitle: "Monthly: ~165-265 EGP",
                ).animate().fadeIn(delay: 540.ms).slideX(),
                _buildSubCard(
                  context,
                  "Elderly (+70)",
                  "Free",
                  Icons.accessibility_new_rounded,
                  subtitle: "All Lines",
                ).animate().fadeIn(delay: 560.ms).slideX(),
                _buildSubCard(
                  context,
                  "People of Determination",
                  "22 - 27 ${'price_egp'.tr()}",
                  Icons.accessible_forward,
                  subtitle: "Quarterly (3 Months)",
                ).animate().fadeIn(delay: 580.ms).slideX(),

                const SizedBox(height: 32),

                // Yearly
                _buildSectionHeader(
                  context,
                  "yearly_sub".tr(),
                ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildYearlyRow(
                        context,
                        "2 ${'line'.tr()}",
                        "4235 ${'price_egp'.tr()}",
                      ),
                      const Divider(height: 32),
                      _buildYearlyRow(
                        context,
                        "3 ${'line'.tr()}",
                        "5335 ${'price_egp'.tr()}",
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 650.ms).scale(),
                const Gap(120),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTicketCard(
    BuildContext context,
    Color color,
    String stations,
    String price, {
    String? subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stations,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          Text(
            price,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCard(
    BuildContext context,
    String title,
    String price,
    IconData icon, {
    String? subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colorScheme.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: colorScheme.primary,
                ),
              )
            : null,
        trailing: Text(
          price,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildYearlyRow(BuildContext context, String title, String price) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          price,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
