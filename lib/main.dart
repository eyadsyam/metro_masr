import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'injection_container.dart' as di;
import 'core/state/user_cubit.dart';
import 'core/state/user_state.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/metro/presentation/bloc/metro_cubit.dart';
import 'features/metro/presentation/pages/main_layout.dart';
import 'features/metro/presentation/pages/route_details_screen.dart';
import 'features/metro/presentation/pages/map_screen.dart';
import 'features/metro/presentation/pages/subscriptions_screen.dart';
import 'features/metro/presentation/pages/saved_routes_screen.dart';
import 'features/metro/presentation/pages/place_search_screen.dart';
import 'features/metro/data/datasources/database_seeder.dart';
import 'features/metro/presentation/theme/metro_theme.dart';
import 'features/metro/presentation/bloc/theme_cubit.dart';
import 'features/metro/presentation/pages/splash_screen.dart';
import 'features/metro/presentation/pages/onboarding/onboarding_screen.dart';
import 'features/metro/presentation/pages/onboarding/language_theme_screen.dart';
import 'features/metro/presentation/pages/onboarding/permission_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  if (kIsWeb) {
    // Initialize for Web
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Initialize for Windows/Linux/Mac
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize dependency injection (includes Supabase initialization)
  await di.init();

  // Check Onboarding Status
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingCompleted =
      prefs.getBool('onboarding_completed') ?? false;

  // Detect system settings on first launch
  if (!prefs.containsKey('first_launch_done')) {
    // Detect system locale
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final supportedLocales = [const Locale('en'), const Locale('ar')];
    final initialLocale =
        supportedLocales.any((l) => l.languageCode == systemLocale.languageCode)
        ? systemLocale.languageCode
        : 'en';

    // Detect system theme
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDark = brightness == Brightness.dark;

    // Save initial settings
    await prefs.setString('initial_locale', initialLocale);
    await prefs.setBool('initial_dark_mode', isDark);
    await prefs.setBool('first_launch_done', true);
  }

  // Seed Database
  try {
    await di.sl<DatabaseSeeder>().seed();
  } catch (e) {
    print('Seeding error: $e');
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MyApp(onboardingCompleted: onboardingCompleted),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool onboardingCompleted;
  const MyApp({super.key, required this.onboardingCompleted});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;
  late final UserCubit _userCubit;

  @override
  void initState() {
    super.initState();

    // Initialize UserCubit
    _userCubit = di.sl<UserCubit>();
    _userCubit.initialize();

    // Setup router with authentication redirect
    _router = GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final userState = _userCubit.state;
        final isOnLoginPage = state.matchedLocation == '/login';
        final isOnSplash = state.matchedLocation == '/splash';
        final isOnOnboarding =
            state.matchedLocation.startsWith('/onboarding') ||
            state.matchedLocation == '/language-theme' ||
            state.matchedLocation == '/permissions';

        // Allow splash and onboarding screens
        if (isOnSplash || isOnOnboarding) {
          return null;
        }

        // If user is not authenticated and not on login page, redirect to login
        if (userState is UserUnauthenticated && !isOnLoginPage) {
          return '/login';
        }

        // If user is authenticated and on login page, redirect to home
        if (userState is UserAuthenticated && isOnLoginPage) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) {
            final nextRoute = widget.onboardingCompleted
                ? '/login'
                : '/onboarding';
            return SplashScreen(nextRoute: nextRoute);
          },
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(path: '/', builder: (context, state) => const MainLayout()),
        GoRoute(
          path: '/details',
          builder: (context, state) => const RouteDetailsScreen(),
        ),
        GoRoute(path: '/map', builder: (context, state) => const MapScreen()),
        GoRoute(
          path: '/subscriptions',
          builder: (context, state) => const SubscriptionsScreen(),
        ),
        GoRoute(
          path: '/saved',
          builder: (context, state) => const SavedRoutesScreen(),
        ),
        GoRoute(
          path: '/place-search',
          builder: (context, state) {
            final isSource = state.extra as bool? ?? true;
            return PlaceSearchScreen(isSource: isSource);
          },
        ),
        // Onboarding Routes
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/language-theme',
          builder: (context, state) => const LanguageThemeScreen(),
        ),
        GoRoute(
          path: '/permissions',
          builder: (context, state) => const PermissionScreen(),
        ),
      ],
      refreshListenable: GoRouterRefreshStream(_userCubit.stream),
    );
  }

  @override
  void dispose() {
    _userCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _userCubit),
        BlocProvider(create: (_) => di.sl<MetroCubit>()),
        BlocProvider(create: (_) => di.sl<ThemeCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          final isArabic = context.locale.languageCode == 'ar';
          return Directionality(
            textDirection: isArabic
                ? ui.TextDirection.rtl
                : ui.TextDirection.ltr,
            child: MaterialApp.router(
              title: 'Metro Masr',
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              theme: MetroTheme.getLightTheme(context.locale),
              darkTheme: MetroTheme.getDarkTheme(context.locale),
              themeMode: themeMode,
              debugShowCheckedModeBanner: false,
              routerConfig: _router,
            ),
          );
        },
      ),
    );
  }
}

/// Helper class to refresh GoRouter when UserCubit state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
