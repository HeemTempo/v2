import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kinondoni_openspace_app/config/app_config.dart';
import 'package:kinondoni_openspace_app/service/offline_map_service.dart';
import 'package:kinondoni_openspace_app/widget/connectivity_banner.dart';
import 'package:kinondoni_openspace_app/widget/environment_badge.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kinondoni_openspace_app/api/graphql/graphql_service.dart';
import 'package:kinondoni_openspace_app/core/network/connectivity_service.dart';
import 'package:kinondoni_openspace_app/core/sync/sync_service.dart';
import 'package:kinondoni_openspace_app/data/local/report_local.dart';
import 'package:kinondoni_openspace_app/data/repository/booking_repository.dart';
import 'package:kinondoni_openspace_app/data/repository/report_repository.dart';
import 'package:kinondoni_openspace_app/model/Notification.dart';
import 'package:kinondoni_openspace_app/providers/booking_provider.dart';
import 'package:kinondoni_openspace_app/providers/locale_provider.dart';
import 'package:kinondoni_openspace_app/providers/notification_provider.dart';
import 'package:kinondoni_openspace_app/providers/report_provider.dart';
import 'package:kinondoni_openspace_app/providers/theme_provider.dart';
import 'package:kinondoni_openspace_app/providers/user_provider.dart';
import 'package:kinondoni_openspace_app/screens/Forget_password.dart';
import 'package:kinondoni_openspace_app/screens/NotificationDetail.dart';
import 'package:kinondoni_openspace_app/screens/NotificationScreen.dart';
import 'package:kinondoni_openspace_app/screens/Reset_Password.dart';
import 'package:kinondoni_openspace_app/screens/helps_and_Faqs.dart';
import 'package:kinondoni_openspace_app/screens/book_openspace.dart';
import 'package:kinondoni_openspace_app/screens/bookings.dart';
import 'package:kinondoni_openspace_app/screens/edit_profile.dart';
import 'package:kinondoni_openspace_app/screens/home_page.dart';
import 'package:kinondoni_openspace_app/screens/intro_slider_screen.dart';
import 'package:kinondoni_openspace_app/screens/language_change.dart';
import 'package:kinondoni_openspace_app/screens/map_screen.dart';
import 'package:kinondoni_openspace_app/screens/offline_map_download_screen.dart';
import 'package:kinondoni_openspace_app/screens/pending_bookings.dart';
import 'package:kinondoni_openspace_app/screens/profile.dart';
import 'package:kinondoni_openspace_app/screens/report_screen.dart';
import 'package:kinondoni_openspace_app/screens/reported_issue.dart';
import 'package:kinondoni_openspace_app/screens/settings_page.dart';
import 'package:kinondoni_openspace_app/screens/sign_in.dart';
import 'package:kinondoni_openspace_app/screens/sign_up.dart';
import 'package:kinondoni_openspace_app/screens/terms_and_conditions.dart';
import 'package:kinondoni_openspace_app/screens/theme_change.dart';
import 'package:kinondoni_openspace_app/screens/track_progress.dart';
import 'package:kinondoni_openspace_app/screens/userreports.dart';
import 'package:kinondoni_openspace_app/screens/pending_reports.dart';
import 'package:kinondoni_openspace_app/screens/report_detail.dart';
import 'package:kinondoni_openspace_app/model/Report.dart';
import 'package:kinondoni_openspace_app/utils/permission.dart';
import 'package:kinondoni_openspace_app/utils/theme.dart';
import 'package:kinondoni_openspace_app/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kinondoni_openspace_app/screens/misc/access_denied_screen.dart';
import 'package:kinondoni_openspace_app/screens/misc/not_found_screen.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await initHiveForFlutter();
    print("DEBUG: WidgetsFlutterBinding & Hive initialized (Standard)");

    try {
      await requestNotificationPermission();
      print("DEBUG: Notification permission requested");
    } catch (e) {
      print("ERROR: Failed to request notification permission: $e");
      // Permission failure shouldn't block the app, so we continue
    }

    // Initialize ThemeProvider and load saved theme
    final themeProvider = ThemeProvider();
    try {
      await themeProvider.loadTheme();
      print("DEBUG: Theme loaded");
    } catch (e) {
      print('WARNING: Failed to load theme: $e');
    }

    // Initialize AppConfig
    try {
      const envFile = kReleaseMode ? '.env.production' : '.env.development';
      await AppConfig.load(envFile: envFile);
      print("DEBUG: AppConfig loaded from $envFile");
      print("DEBUG: BASE_URL = ${AppConfig.baseUrl}");
      print("DEBUG: GRAPHQL_URL = ${AppConfig.graphqlUrl}");
    } catch (e, stackTrace) {
      print("CRITICAL ERROR: Failed to load AppConfig: $e");
      print("Stack trace: $stackTrace");
      runApp(ErrorApp(message: "Failed to load configuration file. Please ensure .env files are included in the build."));
      return;
    }

    // Initialize services
    try {
      await OfflineMapService.initialize();
      print("DEBUG: Offline map service initialized");
    } catch (e) {
      print("WARNING: Failed to initialize offline maps: $e");
    }

    try {
      final syncService = SyncService();
      syncService.onSyncComplete = (successCount, failCount, reportCount, bookingCount, reportIds) {
        print("SYNC SUCCESS: $successCount items synced successfully!");
        print("Reports: $reportCount, Bookings: $bookingCount");
        print("Report IDs: $reportIds");
        
        if (reportCount == 0 && bookingCount == 0 && successCount == 0) {
          NotificationService.showInfo(
            'No offline reports found',
            duration: const Duration(seconds: 3),
          );
        } else if (reportCount > 0 || bookingCount > 0) {
          String message = 'Synced: ';
          List<String> parts = [];
          if (reportCount > 0) parts.add('$reportCount report${reportCount > 1 ? 's' : ''}');
          if (bookingCount > 0) parts.add('$bookingCount booking${bookingCount > 1 ? 's' : ''}');
          message += parts.join(' & ');
          
          if (reportIds.isNotEmpty) {
            message += '\nIDs: ${reportIds.join(', ')}';
          }
          
          NotificationService.showSuccess(
            message,
            duration: const Duration(seconds: 5),
          );
        }
      };
      syncService.init();
      print("DEBUG: SyncService initialized");
    } catch (e) {
      print("WARNING: Failed to initialize SyncService: $e");
    }

    runApp(MyApp(themeProvider: themeProvider));
    print("DEBUG: runApp called");
  } catch (e, stack) {
    print("CRITICAL ERROR in main: $e");
    print(stack);
    runApp(ErrorApp(message: "Critical startup error: $e"));
  }
}

class ErrorApp extends StatelessWidget {
  final String message;
  const ErrorApp({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red.shade100,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  "Startup Error",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;

  const MyApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    print('🏗️ MyApp.build() called - starting app build');
    return _buildApp();
  }
  
  Widget _buildApp() {
    print('🔧 _buildApp() called - initializing services');
    final client = GraphQLService().client;
    print('✅ GraphQL client initialized');
    final connectivityService = ConnectivityService();
    print('✅ ConnectivityService initialized');
    final reportLocal = ReportLocal();
    final reportRepository = ReportRepository(localService: reportLocal);
    print('✅ ReportRepository initialized');

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          print('✅ Creating ConnectivityService provider');
          return ConnectivityService();
        }),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) {
          print('✅ Creating UserProvider');
          return UserProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          print('✅ Creating LocaleProvider');
          return LocaleProvider();
        }),
       
        ChangeNotifierProvider(
          create: (_) => ReportProvider(
            repository: reportRepository,
            connectivity: connectivityService,
          ),
        ),
        ChangeNotifierProxyProvider<ConnectivityService, BookingProvider>(
          create: (context) => BookingProvider(
            repository: BookingRepository(),
            connectivity: context.read<ConnectivityService>(),
          ),
          update: (context, connectivity, previous) =>
              previous ??
              BookingProvider(
                repository: BookingRepository(),
                connectivity: connectivity,
              ),
        ),
        Provider<ValueNotifier<GraphQLClient>>(
          create: (_) => ValueNotifier(client),
        ),
        ChangeNotifierProxyProvider<ConnectivityService, NotificationProvider>(
          create: (context) {
            print('✅ Creating NotificationProvider');
            return NotificationProvider(
              connectivityService: context.read<ConnectivityService>(),
            );
          },
          update: (context, connectivity, previous) =>
              previous ??
              NotificationProvider(
                connectivityService: connectivity,
              ),
        ),
        Provider<Future<SharedPreferences>>(
          create: (_) {
            print('⏳ Starting SharedPreferences.getInstance() - this might hang...');
            return SharedPreferences.getInstance().then((prefs) {
              print('✅ SharedPreferences initialized successfully');
              return prefs;
            });
          },
          lazy: false, // Ensure SharedPreferences is initialized early
        ),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, _) {
          return GraphQLProvider(
            client: ValueNotifier(client),
            child: MaterialApp(
              scaffoldMessengerKey: NotificationService.scaffoldMessengerKey,
              debugShowCheckedModeBanner: false,
              builder: (context, child) {
                ErrorWidget.builder = (FlutterErrorDetails details) {
                  return Scaffold(
                    body: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            const Text('Something went wrong', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            if (kDebugMode) Text(details.exception.toString(), textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                              child: const Text('Restart App'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                };
                
                return Stack(
                  children: [
                    Column(
                      children: [
                        const ConnectivityBanner(),
                        Expanded(child: child!),
                      ],
                    ),
                    const EnvironmentBadge(),
                  ],
                );
              },
              title: 'Smart GIS App',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              // Localization
              locale: localeProvider.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              initialRoute: '/',
              onGenerateRoute: (RouteSettings settings) {
                print(
                  "onGenerateRoute called with: ${settings.name}, arguments: ${settings.arguments}",
                );

                final userProvider = Provider.of<UserProvider>(
                  context,
                  listen: false,
                );

                final protectedRoutes = [
                  '/edit-profile',
                  '/bookings-list',
                  '/userReports',
                ];

                // Handle protected routes for anonymous users
                if (protectedRoutes.contains(settings.name) &&
                    userProvider.user.isAnonymous) {
                  return MaterialPageRoute(
                    builder: (context) => AccessDeniedScreen(
                      featureName: settings.name?.split('/').last ?? 'Feature',
                    ),
                  );
                }

                // Handle /user-notification-detail route
                if (settings.name == '/user-notification-detail') {
                  final args = settings.arguments;
                  if (args is ReportNotification) {
                    return MaterialPageRoute(
                      builder:
                          (context) =>
                              NotificationDetailScreen(notification: args),
                    );
                  } else {
                    print(
                      "Error: Missing or invalid notification argument for /user-notification-detail",
                    );
                    return MaterialPageRoute(
                      builder:
                          (context) => Scaffold(
                            appBar: AppBar(
                              title: const Text("Notification Error"),
                            ),
                            body: const Center(
                              child: Text(
                                "Invalid or missing notification data.",
                              ),
                            ),
                          ),
                    );
                  }
                }

                // Handle /report-detail route
                if (settings.name == '/report-detail') {
                  final args = settings.arguments;
                  if (args is Report) {
                    return MaterialPageRoute(
                      builder: (context) => ReportDetailPage(report: args),
                    );
                  }
                }

                // Handle /report-issue route
                if (settings.name == '/report-issue') {
                  final args = settings.arguments as Map<String, dynamic>?;
                  print("onGenerateRoute for /report-issue, args: $args");

                  final double? latitude = args?['latitude'] as double?;
                  final double? longitude = args?['longitude'] as double?;
                  final String? spaceName = args?['spaceName'] as String?;
                  final String? district = args?['district'] as String?;
                  final String? street = args?['street'] as String?;

                  print(
                    "onGenerateRoute extracted for ReportIssuePage: lat=$latitude, lon=$longitude, name=$spaceName, district=$district, street=$street",
                  );

                  return MaterialPageRoute(
                    builder:
                        (context) => ReportIssuePage(
                          latitude: latitude,
                          longitude: longitude,
                          spaceName: spaceName,
                          district: district,
                          street: street,
                        ),
                  );
                }

                // Handle /reset-password route
                if (settings.name != null &&
                    settings.name!.startsWith('/reset-password')) {
                  final uri = Uri.parse(settings.name!);
                  if (uri.pathSegments.length == 3 &&
                      uri.pathSegments[0] == 'reset-password') {
                    final uid = uri.pathSegments[1];
                    final token = uri.pathSegments[2];
                    print(
                      "Extracted for ResetPasswordPage - uid: $uid, token: $token",
                    );
                    return MaterialPageRoute(
                      builder:
                          (context) =>
                              ResetPasswordPage(uid: uid, token: token),
                    );
                  }
                }

                // Handle /book route
                if (settings.name != null &&
                    settings.name!.startsWith('/book')) {
                  final uri = Uri.parse(settings.name!);
                  int? spaceId;
                  String? spaceName;
                  if (uri.pathSegments.length == 2 &&
                      uri.pathSegments[0] == 'book') {
                    try {
                      spaceId = int.parse(uri.pathSegments[1]);
                    } catch (e) {
                      print(
                        "Invalid spaceId format in path: ${uri.pathSegments[1]}",
                      );
                    }
                  }
                  if (settings.arguments != null) {
                    if (settings.arguments is int) {
                      spaceId = settings.arguments as int;
                    } else if (settings.arguments is Map) {
                      final args = settings.arguments as Map;
                      if (args['spaceId'] != null) {
                        if (args['spaceId'] is int) {
                          spaceId = args['spaceId'] as int;
                        } else if (args['spaceId'] is String) {
                          spaceId = int.tryParse(args['spaceId'].toString());
                        }
                      }
                      spaceName = args['spaceName']?.toString();
                    }
                  }

                  if (spaceId != null) {
                    return MaterialPageRoute(
                      builder:
                          (context) => BookingPage(
                            spaceId: spaceId!,
                            spaceName: spaceName,
                          ),
                    );
                  } else {
                    print(
                      "Error: Navigating to /book without a valid spaceId. Arguments: ${settings.arguments}, Path: ${settings.name}",
                    );
                    return MaterialPageRoute(
                      builder:
                          (context) => Scaffold(
                            appBar: AppBar(title: const Text("Booking Error")),
                            body: const Center(
                              child: Text(
                                "Invalid or missing space ID for booking.",
                              ),
                            ),
                          ),
                    );
                  }
                }

                // General Routes Map
                final routes = <String, WidgetBuilder>{
                  '/': (context) => const IntroSliderScreen(),
                  '/home': (context) => const HomePage(),
                  '/login': (context) => const SignInScreen(),
                  '/register': (context) => const SignUpScreen(),
                  '/track-progress': (context) => const TrackProgressScreen(),
                  '/user-profile': (context) => const UserProfilePage(),
                  '/edit-profile': (context) => const EditProfilePage(),
                  '/map': (context) => const MapScreen(),
                  '/offline-maps': (context) => const OfflineMapDownloadScreen(),
                  '/reported-issue': (context) => const ReportedIssuesPage(),
                  '/setting': (context) => const SettingsPage(),
                  '/change-theme': (context) => const ThemeChangePage(),
                  '/change-language': (context) => const LanguageSettings(),
                  '/help-support': (context) => const HelpPage(),
                  '/terms': (context) => const TermsAndConditionsPage(),
                  '/bookings-list': (context) => const MyBookingsPage(),
                  '/pending-bookings': (context) => const PendingBookingsPage(),

                  '/userReports': (context) => const UserReportsPage(),
                  '/forgot-password': (context) => const ForgotPasswordPage(),
                  '/user-notification': (context) => const NotificationScreen(),
                  '/pending-reports': (context) => const PendingReportsPage(),
                };

                final WidgetBuilder? routeBuilder = routes[settings.name];

                if (routeBuilder != null) {
                  return MaterialPageRoute(
                    builder: routeBuilder,
                    settings: settings,
                  );
                }

                // Fallback for unknown routes
                print(
                  "Route ${settings.name} not found, showing default PageNotFound.",
                );
                return MaterialPageRoute(
                  builder: (context) => NotFoundScreen(routeName: settings.name),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
