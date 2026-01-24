# Metro Masr - Comprehensive Project Documentation

## 1. Project Overview
**App Name:** Metro Masr
**Platform:** Flutter (Android, iOS, Web, Windows planned)
**Purpose:** A smart, offline-first metro navigation assistant for the Cairo Metro system. It helps users find the shortest path between stations, calculate fares, view subscription plans, and locate the nearest station using GPS.
**Core Philosophy:** Privacy-focused (Guest Mode), Offline-capable (Local Database), and Connected (Cloud Sync for specialized features).

---

## 2. Technology Stack

### **Frontend Framework**
*   **Flutter** (Dart): UI & Logic.

### **State Management**
*   **Flutter Bloc (Cubit)**: Used for managing UI states (MetroCubit for navigation, UserCubit for auth, ThemeCubit for UI modes).
*   **GetIt**: Dependency Injection (Service Locator).

### **Backend & Cloud Services**
*   **Supabase**:
    *   **Auth**: Google Sign-In & Anonymous logic.
    *   **Database (PostgreSQL)**: Storing user profiles and syncing saved routes.
*   **Google Sign-In**: Native integration for Android/iOS.

### **Local Persistence & Database**
*   **Floor (SQLite Abstraction)**: Stores static metro data (Stations, Lines, Connections) for offline pathfinding.
*   **SharedPreferences**: Stores simple key-value pairs (Onboarding status, Theme preference, Guest info).

### **Key Libraries**
*   **Geolocator**: GPS handling for "Nearest Station".
*   **GoRouter**: Smart navigation and deep linking handling.
*   **Easy Localization**: i18n support (English/Arabic) with RTL support.
*   **Flutter Animate**: polished UI transitions.
*   **Flutter Map (OpenStreetMap)**: Visualizing stations on a map without Google Maps API costs.

---

## 3. System Architecture
The project follows a **Clean Architecture** approach, separating concerns into three main layers:

### **A. Presentation Layer (`lib/features/metro/presentation`)**
*   **Pages**: Screens like `HomeScreen`, `RouteDetailsScreen`, `SubscriptionsScreen`.
*   **Widgets**: Reusable UI components (`FloatingInputCard`, `StationSearchSheet`).
*   **Bloc/Cubit**: `MetroCubit` acts as the mediator, calling UseCases and updating the UI state.

### **B. Domain Layer (`lib/features/metro/domain`)**
*   *Pure Dart code, no external dependencies.*
*   **Entities**: Core business objects (`Station`, `RouteResult`, `StationConnection`).
*   **UseCases**: Encapsulated business logic:
    *   `FindShortestPathUseCase.dart`: The core algorithm (see Section 6).
    *   `GetAllStationsUseCase.dart`.
*   **Repositories (Interfaces)**: Defines how data should be fetched (e.g., `IMetroRepository`).

### **C. Data Layer (`lib/features/metro/data`)**
*   **DataSources**:
    *   `StationDao`: Access to SQLite via Floor.
    *   `DatabaseSeeder`: Populates the local DB with initial Cairo Metro data.
*   **Repositories (Implementation)**: `MetroRepositoryImpl` connects Domain interfaces to DataSources.
*   **Models**: DTOs (Data Transfer Objects) mapping DB rows to Domain entities.

---

## 4. Core Features & Business Logic

### **1. Pathfinding Algorithm (`FindShortestPathUseCase`)**
*   **Type**: Modified **Dijkstra's Algorithm**.
*   **Graph Construction**: Builds a weighted graph from `StationConnection` entries in the DB.
*   **Logic**:
    1.  Nodes = Stations.
    2.  Edges = Connections (with costs).
    3.  **Transfer Detection**: If the algorithm moves between two nodes with the *same name* but *different Line IDs* (e.g., Sadat Line 1 -> Sadat Line 2), it counts as a **Transfer**.
    4.  **Cost logic**: Standard hops cost 1 unit (arbitrary weight), transfers might cost more in time estimation.

### **2. Pricing Engine (Cairo Metro Rules)**
*   **Tier 1**: Up to 9 stations -> **8 EGP**.
*   **Tier 2**: 10 to 16 stations -> **10 EGP**.
*   **Tier 3**: 17 to 23 stations -> **15 EGP**.
*   **Tier 4**: More than 23 stations -> **20 EGP**.
*   *Note:* Transfers are calculated as "connectors" and usually do not increment the "Station Count" for pricing, but the app logic ensures strictly traveled stations are counted.

### **3. Time Estimation**
*   **Formula**: `(Number of Stations * 2 minutes) + (Number of Transfers * 5 minutes)`.

### **4. Hybrid Sync System (`DataSyncService`)**
*   **Offline**: Routes saved by the user are stored in `SharedPrefs` (JSON cache).
*   **Online**:
    *   If `ConnectivityService` detects Internet + User is Authenticated:
    *   Push local routes to Supabase `saved_routes` table.
    *   Pull latest routes from Supabase.
    *   This ensures users can switch devices and keep their history.

### **5. Subscriptions Screen**
*   Displays **Daily Tickets**, **Monthly**, **Quarterly**, and **Yearly** plans.
*   **Localization**: Fully bilingual (Ar/En).
*   **Layout**: Vertical stack of cards for mobile responsiveness.
*   **Colors**: visual distinction (Blue=Student, Green=Special Needs, Orange=Military).

---

## 5. Database Schema

### **A. Local SQLite (Floor)**
*   **Table: Station**
    *   `id` (int, PK)
    *   `nameAr`, `nameEn` (Text)
    *   `lat`, `lng` (Real)
    *   `lineId` (int) - [1: Blue, 2: Red, 3: Green]
    *   `isInterchange` (bool)
*   **Table: StationConnection**
    *   `fromStationId`, `toStationId` (int, FKs)
    *   `cost` (int) - Weight for pathfinding.

### **B. Cloud Supabase (PostgreSQL)**
*   **Table: profiles**
    *   `id` (uuid, references auth.users)
    *   `email`, `full_name`, `avatar_url`.
*   **Table: saved_routes**
    *   `id` (uuid)
    *   `user_id` (uuid)
    *   `source_station_id`, `destination_station_id`
    *   `path` (jsonb array of station names)
    *   `price`, `estimated_time`
    *   `created_at`.

---

## 6. Project Structure Map (`lib/`)

```
lib/
├── core/                       # Shared utilities & configs
│   ├── config/                 # AppConfig (Keys, URLs)
│   ├── services/               # Auth, Connectivity, DataSync, LocalStorage
│   └── state/                  # Global UserCubit
├── features/
│   ├── auth/                   # Login Screen
│   └── metro/                  # MAIN FEATURE
│       ├── data/
│       │   ├── datasources/    # Seeder, Database, DAO
│       │   └── repositories/   # Repo Implementation
│       ├── domain/
│       │   ├── entities/       # Pure models (Station, RouteResult)
│       │   └── usecases/       # Logic (FindPath, GetAllStations)
│       └── presentation/
│           ├── bloc/           # MetroCubit
│           ├── pages/          # Home, Details, Subscriptions, Map
│           └── widgets/        # Reusable UI components
├── main.dart                   # Entry point, Routing config
└── injection_container.dart    # Dependency Injection Setup
```

---

## 7. Current data (Seeded)
*   **Line 1 (Blue):** Helwan <-> New El Marg.
*   **Line 2 (Red):** Shobra <-> El Mounib.
*   **Line 3 (Green):** Adly Mansour <-> Rod El Farag / Cairo Univ.
*   **Interchanges:** Sadat (L1/L2), Al-Shohada (L1/L2), Attaba (L2/L3), Nasser (L1/L3), Cairo University (L2/L3).

---

## 8. How to Run
1.  **Flutter Setup**: Ensure Flutter SDK 3.x is installed.
2.  **Dependencies**: Run `flutter pub get`.
3.  **Code Generation**: Run `dart run build_runner build` (Essential for Floor DB to generate the database code).
4.  **Run**: `flutter run`.

---

## 9. Future Roadmap (Documented Intent)
*   **Live Updates**: Hooking the `PricingService` to fetch live prices from Supabase config table instead of hardcoded logic.
*   **Metro API**: Fully exposing the pathfinding as an API endpoint via Supabase Edge Functions (optional).
