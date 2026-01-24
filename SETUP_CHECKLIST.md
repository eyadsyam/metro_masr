# Metro Masr - Authentication Setup Checklist

## ✅ Code Implementation (COMPLETED)

- [x] Core configuration with real credentials
- [x] User model for guest and authenticated users
- [x] Authentication service with Google Sign-In
- [x] Connectivity service for offline detection
- [x] Local storage service for caching
- [x] Data sync service for cloud backup
- [x] User state management with Cubit
- [x] Login screen with beautiful UI
- [x] Dependency injection setup
- [x] Main app integration with routing
- [x] All dependencies installed

## 📋 Supabase Configuration (TODO)

### Step 1: Database Setup
- [ ] Go to your Supabase project dashboard
- [ ] Navigate to SQL Editor
- [ ] Run the `supabase_setup.sql` script
- [ ] Verify tables created: `profiles`, `saved_routes`
- [ ] Verify RLS policies are enabled

### Step 2: Enable Google OAuth
- [ ] Go to Authentication > Providers in Supabase
- [ ] Enable Google provider
- [ ] Add your Google Client ID: `381646113575-h9at947lgdtpi6n0qu0lhbt205p0lv1t.apps.googleusercontent.com`
- [ ] Add your Google Client Secret (from Google Cloud Console)
- [ ] Save the configuration

### Step 3: Configure Redirect URLs
- [ ] In Supabase, go to Authentication > URL Configuration
- [ ] Add redirect URLs:
  - `https://blcacbznktuixbbjaivb.supabase.co/auth/v1/callback`
  - Your app's custom URL scheme (if using deep links)

## 🔧 Google Cloud Console Setup (TODO)

### Step 1: Create/Configure OAuth Client
- [ ] Go to [Google Cloud Console](https://console.cloud.google.com)
- [ ] Navigate to APIs & Services > Credentials
- [ ] Verify OAuth 2.0 Client ID exists for Web application
- [ ] Client ID should be: `381646113575-h9at947lgdtpi6n0qu0lhbt205p0lv1t.apps.googleusercontent.com`

### Step 2: Configure Authorized Redirect URIs
- [ ] Add Supabase callback URL:
  - `https://blcacbznktuixbbjaivb.supabase.co/auth/v1/callback`

### Step 3: Android Configuration (if deploying to Android)
- [ ] Create OAuth 2.0 Client ID for Android
- [ ] Get SHA-1 fingerprint:
  ```bash
  cd android
  ./gradlew signingReport
  ```
- [ ] Add SHA-1 to Google Cloud Console
- [ ] Add package name: `com.example.metro_masr` (or your actual package)

### Step 4: iOS Configuration (if deploying to iOS)
- [ ] Create OAuth 2.0 Client ID for iOS
- [ ] Add Bundle ID from Xcode
- [ ] Configure URL schemes in Info.plist

## 📱 Android Platform Setup (TODO)

### Step 1: Update build.gradle
File: `android/app/build.gradle.kts`
```kotlin
android {
    defaultConfig {
        minSdk = 21  // Ensure minimum SDK is 21
    }
}
```

### Step 2: Add Internet Permission
File: `android/app/src/main/AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### Step 3: Configure Deep Links (Optional)
Add intent filter for deep links if needed.

## 🍎 iOS Platform Setup (TODO)

### Step 1: Update Info.plist
File: `ios/Runner/Info.plist`
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.381646113575-h9at947lgdtpi6n0qu0lhbt205p0lv1t</string>
        </array>
    </dict>
</array>
```

### Step 2: Update Podfile
Ensure minimum iOS version:
```ruby
platform :ios, '12.0'
```

## 🧪 Testing Checklist

### Test Scenario 1: Google Sign-In (Online)
- [ ] Open app
- [ ] Click "Sign in with Google"
- [ ] Select Google account
- [ ] Verify redirect to home screen
- [ ] Check profile created in Supabase
- [ ] Verify user name displayed in app

### Test Scenario 2: Guest Mode
- [ ] Open app
- [ ] Click "Continue as Guest"
- [ ] Enter guest name
- [ ] Verify redirect to home screen
- [ ] Save a route
- [ ] Close and reopen app
- [ ] Verify guest data persists

### Test Scenario 3: Offline Mode
- [ ] Sign in with Google (online)
- [ ] Save some routes
- [ ] Turn off internet
- [ ] Close and reopen app
- [ ] Verify app loads with cached data
- [ ] Verify routes are visible
- [ ] Turn on internet
- [ ] Verify data syncs

### Test Scenario 4: Sign Out
- [ ] Sign in (Google or Guest)
- [ ] Navigate to profile/settings
- [ ] Click sign out
- [ ] Verify redirect to login screen
- [ ] Verify local data cleared

### Test Scenario 5: Route Management
- [ ] Sign in as authenticated user
- [ ] Save multiple routes
- [ ] Verify routes appear in Supabase
- [ ] Delete a route
- [ ] Verify deletion in Supabase
- [ ] Repeat as guest user
- [ ] Verify guest routes stay local

## 🔍 Verification Commands

### Check Flutter Setup
```bash
flutter doctor
flutter pub get
flutter analyze
```

### Test Build (Android)
```bash
flutter build apk --debug
```

### Test Build (iOS)
```bash
flutter build ios --debug
```

### Run on Device
```bash
flutter run
```

## 📊 Monitoring & Debugging

### Supabase Dashboard
- [ ] Monitor Authentication logs
- [ ] Check Database tables for new entries
- [ ] Review API usage

### App Logs
- [ ] Check console for authentication flows
- [ ] Monitor network requests
- [ ] Verify error handling

### Common Issues & Solutions

**Issue**: Google Sign-In fails
- **Solution**: Check SHA-1 fingerprint is added to Google Cloud Console
- **Solution**: Verify redirect URIs match exactly

**Issue**: Profile not created in Supabase
- **Solution**: Check RLS policies are correct
- **Solution**: Verify Supabase credentials in AppConfig

**Issue**: Offline mode not working
- **Solution**: Ensure SharedPreferences is working
- **Solution**: Check ConnectivityService initialization

**Issue**: Guest data not persisting
- **Solution**: Verify SharedPreferences permissions
- **Solution**: Check local storage service implementation

## 🚀 Deployment Checklist

### Before Production
- [ ] Move API keys to environment variables
- [ ] Enable error tracking (Sentry, Firebase Crashlytics)
- [ ] Add analytics (Firebase Analytics, Mixpanel)
- [ ] Test on multiple devices
- [ ] Test on different network conditions
- [ ] Perform security audit
- [ ] Review RLS policies in Supabase
- [ ] Set up backup strategy

### Production Environment
- [ ] Use production Supabase project
- [ ] Use production Google OAuth credentials
- [ ] Enable rate limiting
- [ ] Set up monitoring alerts
- [ ] Configure CDN for assets
- [ ] Enable HTTPS only

## 📚 Documentation Files

- [x] `AUTHENTICATION_GUIDE.md` - Complete architecture documentation
- [x] `IMPLEMENTATION_SUMMARY.md` - What was implemented
- [x] `INTEGRATION_EXAMPLES.md` - Code examples for integration
- [x] `supabase_setup.sql` - Database setup script
- [x] This checklist

## 🎯 Next Steps

1. **Immediate**:
   - Run `supabase_setup.sql` in Supabase
   - Enable Google OAuth in Supabase
   - Test authentication flows

2. **Short-term**:
   - Integrate authentication into existing screens
   - Add user profile screen
   - Implement sign-out functionality

3. **Long-term**:
   - Add more OAuth providers (Facebook, Apple)
   - Implement email/password authentication
   - Add account deletion feature
   - Implement data export feature

## ✨ Success Criteria

Your authentication system is ready when:
- [x] Code compiles without errors
- [ ] Google Sign-In works on device
- [ ] Guest mode works correctly
- [ ] Offline mode loads cached data
- [ ] Routes sync to Supabase for authenticated users
- [ ] Guest routes stay local
- [ ] Sign out clears data properly
- [ ] App handles network changes gracefully

## 📞 Support Resources

- **Supabase Docs**: https://supabase.com/docs/guides/auth
- **Google Sign-In Flutter**: https://pub.dev/packages/google_sign_in
- **Flutter BLoC**: https://bloclibrary.dev
- **Go Router**: https://pub.dev/packages/go_router

---

**Status**: Implementation Complete ✅
**Next Action**: Configure Supabase Database
**Estimated Time**: 15-30 minutes

Good luck! 🚀
