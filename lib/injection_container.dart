import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'core/config/app_config.dart';
import 'core/services/auth_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/data_sync_service.dart';
import 'core/state/user_cubit.dart';

import 'features/metro/data/datasources/metro_database.dart';
import 'features/metro/data/datasources/database_seeder.dart';
import 'features/metro/data/datasources/station_dao.dart';
import 'features/metro/data/repositories/metro_repository_impl.dart';
import 'features/metro/domain/repositories/metro_repository.dart';
import 'features/metro/domain/services/pricing_service.dart';
import 'features/metro/domain/usecases/find_shortest_path_usecase.dart';
import 'features/metro/domain/usecases/get_all_stations_usecase.dart';
import 'features/metro/presentation/bloc/metro_cubit.dart';
import 'features/metro/presentation/bloc/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ========== Core Services ==========

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Google Sign-In (CRITICAL FIX)
  sl.registerLazySingleton<GoogleSignIn>(() {
    return GoogleSignIn(
      // Android requires serverClientId (The Web ID).
      // Do NOT pass clientId for Android.
      serverClientId: AppConfig.googleWebClientId,

      // iOS requires clientId.
      clientId: Platform.isIOS ? AppConfig.googleIosClientId : null,

      scopes: ['email', 'profile'],
    );
  });

  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // Connectivity Service
  final connectivityService = ConnectivityService();
  await connectivityService.initialize();
  sl.registerSingleton<ConnectivityService>(connectivityService);

  // Local Storage Service
  sl.registerLazySingleton<LocalStorageService>(
    () => LocalStorageService(prefs: sl()),
  );

  // Auth Service
  sl.registerLazySingleton<AuthService>(
    () => AuthService(supabase: sl(), googleSignIn: sl(), prefs: sl()),
  );

  // Data Sync Service
  sl.registerLazySingleton<DataSyncService>(
    () =>
        DataSyncService(supabase: sl(), localStorage: sl(), connectivity: sl()),
  );

  // ========== State Management ==========

  // User Cubit
  sl.registerFactory<UserCubit>(
    () => UserCubit(
      authService: sl(),
      localStorage: sl(),
      dataSyncService: sl(),
      connectivityService: sl(),
    ),
  );

  // ========== Features - Metro ==========

  // Bloc
  sl.registerFactory(
    () =>
        MetroCubit(getAllStationsUseCase: sl(), findShortestPathUseCase: sl()),
  );
  sl.registerFactory(() => ThemeCubit());

  // UseCases
  sl.registerLazySingleton(() => GetAllStationsUseCase(sl()));
  sl.registerLazySingleton(() => FindShortestPathUseCase(sl()));
  sl.registerLazySingleton(() => PricingService());

  // Repository
  sl.registerLazySingleton<IMetroRepository>(() => MetroRepositoryImpl(sl()));

  // Data sources
  final database = await $FloorAppDatabase
      .databaseBuilder(AppConfig.localDatabaseName)
      .build();
  sl.registerSingleton<AppDatabase>(database);

  sl.registerLazySingleton<StationDao>(() => sl<AppDatabase>().stationDao);

  sl.registerLazySingleton(() => DatabaseSeeder(sl()));
}
