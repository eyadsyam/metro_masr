import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../models/app_user.dart';

/// Authentication Service
/// Handles Google Sign-In, Guest Mode, and Supabase authentication
class AuthService {
  final SupabaseClient _supabase;
  final GoogleSignIn _googleSignIn;
  final SharedPreferences _prefs;

  AuthService({
    required SupabaseClient supabase,
    required GoogleSignIn googleSignIn,
    required SharedPreferences prefs,
  }) : _supabase = supabase,
       _googleSignIn = googleSignIn,
       _prefs = prefs;

  /// Get current user (Guest or Authenticated)
  Future<AppUser?> getCurrentUser() async {
    try {
      // Check if user is guest
      final isGuest = _prefs.getBool(AppConfig.keyIsGuest) ?? false;

      if (isGuest) {
        final guestName = _prefs.getString(AppConfig.keyGuestName);
        if (guestName != null && guestName.isNotEmpty) {
          return AppUser.guest(name: guestName);
        }
        return null;
      }

      // Check Supabase session
      final session = _supabase.auth.currentSession;
      if (session != null) {
        final user = session.user;

        // Fetch profile from Supabase
        final profile = await _getOrCreateProfile(
          userId: user.id,
          email: user.email ?? '',
          fullName:
              user.userMetadata?['full_name'] as String? ??
              user.userMetadata?['name'] as String? ??
              'User',
          avatarUrl:
              user.userMetadata?['avatar_url'] as String? ??
              user.userMetadata?['picture'] as String?,
        );

        return AppUser.fromSupabaseProfile(profile);
      }

      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  /// Sign in with Google
  Future<AppUser> signInWithGoogle() async {
    try {
      // 1. Sign out first to ensure clean state
      await _googleSignIn.signOut();

      // 2. Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google Sign-In was cancelled');
      }

      // 3. Get authentication details (tokens)
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('Failed to get ID token from Google');
      }

      // 4. Sign in to Supabase with Google credentials
      final AuthResponse response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw Exception('Failed to authenticate with Supabase');
      }

      final user = response.user!;

      // 5. Create or update profile in Supabase
      final profile = await _getOrCreateProfile(
        userId: user.id,
        email: user.email ?? googleUser.email,
        fullName:
            user.userMetadata?['full_name'] as String? ??
            user.userMetadata?['name'] as String? ??
            googleUser.displayName ??
            'User',
        avatarUrl:
            user.userMetadata?['avatar_url'] as String? ??
            user.userMetadata?['picture'] as String? ??
            googleUser.photoUrl,
      );

      // 6. Clear guest mode
      await _clearGuestMode();

      return AppUser.fromSupabaseProfile(profile);
    } catch (e) {
      print('Google Sign-In error: $e');

      // Check for Network Error (ApiException: 7)
      if (e.toString().contains('ApiException: 7') ||
          e.toString().contains('network_error') ||
          e.toString().contains('SocketException')) {
        throw Exception(
          'Network Error: Please check your internet connection and try again.',
        );
      }

      // Check for Developer Error (ApiException: 10) - SHA-1 Missing
      if (e.toString().contains('ApiException: 10')) {
        throw Exception(
          'Configuration Error: SHA-1 Fingerprint mismatch. Please contact support.',
        );
      }

      // Google Sign-In Cancelled
      if (e.toString().toLowerCase().contains('cancelled')) {
        throw Exception('Sign in cancelled');
      }

      rethrow;
    }
  }

  /// Continue as Guest
  Future<AppUser> continueAsGuest(String guestName) async {
    try {
      if (guestName.trim().isEmpty) {
        throw Exception('Guest name cannot be empty');
      }

      // Save guest info locally
      await _prefs.setString(AppConfig.keyGuestName, guestName.trim());
      await _prefs.setBool(AppConfig.keyIsGuest, true);

      // Sign out from Supabase if logged in
      await _supabase.auth.signOut();

      return AppUser.guest(name: guestName.trim());
    } catch (e) {
      print('Guest mode error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();

      // Sign out from Supabase
      await _supabase.auth.signOut();

      // Clear guest mode
      await _clearGuestMode();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  /// Check if user is authenticated (not guest)
  bool isAuthenticated() {
    final isGuest = _prefs.getBool(AppConfig.keyIsGuest) ?? false;
    return !isGuest && _supabase.auth.currentSession != null;
  }

  /// Check if user is in guest mode
  bool isGuestMode() {
    return _prefs.getBool(AppConfig.keyIsGuest) ?? false;
  }

  /// Get or create user profile in Supabase
  Future<Map<String, dynamic>> _getOrCreateProfile({
    required String userId,
    required String email,
    required String fullName,
    String? avatarUrl,
  }) async {
    try {
      // Try to fetch existing profile
      final response = await _supabase
          .from(AppConfig.profilesTable)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        // Profile exists, update it if needed
        await _supabase
            .from(AppConfig.profilesTable)
            .update({
              'email': email,
              'full_name': fullName,
              'avatar_url': avatarUrl,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);

        return {
          'id': userId,
          'email': email,
          'full_name': fullName,
          'avatar_url': avatarUrl,
        };
      } else {
        // Create new profile
        final newProfile = {
          'id': userId,
          'email': email,
          'full_name': fullName,
          'avatar_url': avatarUrl,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        await _supabase.from(AppConfig.profilesTable).insert(newProfile);

        return newProfile;
      }
    } catch (e) {
      print('Error managing profile: $e');
      // Return basic profile even if database operation fails
      return {
        'id': userId,
        'email': email,
        'full_name': fullName,
        'avatar_url': avatarUrl,
      };
    }
  }

  /// Clear guest mode data
  Future<void> _clearGuestMode() async {
    await _prefs.remove(AppConfig.keyGuestName);
    await _prefs.setBool(AppConfig.keyIsGuest, false);
  }

  /// Listen to auth state changes
  Stream<AppUser?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.asyncMap((data) async {
      final session = data.session;

      if (session != null) {
        final user = session.user;
        final profile = await _getOrCreateProfile(
          userId: user.id,
          email: user.email ?? '',
          fullName:
              user.userMetadata?['full_name'] as String? ??
              user.userMetadata?['name'] as String? ??
              'User',
          avatarUrl:
              user.userMetadata?['avatar_url'] as String? ??
              user.userMetadata?['picture'] as String?,
        );
        return AppUser.fromSupabaseProfile(profile);
      }

      return null;
    });
  }
}
