# Metro Masr - Authentication Architecture Diagram

## System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         METRO MASR APP                          │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                        UI LAYER (Widgets)                       │
├─────────────────────────────────────────────────────────────────┤
│  LoginScreen  │  MainLayout  │  SavedRoutes  │  ProfileScreen  │
└────────┬──────┴──────┬───────┴──────┬────────┴────────┬─────────┘
         │             │              │                 │
         └─────────────┴──────────────┴─────────────────┘
                              │
                    ┌─────────▼─────────┐
                    │   BLoC LAYER      │
                    │   (UserCubit)     │
                    └─────────┬─────────┘
                              │
         ┌────────────────────┼────────────────────┐
         │                    │                    │
    ┌────▼─────┐      ┌──────▼──────┐     ┌──────▼──────┐
    │   Auth   │      │   Local     │     │    Data     │
    │ Service  │      │  Storage    │     │    Sync     │
    └────┬─────┘      └──────┬──────┘     └──────┬──────┘
         │                   │                    │
         │                   │                    │
    ┌────▼─────┐      ┌──────▼──────┐     ┌──────▼──────┐
    │ Google   │      │   Shared    │     │  Supabase   │
    │ Sign-In  │      │ Preferences │     │   Client    │
    └──────────┘      └─────────────┘     └─────────────┘
         │                                        │
         │                                        │
    ┌────▼─────┐                          ┌──────▼──────┐
    │  Google  │                          │  Supabase   │
    │   OAuth  │                          │  Database   │
    └──────────┘                          └─────────────┘
```

## Authentication Flow Diagram

### Google Sign-In Flow
```
┌──────────┐
│   User   │
└────┬─────┘
     │ Clicks "Sign in with Google"
     ▼
┌────────────────┐
│  LoginScreen   │
└────┬───────────┘
     │ Calls userCubit.signInWithGoogle()
     ▼
┌────────────────┐
│   UserCubit    │
└────┬───────────┘
     │ Delegates to AuthService
     ▼
┌────────────────┐
│  AuthService   │
└────┬───────────┘
     │ Initiates Google Sign-In
     ▼
┌────────────────┐
│ GoogleSignIn   │
└────┬───────────┘
     │ Returns ID Token
     ▼
┌────────────────┐
│  AuthService   │
└────┬───────────┘
     │ Signs in to Supabase with token
     ▼
┌────────────────┐
│ SupabaseClient │
└────┬───────────┘
     │ Returns authenticated user
     ▼
┌────────────────┐
│  AuthService   │
└────┬───────────┘
     │ Checks/Creates profile in DB
     ▼
┌────────────────┐
│ Supabase DB    │
│ (profiles)     │
└────┬───────────┘
     │ Profile data
     ▼
┌────────────────┐
│  AuthService   │
└────┬───────────┘
     │ Returns AppUser
     ▼
┌────────────────┐
│   UserCubit    │
└────┬───────────┘
     │ Emits UserAuthenticated state
     ▼
┌────────────────┐
│  LoginScreen   │
└────┬───────────┘
     │ Navigates to home
     ▼
┌────────────────┐
│   MainLayout   │
└────────────────┘
```

### Guest Mode Flow
```
┌──────────┐
│   User   │
└────┬─────┘
     │ Clicks "Continue as Guest"
     ▼
┌────────────────┐
│  LoginScreen   │
└────┬───────────┘
     │ Shows name dialog
     ▼
┌────────────────┐
│   User Input   │
│  (Guest Name)  │
└────┬───────────┘
     │ Calls userCubit.continueAsGuest(name)
     ▼
┌────────────────┐
│   UserCubit    │
└────┬───────────┘
     │ Delegates to AuthService
     ▼
┌────────────────┐
│  AuthService   │
└────┬───────────┘
     │ Saves to SharedPreferences
     ▼
┌────────────────┐
│SharedPreferences│
│ guest_name: X  │
│ is_guest: true │
└────┬───────────┘
     │ Success
     ▼
┌────────────────┐
│  AuthService   │
└────┬───────────┘
     │ Returns AppUser (guest)
     ▼
┌────────────────┐
│   UserCubit    │
└────┬───────────┘
     │ Emits UserAuthenticated(isGuest: true)
     ▼
┌────────────────┐
│  LoginScreen   │
└────┬───────────┘
     │ Navigates to home
     ▼
┌────────────────┐
│   MainLayout   │
└────────────────┘
```

## Data Flow Diagram

### Saving Routes (Authenticated User)
```
┌──────────┐
│   User   │
└────┬─────┘
     │ Saves route
     ▼
┌────────────────┐
│ RouteDetails   │
└────┬───────────┘
     │ Calls userCubit.saveRoute(...)
     ▼
┌────────────────┐
│   UserCubit    │
└────┬───────────┘
     │ Checks: isGuest? NO
     │ Delegates to DataSyncService
     ▼
┌────────────────┐
│ DataSyncService│
└────┬───────────┘
     │ Checks connectivity
     ▼
┌────────────────┐
│Connectivity    │
│ Service        │
└────┬───────────┘
     │ Online? YES
     ▼
┌────────────────┐
│ DataSyncService│
└────┬───────────┘
     │ Saves to Supabase
     ▼
┌────────────────┐
│ Supabase DB    │
│(saved_routes)  │
└────┬───────────┘
     │ Success
     ▼
┌────────────────┐
│ DataSyncService│
└────┬───────────┘
     │ Caches locally
     ▼
┌────────────────┐
│ LocalStorage   │
└────┬───────────┘
     │ Success
     ▼
┌────────────────┐
│   UserCubit    │
└────┬───────────┘
     │ Returns success
     ▼
┌────────────────┐
│ RouteDetails   │
└────┬───────────┘
     │ Shows success message
     ▼
┌──────────┐
│   User   │
└──────────┘
```

### Saving Routes (Guest User)
```
┌──────────┐
│   User   │
└────┬─────┘
     │ Saves route
     ▼
┌────────────────┐
│ RouteDetails   │
└────┬───────────┘
     │ Calls userCubit.saveRoute(...)
     ▼
┌────────────────┐
│   UserCubit    │
└────┬───────────┘
     │ Checks: isGuest? YES
     │ Delegates to LocalStorage
     ▼
┌────────────────┐
│ LocalStorage   │
└────┬───────────┘
     │ Saves to SharedPreferences
     ▼
┌────────────────┐
│SharedPreferences│
│ guest_routes   │
└────┬───────────┘
     │ Success (NEVER syncs to cloud)
     ▼
┌────────────────┐
│   UserCubit    │
└────┬───────────┘
     │ Returns success
     ▼
┌────────────────┐
│ RouteDetails   │
└────┬───────────┘
     │ Shows success message
     ▼
┌──────────┐
│   User   │
└──────────┘
```

## Offline Mode Flow

### App Starts Offline
```
┌──────────┐
│   App    │
│  Starts  │
└────┬─────┘
     │
     ▼
┌────────────────┐
│   UserCubit    │
│  initialize()  │
└────┬───────────┘
     │ Calls AuthService.getCurrentUser()
     ▼
┌────────────────┐
│  AuthService   │
└────┬───────────┘
     │ Checks Supabase session
     ▼
┌────────────────┐
│Connectivity    │
│ Service        │
└────┬───────────┘
     │ Offline? YES
     ▼
┌────────────────┐
│  AuthService   │
└────┬───────────┘
     │ Falls back to cache
     ▼
┌────────────────┐
│ LocalStorage   │
└────┬───────────┘
     │ Returns cached user
     ▼
┌────────────────┐
│   UserCubit    │
└────┬───────────┘
     │ Emits UserAuthenticated (from cache)
     ▼
┌────────────────┐
│      UI        │
└────┬───────────┘
     │ Shows cached data
     ▼
┌──────────┐
│   User   │
│ (Offline)│
└──────────┘
```

### Connection Restored
```
┌──────────┐
│  Network │
│  Returns │
└────┬─────┘
     │
     ▼
┌────────────────┐
│Connectivity    │
│ Service        │
└────┬───────────┘
     │ Emits online event
     ▼
┌────────────────┐
│ DataSyncService│
└────┬───────────┘
     │ Auto-sync triggered
     ▼
┌────────────────┐
│ Supabase DB    │
└────┬───────────┘
     │ Fetches latest data
     ▼
┌────────────────┐
│ DataSyncService│
└────┬───────────┘
     │ Updates local cache
     ▼
┌────────────────┐
│ LocalStorage   │
└────┬───────────┘
     │ Cache updated
     ▼
┌────────────────┐
│      UI        │
└────┬───────────┘
     │ Shows synced data
     ▼
┌──────────┐
│   User   │
│ (Online) │
└──────────┘
```

## State Management Flow

```
┌─────────────────────────────────────────┐
│           UserState Hierarchy           │
├─────────────────────────────────────────┤
│                                         │
│  UserInitial                            │
│    ↓                                    │
│  UserLoading                            │
│    ↓                                    │
│  ┌─────────────────┐                   │
│  │UserAuthenticated│                   │
│  │  - isGuest: bool│                   │
│  │  - name: String │                   │
│  │  - email: String?│                  │
│  └─────────────────┘                   │
│    OR                                   │
│  UserUnauthenticated                   │
│    OR                                   │
│  UserError(message)                    │
│                                         │
└─────────────────────────────────────────┘

Events/Actions:
- initialize()
- signInWithGoogle()
- continueAsGuest(name)
- signOut()
- saveRoute(...)
- getSavedRoutes()
- deleteRoute(id)
```

## Data Storage Strategy

```
┌─────────────────────────────────────────────────────────┐
│                    DATA STORAGE                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  AUTHENTICATED USER                                     │
│  ┌─────────────────┐         ┌──────────────────┐     │
│  │  Supabase DB    │ ◄─sync─►│ Local Cache      │     │
│  │  (Cloud)        │         │ (SharedPrefs)    │     │
│  ├─────────────────┤         ├──────────────────┤     │
│  │ • profiles      │         │ • user_cache     │     │
│  │ • saved_routes  │         │ • routes_cache   │     │
│  └─────────────────┘         └──────────────────┘     │
│                                                         │
│  GUEST USER                                             │
│  ┌─────────────────┐                                   │
│  │ Local Only      │                                   │
│  │ (SharedPrefs)   │                                   │
│  ├─────────────────┤                                   │
│  │ • guest_name    │                                   │
│  │ • is_guest      │                                   │
│  │ • guest_routes  │ ◄── NEVER synced to cloud        │
│  └─────────────────┘                                   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Security Layers

```
┌─────────────────────────────────────────┐
│          SECURITY ARCHITECTURE          │
├─────────────────────────────────────────┤
│                                         │
│  1. Authentication Layer                │
│     • Google OAuth 2.0                  │
│     • Supabase JWT tokens               │
│     • Secure token storage              │
│                                         │
│  2. Authorization Layer                 │
│     • Row Level Security (RLS)          │
│     • User can only access own data     │
│     • Enforced at database level        │
│                                         │
│  3. Data Isolation                      │
│     • Guest data: Local only            │
│     • Auth data: Cloud + Local          │
│     • Clear separation                  │
│                                         │
│  4. Network Security                    │
│     • HTTPS only                        │
│     • Supabase managed encryption       │
│     • Secure API keys                   │
│                                         │
└─────────────────────────────────────────┘
```

---

**Legend**:
- `│` : Vertical flow
- `▼` : Downward flow
- `◄─►` : Bidirectional sync
- `◄──` : One-way flow
- `┌─┐` : Component boundary
