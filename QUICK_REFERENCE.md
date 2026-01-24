# Quick Reference - Metro Masr Authentication

## 🚀 Quick Start

### Run the App
```bash
flutter run
```

### Test Authentication
1. **Google Sign-In**: Click "Sign in with Google" → Select account
2. **Guest Mode**: Click "Continue as Guest" → Enter name

## 📱 Key Screens

### Home Screen
- **Location**: `lib/features/metro/presentation/pages/home_screen.dart`
- **Features**: Personalized greeting with user's first name
- **Greeting**: "Good Morning, Eyad" (dynamic based on time)

### Profile Screen
- **Location**: `lib/features/metro/presentation/pages/profile_screen.dart`
- **Features**:
  - User info display (avatar, name, email)
  - Guest mode indicator
  - Edit profile
  - Language switcher
  - Dark mode toggle
  - Sign out button

### Login Screen
- **Location**: `lib/features/auth/presentation/pages/login_screen.dart`
- **Features**:
  - Google Sign-In
  - Guest Mode
  - Beautiful animations
  - Same background as home

## 🔑 Key Components

### UserCubit
```dart
// Access anywhere in the app
final userCubit = context.read<UserCubit>();

// Get current user
final user = userCubit.currentUser;

// Check user type
if (userCubit.isGuest) { /* Guest */ }
if (userCubit.isAuthenticated) { /* Logged in */ }

// Actions
await userCubit.signInWithGoogle();
await userCubit.continueAsGuest('Name');
await userCubit.signOut();
await userCubit.saveRoute(...);
final routes = await userCubit.getSavedRoutes();
```

### User State
```dart
BlocBuilder<UserCubit, UserState>(
  builder: (context, state) {
    if (state is UserLoading) return Loading();
    if (state is UserAuthenticated) {
      return Text('Hello, ${state.name}');
    }
    if (state is UserUnauthenticated) return LoginButton();
    if (state is UserError) return Error(state.message);
    return SizedBox();
  },
)
```

## 🎨 Theme & Styling

### Background Gradient (Consistent Across App)
```dart
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
)
```

### Animations
```dart
Widget.animate()
  .fadeIn(delay: 300.ms)
  .slideY(begin: 0.2)
  .scale(begin: Offset(0.95, 0.95))
```

## 📝 Translation Keys

### English (`assets/translations/en.json`)
```json
{
  "welcome_morning": "Good Morning",
  "welcome_afternoon": "Good Afternoon",
  "welcome_evening": "Good Evening!",
  "guest_mode": "Guest Mode",
  "sign_in_with_google": "Sign in with Google",
  "logout": "Logout",
  "confirm_logout": "Are you sure you want to sign out?",
  "edit_profile": "Edit Profile",
  "saved_routes": "Saved Routes"
}
```

### Usage
```dart
Text('welcome_morning'.tr())
Text('logout'.tr())
```

## 🔄 App Flow

### First Launch
```
Splash → Onboarding → Language/Theme → Permissions → Login → Home
```

### Subsequent Launches
```
Splash → Login (if not logged in) → Home
```

### Authenticated User
```
Splash → Auto-login → Home
```

## 🛠️ Common Tasks

### Add New Screen with Auth
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state is UserAuthenticated) {
          return Text('Hello, ${state.name}');
        }
        return LoginPrompt();
      },
    );
  }
}
```

### Require Authentication
```dart
void _doSomething(BuildContext context) {
  final userCubit = context.read<UserCubit>();
  
  if (!userCubit.isAuthenticated) {
    // Show login prompt
    context.go('/login');
    return;
  }
  
  // Proceed with action
}
```

### Save Route (Works for Both Guest & Auth)
```dart
await context.read<UserCubit>().saveRoute(
  fromStation: 'Sadat',
  toStation: 'Giza',
  path: ['Sadat', 'Opera', 'Giza'],
  totalStations: 3,
  price: 8.0,
  estimatedTime: 15,
);
```

## 📊 File Structure

```
lib/
├── core/
│   ├── config/
│   │   └── app_config.dart          # API keys & config
│   ├── models/
│   │   └── app_user.dart            # User model
│   ├── services/
│   │   ├── auth_service.dart        # Authentication
│   │   ├── connectivity_service.dart # Network monitoring
│   │   ├── local_storage_service.dart # Caching
│   │   └── data_sync_service.dart   # Cloud sync
│   └── state/
│       ├── user_cubit.dart          # User state management
│       └── user_state.dart          # State definitions
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       └── pages/
│   │           └── login_screen.dart
│   └── metro/
│       └── presentation/
│           └── pages/
│               ├── home_screen.dart
│               └── profile_screen.dart
├── injection_container.dart         # Dependency injection
└── main.dart                        # App entry point
```

## 🐛 Debugging

### Check User State
```dart
print(context.read<UserCubit>().state);
print(context.read<UserCubit>().currentUser);
```

### Check Connectivity
```dart
final connectivity = di.sl<ConnectivityService>();
print('Online: ${connectivity.isConnected}');
```

### View Logs
```bash
flutter logs
```

## ✅ Checklist Before Testing

- [ ] Run `flutter pub get`
- [ ] Set up Supabase database (run `supabase_setup.sql`)
- [ ] Enable Google OAuth in Supabase
- [ ] Configure Google Cloud Console
- [ ] Test on real device for Google Sign-In
- [ ] Test offline mode
- [ ] Test guest mode
- [ ] Test sign out

## 🎯 Next Steps

1. **Backend Setup**: Run SQL script in Supabase
2. **Google OAuth**: Enable in Supabase dashboard
3. **Testing**: Test all authentication flows
4. **Deployment**: Build and release

---

**Quick Help**:
- Documentation: See `AUTHENTICATION_GUIDE.md`
- Examples: See `INTEGRATION_EXAMPLES.md`
- Setup: See `SETUP_CHECKLIST.md`
- Architecture: See `ARCHITECTURE_DIAGRAMS.md`
