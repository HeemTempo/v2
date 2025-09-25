import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:openspace_mobile_app/api/graphql/graphql_service.dart';
import 'package:openspace_mobile_app/core/network/connectivity_service.dart';
import 'package:openspace_mobile_app/core/sync/sync_service.dart';
import 'package:openspace_mobile_app/providers/locale_provider.dart';
import 'package:openspace_mobile_app/providers/theme_provider.dart';
import 'package:openspace_mobile_app/providers/user_provider.dart';
import 'package:openspace_mobile_app/screens/Forget_password.dart';
import 'package:openspace_mobile_app/screens/NotificationScreen.dart';
import 'package:openspace_mobile_app/screens/Reset_Password.dart';
import 'package:openspace_mobile_app/screens/book_openspace.dart';
import 'package:openspace_mobile_app/screens/bookings.dart';
import 'package:openspace_mobile_app/screens/edit_profile.dart';
import 'package:openspace_mobile_app/screens/helps_and_Faqs.dart';
import 'package:openspace_mobile_app/screens/home_page.dart';
import 'package:openspace_mobile_app/screens/intro_slider_screen.dart';
import 'package:openspace_mobile_app/screens/language_change.dart';
import 'package:openspace_mobile_app/screens/map_screen.dart';
import 'package:openspace_mobile_app/screens/profile.dart';
import 'package:openspace_mobile_app/screens/report_screen.dart'; // Assuming this is ReportedIssuesPage
import 'package:openspace_mobile_app/screens/reported_issue.dart'; // This is your ReportIssuePage
import 'package:openspace_mobile_app/screens/settings_page.dart';
import 'package:openspace_mobile_app/screens/sign_in.dart';
import 'package:openspace_mobile_app/screens/sign_up.dart';
import 'package:openspace_mobile_app/screens/terms_and_conditions.dart';
import 'package:openspace_mobile_app/screens/theme_change.dart';
import 'package:openspace_mobile_app/screens/track_progress.dart';
import 'package:openspace_mobile_app/screens/userreports.dart';
import 'package:openspace_mobile_app/utils/alert/access_denied_dialog.dart';
import 'package:openspace_mobile_app/utils/alert/error_dialog.dart';
import 'package:openspace_mobile_app/utils/permission.dart';
import 'package:openspace_mobile_app/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestNotificationPermission();

    SyncService().init();
  runApp(const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final client = GraphQLService().client;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
         ChangeNotifierProvider(create: (_) => ConnectivityService()),
        
        Provider<ValueNotifier<GraphQLClient>>(
            create: (_) => ValueNotifier(client)),
        Provider(create: (_) => SharedPreferences.getInstance()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider,localeProvider, _) {
          return GraphQLProvider(
            client: ValueNotifier(client),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
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
                    "onGenerateRoute called with: ${settings.name}, arguments: ${settings.arguments}");

                final userProvider = Provider.of<UserProvider>(context, listen: false);

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
                   showAccessDeniedDialog(context, featureName: settings.name!.split('/').last);
                  });
                  // Return a valid route (e.g., a placeholder, a login screen, or an access denied screen)
                  return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text("Access Denied. Please log in."))));
                }
                if (settings.name == '/report-issue') {
                  final args = settings.arguments as Map<String, dynamic>?;
                  print("onGenerateRoute for /report-issue, args: $args");

                  final double? latitude = args?['latitude'] as double?;
                  final double? longitude = args?['longitude'] as double?;
                  final String? spaceName = args?['spaceName'] as String?;

                  print(
                      "onGenerateRoute extracted for ReportIssuePage: lat=$latitude, lon=$longitude, name=$spaceName");

                  return MaterialPageRoute(
                    builder: (context) => ReportIssuePage(
                      latitude: latitude,
                      longitude: longitude,
                      spaceName: spaceName,
                    ),
                  );
                }

                if (settings.name != null &&
                    settings.name!.startsWith('/reset-password')) {
                  final uri = Uri.parse(settings.name!);
                  if (uri.pathSegments.length == 3 &&
                      uri.pathSegments[0] == 'reset-password') {
                    final uid = uri.pathSegments[1];
                    final token = uri.pathSegments[2];
                    print(
                        "Extracted for ResetPasswordPage - uid: $uid, token: $token");
                    return MaterialPageRoute(
                      builder: (context) =>
                          ResetPasswordPage(uid: uid, token: token),
                    );
                  }
                }
                if (settings.name != null && settings.name!.startsWith('/book')) {
                  final uri = Uri.parse(settings.name!);
                  int? spaceId;
                  String? spaceName;
                  if (uri.pathSegments.length == 2 &&
                      uri.pathSegments[0] == 'book') {
                    try {
                      spaceId = int.parse(uri.pathSegments[1]);
                    } catch (e) {
                      print("Invalid spaceId format in path: ${uri.pathSegments[1]}");
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
                      builder: (context) => BookingPage(
                        spaceId: spaceId!,
                        spaceName: spaceName,
                      ),
                    );
                  } else {
                    print("Error: Navigating to /book without a valid spaceId. Arguments: ${settings.arguments}, Path: ${settings.name}");
                    return MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: const Text("Booking Error")),
                        body: const Center(
                            child: Text("Invalid or missing space ID for booking.")),
                      ),
                    );
                  }
                }


                // --- General Routes Map ---
                // (Routes not handled by specific handlers above)
                final routes = <String, WidgetBuilder>{
                  '/': (context) => const IntroSliderScreen(),
                  '/home': (context) => const HomePage(),
                  '/login': (context) => const SignInScreen(),
                  '/register': (context) => const SignUpScreen(), // Assuming same as login for now
                  // '/report-issue' is handled above
                  '/track-progress': (context) => const TrackProgressScreen(),
                  '/user-profile': (context) => const UserProfilePage(),
                  '/edit-profile': (context) => const EditProfilePage(),
                  '/map': (context) => const MapScreen(),
                  '/reported-issue': (context) => const ReportedIssuesPage(), // List of reported issues
                  '/setting': (context) => const SettingsPage(),
                  '/change-theme': (context) => const ThemeChangePage(),
                  '/change-language': (context) => const LanguageSettings(),
                  '/help-support': (context) => const HelpPage(),
                  '/terms': (context) => const TermsAndConditionsPage(),
                  '/bookings-list': (context) => const MyBookingsPage(),
                  '/userReports': (context) => const UserReportsPage(),
                  '/forgot-password': (context) => const ForgotPasswordPage(),
                  '/user-notification': (context) => const NotificationScreen(),
                };

                final WidgetBuilder? routeBuilder = routes[settings.name];

                if (routeBuilder != null) {
                  // This will build the route if it's found in the map and
                  // not an anonymous user trying to access a protected route (handled above).
                  return MaterialPageRoute(
                    builder: routeBuilder,
                    settings: settings, // Pass along settings
                  );
                }

                // Fallback for unknown routes
                print(
                    "Route ${settings.name} not found, showing default PageNotFound.");
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showErrorDialog(context, routeName: settings.name ?? "unknown route");
                });
                // Return a valid route for "Page Not Found"
                return MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: const Text("Page Not Found")),
                      body: Center(
                          child: Text(
                              "Sorry, the page '${settings.name}' could not be found.")),
                    ));
              },
            ),
          );
        },
      ),
    );
  }
}