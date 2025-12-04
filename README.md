# OpenSpace Mobile App

A comprehensive mobile application for managing and conserving open spaces in urban areas. This Flutter-based application enables citizens to report issues, book open spaces, and stay informed about the conservation and management of public green spaces.

##  About

The OpenSpace Mobile App is designed to facilitate the sustainable management and conservation of public open spaces. It provides a platform for:

- **Reporting Issues**: Citizens can report problems like vandalism, littering, or maintenance needs in public open spaces
- **Space Booking**: Users can book public open spaces for events and activities
- **Real-time Updates**: Stay informed about the status of reports and bookings
- **Offline Support**: Continue using core features even without internet connection
- **Location-based Services**: Find nearby open spaces and navigate to them

##  Features

### Core Features
- **User Authentication**: Secure login and registration with JWT tokens
-  **Interactive Map**: View all open spaces on an interactive map with real-time location
-  **Issue Reporting**: Report problems with photos and location data
- **Space Booking**: Reserve open spaces for events with approval workflow
-  **Push Notifications**: Get notified about report status and booking confirmations
-  **Dashboard**: View statistics and recent activities at a glance

### Advanced Features
-  **Offline Mode**: Automatic data synchronization when connection returns
-  **Multi-language Support**: Available in English and Swahili
-  **Theme Support**: Light and dark mode
-  **Responsive Design**: Optimized for various screen sizes
-  **Real-time Sync**: Background synchronization of pending reports and bookings

## Getting Started

### Prerequisites

- Flutter SDK (^3.7.2)
- Android Studio / VS Code with Flutter extensions
- Android device or emulator (API 21+)
- Backend server running (see configuration section)

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd v2
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**

   Update the `.env.development` file with your local server IP:
   ```properties
   BASE_URL=http://YOUR_LOCAL_IP:8001/
   GRAPHQL_URL=http://YOUR_LOCAL_IP:8001/graphql/
   HEALTH_CHECK_URL=http://YOUR_LOCAL_IP:8001/api/v1/health
   ENVIRONMENT=development
   ```

   Update the `.env.production` file with your production server IP:
   ```properties
   BASE_URL=http://YOUR_SERVER_IP:8001/
   GRAPHQL_URL=http://YOUR_SERVER_IP:8001/graphql/
   HEALTH_CHECK_URL=http://YOUR_SERVER_IP:8001/api/v1/health
   ENVIRONMENT=production
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

##  Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

The built files will be in:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

##  Project Structure

```
lib/
├── api/              # API services (REST & GraphQL)
├── config/           # App configuration
├── core/             # Core functionality (network, sync)
├── data/             # Data layer (repositories, local storage)
├── l10n/             # Localization files
├── model/            # Data models
├── providers/        # State management providers
├── screens/          # UI screens
├── service/          # Business logic services
├── utils/            # Utility functions
└── widget/           # Reusable widgets
```

##  Configuration

### Environment Detection

The app automatically uses:
- **Development mode** (`flutter run`): Uses `.env.development`
- **Release mode** (`flutter build apk --release`): Uses `.env.production`

In debug mode, you'll see a badge in the top-right corner showing which environment is active:
-  **DEV**: Development environment
-  **PROD**: Production environment

### Network Status

The app displays connectivity status:
- **Red banner** at the bottom when offline
- **Auto-sync** when connection is restored

##  Technologies Used

- **Framework**: Flutter
- **State Management**: Provider
- **Networking**: HTTP, GraphQL (graphql_flutter)
- **Local Storage**: SQLite (sqflite)
- **Maps**: flutter_map
- **Location**: Geolocator, Location
- **Offline Support**: Connectivity Plus, WorkManager
- **Internationalization**: flutter_localizations

##  Features in Detail

### Offline Synchronization

When offline, the app:
1. Saves reports and bookings locally with `pending` status
2. Displays a red "Offline" banner with a retry button
3. Automatically syncs when connection returns
4. Shows pending count in UI

### Report Management

- Create reports with photos, location, and description
- Track report status (pending, in-progress, resolved)
- View report history
- Filter reports by status

### Booking System

- Browse available open spaces
- Select dates and provide event details
- Upload supporting documents
- Track booking approval status
- View booking history



