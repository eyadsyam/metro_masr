# Quick Integration Guide - Using Authentication in Your App

## Accessing Current User

### In Any Widget
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metro_masr/core/state/user_cubit.dart';

// Get the UserCubit
final userCubit = context.read<UserCubit>();

// Get current user
final user = userCubit.currentUser;

// Check user type
if (userCubit.isGuest) {
  print('User is in guest mode: ${user?.name}');
} else if (userCubit.isAuthenticated) {
  print('User is authenticated: ${user?.email}');
}
```

## Displaying User Info in AppBar

```dart
AppBar(
  title: Text('Metro Masr'),
  actions: [
    BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state is UserAuthenticated) {
          return Row(
            children: [
              // Show avatar or icon
              if (state.avatarUrl != null)
                CircleAvatar(
                  backgroundImage: NetworkImage(state.avatarUrl!),
                  radius: 16,
                )
              else
                CircleAvatar(
                  child: Icon(state.isGuest ? Icons.person : Icons.account_circle),
                  radius: 16,
                ),
              SizedBox(width: 8),
              // Show name
              Text(state.name),
              SizedBox(width: 16),
            ],
          );
        }
        return SizedBox();
      },
    ),
  ],
)
```

## Saving Routes

### From Route Details Screen
```dart
// In your route calculation screen
import 'package:metro_masr/core/state/user_cubit.dart';

class RouteDetailsScreen extends StatelessWidget {
  final RouteResult routeResult; // Your route data

  Future<void> _saveRoute(BuildContext context) async {
    final userCubit = context.read<UserCubit>();
    
    try {
      await userCubit.saveRoute(
        fromStation: routeResult.fromStation,
        toStation: routeResult.toStation,
        path: routeResult.path,
        totalStations: routeResult.totalStations,
        price: routeResult.price,
        estimatedTime: routeResult.estimatedTime,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Route saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save route: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Route Details')),
      body: Column(
        children: [
          // Your route details UI
          ElevatedButton.icon(
            onPressed: () => _saveRoute(context),
            icon: Icon(Icons.bookmark),
            label: Text('Save Route'),
          ),
        ],
      ),
    );
  }
}
```

## Displaying Saved Routes

### In Saved Routes Screen
```dart
import 'package:metro_masr/core/state/user_cubit.dart';

class SavedRoutesScreen extends StatefulWidget {
  @override
  State<SavedRoutesScreen> createState() => _SavedRoutesScreenState();
}

class _SavedRoutesScreenState extends State<SavedRoutesScreen> {
  List<Map<String, dynamic>> _routes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    setState(() => _loading = true);
    
    final userCubit = context.read<UserCubit>();
    final routes = await userCubit.getSavedRoutes();
    
    setState(() {
      _routes = routes;
      _loading = false;
    });
  }

  Future<void> _deleteRoute(String routeId) async {
    final userCubit = context.read<UserCubit>();
    
    try {
      await userCubit.deleteRoute(routeId);
      await _loadRoutes(); // Refresh list
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Route deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete route')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Saved Routes')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _routes.isEmpty
              ? Center(child: Text('No saved routes'))
              : ListView.builder(
                  itemCount: _routes.length,
                  itemBuilder: (context, index) {
                    final route = _routes[index];
                    return ListTile(
                      title: Text('${route['from_station']} → ${route['to_station']}'),
                      subtitle: Text('${route['total_stations']} stations • ${route['price']} EGP'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteRoute(route['id']),
                      ),
                    );
                  },
                ),
    );
  }
}
```

## Adding Sign Out Button

### In Settings/Profile Screen
```dart
import 'package:metro_masr/core/state/user_cubit.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final userCubit = context.read<UserCubit>();
      await userCubit.signOut();
      
      // Navigate to login screen
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          if (state is UserAuthenticated) {
            return ListView(
              children: [
                // User info
                ListTile(
                  leading: state.avatarUrl != null
                      ? CircleAvatar(backgroundImage: NetworkImage(state.avatarUrl!))
                      : CircleAvatar(child: Icon(Icons.person)),
                  title: Text(state.name),
                  subtitle: Text(state.email ?? 'Guest User'),
                ),
                Divider(),
                
                // Guest indicator
                if (state.isGuest)
                  ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Guest Mode'),
                    subtitle: Text('Your data is stored locally only'),
                  ),
                
                // Sign out button
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Sign Out'),
                  onTap: () => _signOut(context),
                ),
              ],
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
```

## Checking Authentication Before Actions

### Require Login for Certain Features
```dart
Future<void> _performAuthenticatedAction(BuildContext context) async {
  final userCubit = context.read<UserCubit>();
  
  if (!userCubit.isAuthenticated) {
    // Show dialog to encourage sign in
    final shouldSignIn = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign In Required'),
        content: Text('This feature requires a Google account. Would you like to sign in?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sign In'),
          ),
        ],
      ),
    );
    
    if (shouldSignIn == true && context.mounted) {
      context.go('/login');
    }
    return;
  }
  
  // Perform the action
  // ...
}
```

## Showing Different UI for Guest vs Authenticated

```dart
BlocBuilder<UserCubit, UserState>(
  builder: (context, state) {
    if (state is UserAuthenticated) {
      if (state.isGuest) {
        // Guest UI - Show upgrade prompt
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.cloud_off, size: 48),
                SizedBox(height: 8),
                Text('You\'re in Guest Mode'),
                Text('Sign in to sync your data across devices'),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: Text('Sign In with Google'),
                ),
              ],
            ),
          ),
        );
      } else {
        // Authenticated UI - Show sync status
        return Card(
          child: ListTile(
            leading: Icon(Icons.cloud_done, color: Colors.green),
            title: Text('Synced to Cloud'),
            subtitle: Text('Your data is backed up'),
          ),
        );
      }
    }
    return SizedBox();
  },
)
```

## Listening to Connectivity Changes

```dart
import 'package:metro_masr/core/services/connectivity_service.dart';

class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late StreamSubscription _connectivitySubscription;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    
    final connectivityService = di.sl<ConnectivityService>();
    _isOnline = connectivityService.isConnected;
    
    _connectivitySubscription = connectivityService.connectivityStream.listen((isConnected) {
      setState(() {
        _isOnline = isConnected;
      });
      
      if (isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Back online - syncing data...')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Offline - using cached data')),
        );
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_isOnline)
          Container(
            color: Colors.orange,
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Icon(Icons.cloud_off, color: Colors.white),
                SizedBox(width: 8),
                Text('Offline Mode', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        // Your content
      ],
    );
  }
}
```

## Common Patterns

### Pattern 1: Show Login Prompt
```dart
void _showLoginPrompt(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.login, size: 48),
          SizedBox(height: 16),
          Text('Sign in to unlock all features', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 8),
          Text('Sync your routes across devices'),
          SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            child: Text('Sign In with Google'),
          ),
        ],
      ),
    ),
  );
}
```

### Pattern 2: Conditional Feature Access
```dart
Widget _buildFeature(BuildContext context) {
  final userCubit = context.read<UserCubit>();
  
  return userCubit.isAuthenticated
      ? PremiumFeatureWidget()
      : LockedFeatureWidget(
          onTap: () => _showLoginPrompt(context),
        );
}
```

## Tips

1. **Always check if context is mounted** before navigation after async operations
2. **Use BlocBuilder** for reactive UI updates
3. **Use context.read** for one-time actions (like button presses)
4. **Handle errors gracefully** with try-catch and user feedback
5. **Show loading states** during async operations
6. **Cache data** for offline access
7. **Inform users** about guest mode limitations

## Import Statements You'll Need

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:metro_masr/core/state/user_cubit.dart';
import 'package:metro_masr/core/state/user_state.dart';
import 'package:metro_masr/core/services/connectivity_service.dart';
import 'package:metro_masr/injection_container.dart' as di;
```

---

**Happy Coding! 🚀**
