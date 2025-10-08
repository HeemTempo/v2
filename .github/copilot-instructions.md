# Copilot Instructions for OpenSpace Mobile App

This is a Flutter-based mobile application for managing public open spaces, with features for booking spaces, reporting issues, and tracking community improvements.

## Project Architecture

### Core Components

- **Authentication & User Management** (`lib/service/auth_service.dart`):
  - Uses GraphQL for auth operations with offline support
  - JWT token storage in `FlutterSecureStorage`
  - Anonymous vs authenticated user states

- **State Management** (`lib/providers/`):
  - Provider pattern for app-wide state
  - Key providers: UserProvider, LocaleProvider, ThemeProvider
  - ConnectivityService for online/offline sync

- **Data Layer**:
  - GraphQL API integration (`lib/api/graphql/`)
  - Local SQLite storage (`lib/core/storage/local_db.dart`)
  - Repository pattern with offline caching

### Key Features

1. **Map Integration** (`lib/screens/map_screen.dart`):
   - Uses `flutter_map` with OpenStreetMap
   - Location services with caching
   - Search and reverse geocoding

2. **Booking System** (`lib/screens/book_openspace.dart`):
   - Multi-step booking process
   - File attachment support
   - Offline queue capability

3. **Issue Reporting** (`lib/screens/report_screen.dart`):
   - Location-based reports
   - Media attachments
   - Status tracking

## Development Workflows

### Local Development

1. **Setup Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run Development Build**:
   ```bash 
   flutter run
   ```

3. **Generate Localizations**:
   ```bash
   flutter gen-l10n
   ```

### Important Patterns

1. **Internationalization**:
   - Use `AppLocalizations.of(context)!` for all user-facing strings
   - Add new strings in `lib/l10n/app_localizations.dart`

2. **Error Handling**:
   - Use `QuickAlert` for user notifications
   - Handle offline states with ConnectivityService
   - Implement graceful degradation for location/permission issues

3. **State Updates**:
   ```dart
   // Notify listeners after state changes
   setState(() => _isLoading = true);
   try {
     // API calls
   } finally {
     setState(() => _isLoading = false);
   }
   ```

### Testing Guidelines

- Widget tests in `test/widget_test.dart`
- Mock location services for map tests
- Test offline scenarios by disabling connectivity

## Key Integration Points

1. **Backend API** (`lib/api/graphql/`):
   - GraphQL endpoint configuration in `graphql_service.dart`
   - Auth mutations in `auth_mutation.dart`

2. **Location Services** (`lib/utils/location_service.dart`):
   - Geolocator for device location
   - Nominatim for reverse geocoding
   - Cache mechanisms for performance

3. **Storage** (`lib/core/storage/`):
   - Secure storage for auth tokens
   - SQLite for offline data
   - SharedPreferences for user settings

## Common Gotchas

1. Always check connectivity before API calls:
   ```dart
   if (!connectivityService.isOnline) {
     // Handle offline mode
   }
   ```

2. Handle permission states for location/storage:
   ```dart
   await _checkAndRequestPermission();
   ```

3. Dispose controllers in widget lifecycles:
   ```dart
   @override
   void dispose() {
     _controller.dispose();
     super.dispose();
   }
   ```

## Resource Links

- [Flutter Map Documentation](https://docs.fleaflet.dev/)
- [GraphQL Flutter Guide](https://pub.dev/packages/graphql_flutter)