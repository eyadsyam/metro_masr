# Remaining Fixes - Metro Guide App

## Status: IN PROGRESS

### ✅ COMPLETED
1. **Save/Unsave Toggle** - Fixed in route_details_screen.dart
   - Now properly uses UserCubit for both save and delete
   - Handles offline-first architecture
   - Proper error handling with localized messages

### 🔄 IN PROGRESS / REMAINING

#### 2. User Data Isolation (CRITICAL)
**Problem:** Multiple users/guests on same device see each other's data
**Solution:** Add userId prefix to all SharedPreferences keys
**Files to modify:**
- `lib/core/services/local_storage_service.dart`
  - Add `_currentUserId` field
  - Add `setCurrentUserId(String userId)` method
  - Modify all storage keys to use `_getUserKey(String baseKey)` helper
  - Example: `'guest_routes'` → `'user_{userId}_routes'`

**Implementation:**
```dart
// In LocalStorageService
String? _currentUserId;

void setCurrentUserId(String userId) {
  _currentUserId = userId;
}

String _getUserKey(String baseKey) {
  if (_currentUserId == null || _currentUserId!.isEmpty) {
    return 'guest_${baseKey}';
  }
  return 'user_${_currentUserId}_$baseKey';
}

// Then use in all methods:
final key = _getUserKey('routes');
final routesJson = _prefs.getString(key);
```

#### 3. Station Names in Saved Screen (CRITICAL)
**Problem:** All stations show as "حلوان/Helwan"
**Root Cause:** Using `orElse: () => stations.first` when station ID not found
**Solution:** Store station names WITH the route, not just IDs

**Files to modify:**
- `lib/features/metro/presentation/pages/route_details_screen.dart`
  - When saving route, include `sourceStationName` and `destinationStationName`
- `lib/features/metro/presentation/pages/saved_routes_screen.dart`
  - Use stored names instead of looking up by ID
  - Remove `orElse: () => stations.first` fallback

**Implementation:**
```dart
// In route_details_screen.dart - when saving
final route = SavedRoute(
  id: routeId,
  sourceStationName: state.sourceStation!.getName(context), // Use localized name
  destinationStationName: state.destinationStation!.getName(context),
  sourceStationId: state.sourceStation!.id,
  destinationStationId: state.destinationStation!.id,
  savedAt: DateTime.now(),
);

// In saved_routes_screen.dart - when displaying
Text(
  '${route.sourceStationName} → ${route.destinationStationName}',
  // Don't look up by ID, use stored names
)
```

#### 4. Price Calculation & Route Logic
**Problems:**
- No validation for same source/destination
- May not choose shortest route
- Price calculation might be incorrect

**Files to modify:**
- `lib/features/metro/domain/usecases/metro_logic.dart`

**Validations needed:**
```dart
// Add in findRoute method
if (source.id == destination.id) {
  throw Exception('Source and destination cannot be the same');
}

// Ensure shortest path algorithm is correct
// Verify price tiers: 8 EGP (≤9 stations), 10 EGP (≤16), 15 EGP (≤23)
```

#### 5. RTL Support for Arabic
**Problem:** UI not properly mirrored for Arabic
**Solution:** Wrap MaterialApp with Directionality

**Files to modify:**
- `lib/main.dart`

**Implementation:**
```dart
return EasyLocalization(
  // ... existing config
  child: Builder(
    builder: (context) {
      final isArabic = context.locale.languageCode == 'ar';
      return Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: MaterialApp.router(
          // ... existing config
        ),
      );
    },
  ),
);
```

#### 6. Theme & Language from System
**Problem:** App doesn't detect system theme/language on first launch
**Solution:** Use system settings as default

**Files to modify:**
- `lib/main.dart`

**Implementation:**
```dart
// In main()
final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
final supportedLocales = [Locale('en'), Locale('ar')];
final fallbackLocale = supportedLocales.contains(systemLocale) 
    ? systemLocale 
    : Locale('en');

// For theme
final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
final isDark = brightness == Brightness.dark;

// Store in SharedPreferences if first launch
final prefs = await SharedPreferences.getInstance();
if (!prefs.containsKey('first_launch_done')) {
  await prefs.setString('initial_locale', fallbackLocale.languageCode);
  await prefs.setBool('initial_dark_mode', isDark);
  await prefs.setBool('first_launch_done', true);
}
```

#### 7. Rive Animations
**Problem:** App needs more visual appeal
**Solution:** Add Rive animations to key screens

**Steps:**
1. Add `rive` package to pubspec.yaml
2. Download free Rive animations from rive.app
3. Add to `assets/animations/`
4. Implement in:
   - Home screen (metro train animation)
   - Loading states
   - Empty states
   - Onboarding screens

**Example:**
```dart
// In home_screen.dart
import 'package:rive/rive.dart';

// Add animation
Container(
  height: 200,
  child: RiveAnimation.asset(
    'assets/animations/metro_train.riv',
    fit: BoxFit.contain,
  ),
)
```

## Priority Order
1. **User Data Isolation** (CRITICAL - prevents data leaks)
2. **Station Names Fix** (CRITICAL - UX issue)
3. **Price Calculation** (HIGH - core functionality)
4. **RTL Support** (MEDIUM - affects 50% of users)
5. **Theme/Language Detection** (MEDIUM - UX improvement)
6. **Rive Animations** (LOW - visual polish)

## Testing Checklist
- [ ] Multiple users can use same device without seeing each other's data
- [ ] Station names display correctly in all languages
- [ ] Cannot select same station as source and destination
- [ ] Price calculation is accurate for all routes
- [ ] Arabic UI is properly mirrored (RTL)
- [ ] App detects system theme/language on first launch
- [ ] Animations run smoothly without lag

## Notes
- All changes must maintain offline-first architecture
- Error handling must be comprehensive
- UI must remain stable and responsive
- No breaking changes to existing functionality
