/// Application Configuration
/// Contains all API keys and configuration constants
class AppConfig {
  // =========================================================
  // Supabase Configuration
  // =========================================================
  static const String supabaseUrl = 'https://blcacbznktuixbbjaivb.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJsY2FjYnpua3R1aXhiYmphaXZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkwNzk3MDMsImV4cCI6MjA4NDY1NTcwM30.9FbSLecMMyj0-WuXgShURLLO2q4Zm1Bxck8cjtW2x3I';

  // =========================================================
  // Google Sign-In Configuration
  // =========================================================

  /// 🌐 Google Web Client ID
  /// REQUIRED for Android initialization (passed as serverClientId).
  static const String googleWebClientId =
      '381646113575-bvl4no1suk49fgfas3rm4dmeu7g9omlg.apps.googleusercontent.com';

  /// 🍎 Google iOS Client ID
  /// REQUIRED for iOS initialization (passed as clientId).
  /// Leave empty if not yet configured.
  static const String googleIosClientId = '';

  // =========================================================
  // Local Storage Keys
  // =========================================================
  static const String keyGuestName = 'guest_name';
  static const String keyIsGuest = 'is_guest';
  static const String keyLastSyncTime = 'last_sync_time';
  static const String keyOnboardingCompleted = 'onboarding_completed';

  // =========================================================
  // Database
  // =========================================================
  static const String localDatabaseName = 'metro_guide.db';

  // =========================================================
  // Supabase Tables
  // =========================================================
  static const String profilesTable = 'profiles';
  static const String savedRoutesTable = 'saved_routes';
}
