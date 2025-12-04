import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/config/app_config.dart';
import 'package:openspace_mobile_app/widget/connectivity_banner.dart';
import 'package:openspace_mobile_app/widget/environment_badge.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:openspace_mobile_app/api/graphql/graphql_service.dart';
import 'package:openspace_mobile_app/core/network/connectivity_service.dart';
import 'package:openspace_mobile_app/core/sync/sync_service.dart';
import 'package:openspace_mobile_app/data/local/report_local.dart';
import 'package:openspace_mobile_app/data/repository/booking_repository.dart';
import 'package:openspace_mobile_app/data/repository/report_repository.dart';
import 'package:openspace_mobile_app/model/Notification.dart';
import 'package:openspace_mobile_app/providers/booking_provider.dart';
import 'package:openspace_mobile_app/providers/locale_provider.dart';
import 'package:openspace_mobile_app/providers/notification_provider.dart';
import 'package:openspace_mobile_app/providers/report_provider.dart';
import 'package:openspace_mobile_app/providers/theme_provider.dart';
import 'package:openspace_mobile_app/providers/user_provider.dart';
import 'package:openspace_mobile_app/screens/Forget_password.dart';
import 'package:openspace_mobile_app/screens/NotificationDetail.dart';
import 'package:openspace_mobile_app/screens/NotificationScreen.dart';
import 'package:openspace_mobile_app/screens/Reset_Password.dart';
import 'package:openspace_mobile_app/screens/helps_and_Faqs.dart';
import 'package:openspace_mobile_app/screens/book_openspace.dart';
import 'package:openspace_mobile_app/screens/bookings.dart';
import 'package:openspace_mobile_app/screens/edit_profile.dart';
import 'package:openspace_mobile_app/screens/home_page.dart';
import 'package:openspace_mobile_app/screens/intro_slider_screen.dart';
import 'package:openspace_mobile_app/screens/language_change.dart';
import 'package:openspace_mobile_app/screens/map_screen.dart';
import 'package:openspace_mobile_app/screens/pending_bookings.dart';
import 'package:openspace_mobile_app/screens/profile.dart';
import 'package:openspace_mobile_app/screens/report_screen.dart';
import 'package:openspace_mobile_app/screens/reported_issue.dart';
import 'package:openspace_mobile_app/screens/settings_page.dart';
import 'package:openspace_mobile_app/screens/sign_in.dart';
import 'package:openspace_mobile_app/screens/sign_up.dart';
import 'package:openspace_mobile_app/screens/terms_and_conditions.dart';
import 'package:openspace_mobile_app/screens/theme_change.dart';
import 'package:openspace_mobile_app/screens/track_progress.dart';
import 'package:openspace_mobile_app/screens/userreports.dart';
import 'package:openspace_mobile_app/screens/pending_reports.dart';
import 'package:openspace_mobile_app/screens/report_detail.dart';
import 'package:openspace_mobile_app/model/Report.dart';
import 'package:openspace_mobile_app/utils/alert/access_denied_dialog.dart';
import 'package:openspace_mobile_app/utils/alert/error_dialog.dart';
import 'package:openspace_mobile_app/utils/permission.dart';
import 'package:openspace_mobile_app/utils/theme.dart';
import 'package:openspace_mobile_app/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    print("DEBUG: WidgetsFlutterBinding initialized");

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
    } catch (e) {
      print("CRITICAL ERROR: Failed to load AppConfig: $e");
      runApp(ErrorApp(message: "Failed to load configuration: $e"));
      return; // Stop execution
    }

    // Initialize services
    try {
      final syncService = SyncService();
      syncService.onSyncComplete = (successCount, failCount, reportCount, bookingCount, reportIds) {
        print("SYNC SUCCESS: $successCount items synced successfully!");
        print("Reports: $reportCount, Bookings: $bookingCount");
        print("Report IDs: $reportIds");
        
        // Show user-friendly notification
        NotificationService.showSyncSuccess(reportCount, bookingCount, reportIds);
      };
      syncService.init();
      print("DEBUG: SyncService initialized");
    } catch (e) {
      print("ERROR: Failed to initialize SyncService: $e");
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
    return FutureBuilder(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        
        if (snapshot.hasError) {
          return ErrorApp(message: 'Initialization failed: ${snapshot.error}');
        }
        
        return _buildApp();
      },
    );
  }
  
  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
  
  Widget _buildApp() {
    final client = GraphQLService().client;
    final connectivityService = ConnectivityService();
    final reportLocal = ReportLocal();
    final reportRepository = ReportRepository(localService: reportLocal);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
       
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
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        Provider<Future<SharedPreferences>>(
          create: (_) => SharedPreferences.getInstance(),
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
                  '/user-profile',
                  '/edit-profile',
                  '/bookings-list',
                  '/userReports',
                ];

                // Handle protected routes for anonymous users
                if (protectedRoutes.contains(settings.name) &&
                    userProvider.user.isAnonymous) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showAccessDeniedDialog(
                      context,
                      featureName: settings.name!.split('/').last,
                    );
                  });
                  return MaterialPageRoute(
                    builder:
                        (_) => const Scaffold(
                          body: Center(
                            child: Text("Access Denied. Please log in."),
                          ),
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

                  print(
                    "onGenerateRoute extracted for ReportIssuePage: lat=$latitude, lon=$longitude, name=$spaceName",
                  );

                  return MaterialPageRoute(
                    builder:
                        (context) => ReportIssuePage(
                          latitude: latitude,
                          longitude: longitude,
                          spaceName: spaceName,
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
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showErrorDialog(
                    context,
                    routeName: settings.name ?? "unknown route",
                  );
                });
                return MaterialPageRoute(
                  builder:
                      (_) => Scaffold(
                        appBar: AppBar(title: const Text("Page Not Found")),
                        body: Center(
                          child: Text(
                            "Sorry, the page '${settings.name}' could not be found.",
                          ),
                        ),
                      ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
