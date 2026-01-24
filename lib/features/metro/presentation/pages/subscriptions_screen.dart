import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ...

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  // Data extracted from official Cairo Metro website
  static final List<Map<String, dynamic>> _ticketPricing = [
    {
      'title': 'ticket_9_stations',
      'price_public': 8,
      'price_senior': 4,
      'price_special': 5,
    },
    {
      'title': 'ticket_16_stations',
      'price_public': 10,
      'price_senior': 5,
      'price_special': 5,
    },
    {
      'title': 'ticket_23_stations',
      'price_public': 15,
      'price_senior': 8,
      'price_special': 5,
    },
    {
      'title': 'ticket_plus_39_stations',
      'price_public': 20,
      'price_senior': 10,
      'price_special': 5,
    },
  ];

  static final List<Map<String, dynamic>> _monthlySubscriptions = [
    {'zone': 'zone_1', 'rides': 60, 'price_public': 310, 'price_military': 240},
    {'zone': 'zone_2', 'rides': 60, 'price_public': 365, 'price_military': 300},
    {
      'zone': 'zone_3_4',
      'rides': 60,
      'price_public': 425,
      'price_military': 375,
    },
    {
      'zone': 'zone_5_6',
      'rides': 60,
      'price_public': 600,
      'price_military': 500,
    },
  ];

  static final List<Map<String, dynamic>> _quarterlySubscriptions = [
    {
      'zone': 'zone_1',
      'rides': 180,
      'price_public': 835,
      'price_military': 720,
    },
    {
      'zone': 'zone_2',
      'rides': 180,
      'price_public': 990,
      'price_military': 900,
    },
    {
      'zone': 'zone_3_4',
      'rides': 180,
      'price_public': 1250,
      'price_military': 1125,
    },
    {
      'zone': 'zone_5_6',
      'rides': 180,
      'price_public': 1670,
      'price_military': 1500,
    },
  ];

  // Quarterly Students & Special Needs (180 rides)
  static final List<Map<String, dynamic>> _studentSpecialSubscriptions = [
    {
      'zone': 'zone_1', // 25 stations
      'price_student': 150,
      'price_special': 150,
    },
    {
      'zone': 'zone_2', // 39 stations
      'price_student': 200,
      'price_special': 200,
    },
    {
      'zone': 'zone_3_4', // All lines
      'price_student': 250,
      'price_special': 250,
    },
    {
      'zone': 'zone_5_6', // +4 zones
      'price_student': 300,
      'price_special': 300,
    },
  ];

  static final List<String> _requirements = [
    'req_form',
    'req_photos',
    'req_id_card',
    'req_student_proof', // e.g. stamped form
  ];

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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Text(
                    "packages_subtitle".tr(),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 16),

                // Daily Tickets
                _buildSectionHeader(
                  context,
                  "daily_tickets".tr(),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),

                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _ticketPricing.length,
                    separatorBuilder: (context, index) => const Gap(16),
                    itemBuilder: (context, index) {
                      return _buildTicketCard(
                        context,
                        _ticketPricing[index],
                        index,
                      );
                    },
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 32),

                // Monthly Subscriptions
                _buildSectionHeader(
                  context,
                  "monthly_subscriptions".tr(),
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                _buildSubscriptionTable(context, _monthlySubscriptions),

                const SizedBox(height: 32),

                // Quarterly Subscriptions
                _buildSectionHeader(
                  context,
                  "quarterly_subscriptions".tr(),
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                _buildSubscriptionTable(context, _quarterlySubscriptions),

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
                ).animate().fadeIn(delay: 550.ms).scale(),
                const Gap(32),

                // Students & Special Needs (Custom Card)
                _buildSectionHeader(
                  context,
                  "students_and_special".tr(),
                ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                _buildSpecialSubscriptionTable(
                  context,
                  _studentSpecialSubscriptions,
                ),

                const Gap(32),

                // Requirements
                _buildSectionHeader(
                  context,
                  "requirements".tr(),
                ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _requirements.length,
                  separatorBuilder: (context, index) => const Gap(8),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: colorScheme.primary,
                          ),
                          const Gap(12),
                          Expanded(
                            child: Text(
                              _requirements[index].tr(),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Gap(100),
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
    Map<String, dynamic> data,
    int index,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = [
      Colors.yellow.shade700, // 9 stations
      Colors.green, // 16 stations
      Colors.blue, // 23 stations
      Colors.pink, // +23 stations
    ];

    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors[index % colors.length].withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors[index % colors.length].withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors[index % colors.length],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const Spacer(),
          Text(
            data['title'].toString().tr(),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Gap(4),
          Text(
            "${data['price_public']} ${'price_egp'.tr()}",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors[index % colors.length],
            ),
          ),
        ],
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

  Widget _buildSubscriptionTable(
    BuildContext context,
    List<Map<String, dynamic>> data,
  ) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "zone_title".tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      "public_price".tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      "military_price".tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Rows
          ...data.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      item['zone'].toString().tr(),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        "${item['price_public']} ${'price_egp'.tr()}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        "${item['price_military']} ${'price_egp'.tr()}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSpecialSubscriptionTable(
    BuildContext context,
    List<Map<String, dynamic>> data,
  ) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "zone_title".tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      "students_label".tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      "special_needs".tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...data.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      item['zone'].toString().tr(),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        "${item['price_student']} ${'price_egp'.tr()}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        "${item['price_special']} ${'price_egp'.tr()}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
