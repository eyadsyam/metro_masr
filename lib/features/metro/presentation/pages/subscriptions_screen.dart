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

                const SizedBox(height: 32),

                // Quarterly
                _buildSectionHeader(
                  context,
                  "quarterly_sub".tr(),
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                _buildSubCard(
                  context,
                  "public".tr(),
                  "185 ${'price_egp'.tr()}",
                  Icons.person_rounded,
                ).animate().fadeIn(delay: 350.ms).slideX(),
                _buildSubCard(
                  context,
                  "students".tr(),
                  "33 ${'price_egp'.tr()}",
                  Icons.school_rounded,
                ).animate().fadeIn(delay: 400.ms).slideX(),
                _buildSubCard(
                  context,
                  "elderly".tr(),
                  "discounted".tr(),
                  Icons.elderly_rounded,
                ).animate().fadeIn(delay: 450.ms).slideX(),

                const SizedBox(height: 32),

                // Yearly
                _buildSectionHeader(
                  context,
                  "yearly_sub".tr(),
                ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
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
                        "yearly_price".tr(args: ['3175']),
                      ),
                      const Divider(height: 32),
                      _buildYearlyRow(
                        context,
                        "3 ${'line'.tr()}",
                        "yearly_price".tr(args: ['3660']),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 550.ms).scale(),
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
    String price,
  ) {
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
          Text(
            stations,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
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
    IconData icon,
  ) {
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
