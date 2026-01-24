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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "packages".tr(),
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    "packages_subtitle".tr(),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16, // Increased size
                      fontWeight: FontWeight.w500, // Increased weight
                      color: colorScheme
                          .onSurface, // Removed opacity for better visibility
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 24),

                // Daily Tickets (Stacked Vertically)
                _buildSectionHeader(
                  context,
                  "daily_tickets".tr(),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),

                ..._ticketPricing.map((ticket) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildTicketCardWide(
                      context,
                      ticket,
                      _ticketPricing.indexOf(ticket),
                    ),
                  );
                }),

                const SizedBox(height: 32),

                // Monthly Subscriptions
                _buildSectionHeader(
                  context,
                  "monthly_subscriptions".tr(),
                  subtitle: "60_rides_desc".tr(),
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                ..._monthlySubscriptions.map(
                  (item) => _buildSubscriptionCard(
                    context,
                    zone: item['zone'].toString().tr(),
                    prices: [
                      _PriceItem(
                        label: 'public_price'.tr(),
                        price: item['price_public'],
                        color: isDark ? Colors.cyanAccent : theme.primaryColor,
                      ), // High contrast
                      _PriceItem(
                        label: 'military_price'.tr(),
                        price: item['price_military'],
                        color: Colors.orange[700]!,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Quarterly Subscriptions
                _buildSectionHeader(
                  context,
                  "quarterly_subscriptions".tr(),
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                ..._quarterlySubscriptions.map(
                  (item) => _buildSubscriptionCard(
                    context,
                    zone: item['zone'].toString().tr(),
                    prices: [
                      _PriceItem(
                        label: 'public_price'.tr(),
                        price: item['price_public'],
                        color: isDark ? Colors.cyanAccent : theme.primaryColor,
                      ),
                      _PriceItem(
                        label: 'military_price'.tr(),
                        price: item['price_military'],
                        color: Colors.orange[700]!,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Yearly
                _buildSectionHeader(
                  context,
                  "yearly_sub".tr(),
                ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withOpacity(0.2),
                    ),
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
                      _buildYearlyRow(
                        context,
                        "2 ${'line'.tr()}",
                        "4235 ${'price_egp'.tr()}",
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(),
                      ),
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
                ..._studentSpecialSubscriptions.map(
                  (item) => _buildSubscriptionCard(
                    context,
                    zone: item['zone'].toString().tr(),
                    prices: [
                      _PriceItem(
                        label: 'students_label'.tr(),
                        price: item['price_student'],
                        color: Colors.blueAccent,
                      ),
                      _PriceItem(
                        label: 'special_needs'.tr(),
                        price: item['price_special'],
                        color: Colors.green,
                      ),
                    ],
                  ),
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
                  separatorBuilder: (context, index) => const Gap(12),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const Gap(12),
                          Expanded(
                            child: Text(
                              _requirements[index].tr(),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
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

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        if (subtitle != null) ...[
          const Gap(4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14, // Increased size
                color: Theme.of(context).textTheme.bodyMedium?.color
                    ?.withOpacity(0.8), // Better contrast
              ),
            ),
          ),
        ],
        const Gap(12),
      ],
    );
  }

  Widget _buildTicketCard(
    BuildContext context,
    Map<String, dynamic> data,
    int index,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final colors = [
      Colors.amber.shade700, // 9 stations
      Colors.green.shade600, // 16 stations
      Colors.blue.shade600, // 23 stations
      const Color(0xFFD81B60), // +23 stations (Pink/Purple)
    ];
    final color = colors[index % colors.length];

    return Container(
      width: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.confirmation_number_rounded,
              color: color,
              size: 20,
            ),
          ),
          const Spacer(),
          Text(
            data['title'].toString().tr(),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withOpacity(0.8),
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Gap(8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "${data['price_public']}",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          Text(
            'price_egp'.tr(),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  // New Wide Ticket Card for Stacked Layout
  Widget _buildTicketCardWide(
    BuildContext context,
    Map<String, dynamic> data,
    int index,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final colors = [
      Colors.amber.shade700,
      Colors.green.shade600,
      Colors.blue.shade600,
      const Color(0xFFD81B60),
    ];
    final color = colors[index % colors.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.confirmation_number_rounded,
              color: color,
              size: 24,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Text(
              data['title'].toString().tr(),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${data['price_public']}",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                'price_egp'.tr(),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context, {
    required String zone,
    required List<_PriceItem> prices,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            zone,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Gap(12),
          Row(
            children: prices
                .map(
                  (p) => Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.label,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          "${p.price} ${'price_egp'.tr()}",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: p.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyRow(BuildContext context, String title, String price) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: theme.primaryColor,
              ),
            ),
            const Gap(12),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        Text(
          price,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
            fontSize: 18,
          ),
        ),
      ],
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

class _PriceItem {
  final String label;
  final int price;
  final Color color;

  _PriceItem({required this.label, required this.price, required this.color});
}
