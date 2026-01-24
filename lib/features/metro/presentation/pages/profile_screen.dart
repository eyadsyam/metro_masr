import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../bloc/theme_cubit.dart';
import '../../../../core/state/user_cubit.dart';
import '../../../../core/state/user_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "logout".tr(),
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        content: Text(
          "confirm_logout".tr(),
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("cancel".tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text("logout".tr()),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final userCubit = context.read<UserCubit>();
      await userCubit.signOut();

      if (mounted) {
        context.go('/login');
      }
    }
  }

  void _showEditDialog(BuildContext context, String currentName) {
    _nameController.text = currentName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "edit_profile".tr(),
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: "name".tr(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancel".tr()),
          ),
          FilledButton(
            onPressed: () {
              final newName = _nameController.text.trim();
              if (newName.isNotEmpty) {
                // For guest users, we could update the local name
                // For authenticated users, this would need a backend update
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("profile_update_coming_soon".tr()),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text("save".tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "profile_tab".tr(),
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // Layer 1: Background gradient (same as home screen)
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
            child: BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                if (state is UserLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is UserAuthenticated) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Avatar with online indicator
                        Stack(
                          children: [
                            Center(
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: theme.primaryColor,
                                backgroundImage: state.avatarUrl != null
                                    ? NetworkImage(state.avatarUrl!)
                                    : null,
                                child: state.avatarUrl == null
                                    ? Icon(
                                        state.isGuest
                                            ? Icons.person
                                            : Icons.account_circle,
                                        size: 60,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                            if (!state.isGuest)
                              Positioned(
                                bottom: 0,
                                right:
                                    MediaQuery.of(context).size.width / 2 - 70,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.scaffoldBackgroundColor,
                                      width: 3,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ).animate().scale(
                          curve: Curves.easeOutBack,
                          duration: 400.ms,
                        ),
                        const Gap(16),

                        // Name
                        Text(
                          state.name,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                        // Email or Guest Badge
                        if (state.email != null)
                          Text(
                            state.email!,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2)
                        else
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.orange,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                const Gap(6),
                                Text(
                                  "guest_mode".tr(),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 250.ms).scale(),

                        const Gap(32),

                        // Guest Mode Info Card
                        if (state.isGuest)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.cloud_off,
                                  size: 40,
                                  color: Colors.orange,
                                ),
                                const Gap(12),
                                Text(
                                  "guest_mode_info".tr(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const Gap(12),
                                FilledButton.icon(
                                  onPressed: () => context.go('/login'),
                                  icon: const Icon(Icons.login, size: 18),
                                  label: Text("sign_in_with_google".tr()),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: theme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                        if (state.isGuest) const Gap(24),

                        // Settings List
                        _tile(
                          context,
                          Icons.language,
                          "change_language".tr(),
                          trailing: _langSwitch(context),
                        ).animate().fadeIn(delay: 350.ms).slideX(),

                        _tile(
                          context,
                          Icons.dark_mode,
                          "dark_mode".tr(),
                          trailing: Switch(
                            value:
                                context.watch<ThemeCubit>().state ==
                                ThemeMode.dark,
                            onChanged: (v) =>
                                context.read<ThemeCubit>().toggleTheme(v),
                          ),
                        ).animate().fadeIn(delay: 400.ms).slideX(),

                        _tile(
                          context,
                          Icons.edit,
                          "edit_profile".tr(),
                          onTap: () => _showEditDialog(context, state.name),
                        ).animate().fadeIn(delay: 450.ms).slideX(),

                        _tile(
                          context,
                          Icons.bookmark,
                          "saved_routes".tr(),
                          onTap: () => context.push('/saved'),
                        ).animate().fadeIn(delay: 500.ms).slideX(),

                        const Gap(16),
                        Divider(color: theme.dividerColor),
                        const Gap(8),

                        _tile(
                          context,
                          Icons.logout,
                          "logout".tr(),
                          color: Colors.red,
                          onTap: () => _signOut(context),
                        ).animate().fadeIn(delay: 550.ms).slideX(),

                        const Gap(120),
                      ],
                    ),
                  );
                }

                // Unauthenticated state
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off, size: 80, color: Colors.grey),
                      const Gap(16),
                      Text(
                        "not_logged_in".tr(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const Gap(24),
                      FilledButton(
                        onPressed: () => context.go('/login'),
                        child: Text("go_to_login".tr()),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String label, {
    Widget? trailing,
    Color? color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? Theme.of(context).colorScheme.primary).withOpacity(
            0.15,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color:
              color ??
              (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary),
          size: 22,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      trailing:
          trailing ??
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  Widget _langSwitch(BuildContext context) {
    return DropdownButton<String>(
      underline: const SizedBox(),
      value: context.locale.languageCode,
      items: const [
        DropdownMenuItem(value: 'en', child: Text("English")),
        DropdownMenuItem(value: 'ar', child: Text("العربية")),
      ],
      onChanged: (val) {
        if (val != null) {
          context.setLocale(Locale(val));
        }
      },
    );
  }
}
