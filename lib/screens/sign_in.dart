import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/core/network/connectivity_service.dart';
import 'package:quickalert/quickalert.dart';
import 'package:provider/provider.dart';
import '../service/auth_service.dart';
import '../utils/constants.dart';
import '../providers/user_provider.dart';
import '../l10n/app_localizations.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  late final AuthService _authService;
  bool _isCheckingAutoLogin = true;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _checkAutoLogin();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Check if user can auto-login (offline mode with cached credentials)
  Future<void> _checkAutoLogin() async {
    try {
      final connectivityService = Provider.of<ConnectivityService>(
        context,
        listen: false,
      );

      // Only auto-login if offline and has cached credentials
      if (!connectivityService.isOnline) {
        final offlineUser = await _authService.getOfflineUser();
        
        if (offlineUser != null && mounted) {
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          userProvider.setUser(offlineUser);
          
          // Navigate to home
          Navigator.pushReplacementNamed(context, '/home');
          return;
        }
      }
    } catch (e) {
      print('Auto-login error: $e');
    } finally {
      if (mounted) {
        setState(() => _isCheckingAutoLogin = false);
      }
    }
  }

  void _showAlert(
    QuickAlertType type,
    String message, {
    VoidCallback? onConfirmed,
  }) {
    if (!mounted) return;
    QuickAlert.show(
      context: context,
      type: type,
      text: message,
      showConfirmBtn: true,
      confirmBtnText: AppLocalizations.of(context)!.okButton,
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        if (onConfirmed != null) onConfirmed();
      },
    );
  }

 void _signIn() async {
  final loc = AppLocalizations.of(context)!;
  final connectivityService = Provider.of<ConnectivityService>(context, listen: false);

  // Offline mode
  if (!connectivityService.isOnline) {
    setState(() => _isLoading = true);
    try {
      final offlineUser = await _authService.getOfflineUser();
      if (offlineUser == null) throw Exception(loc.offlineNoCachedToken);

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setUser(offlineUser);

      _showAlert(
        QuickAlertType.success,
        loc.offlineLoginSuccess,
        onConfirmed: () {
          if (mounted) Navigator.pushReplacementNamed(context, '/home');
        },
      );
    } catch (e) {
      _showAlert(QuickAlertType.error, loc.offlineNoCachedToken);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
    return;
  }

  // Online login
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);

  try {
    final user = await _authService.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    
    if (_rememberMe) await _authService.cacheUserCredentials(user);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.setUser(user);

    _showAlert(
      QuickAlertType.success,
      loc.loginSuccess,
      onConfirmed: () {
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      },
    );
  } catch (e) {
    final errorMessage = e.toString().replaceFirst('Exception: ', '');
    _showAlert(
      QuickAlertType.error,
      errorMessage.isNotEmpty ? errorMessage : loc.loginFailed,
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final connectivityService = Provider.of<ConnectivityService>(context);

    // Show loading while checking auto-login
    if (_isCheckingAutoLogin) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Connectivity status indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: connectivityService.isOnline
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: connectivityService.isOnline
                                      ? Colors.green
                                      : Colors.orange,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    connectivityService.isOnline
                                        ? Icons.wifi
                                        : Icons.wifi_off,
                                    size: 16,
                                    color: connectivityService.isOnline
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    connectivityService.isOnline
                                        ? loc.onlineMode
                                        : loc.offlineMode,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: connectivityService.isOnline
                                          ? Colors.green
                                          : Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Image.asset('assets/images/bibi.png', height: 75),
                            const SizedBox(height: 16),
                            Text(
                              loc.welcomeBack,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              loc.signInSubtitle,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppConstants.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // Show input fields only in ONLINE mode
                            if (connectivityService.isOnline) ...[
                              TextFormField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  labelText: loc.usernameLabel,
                                  hintText: loc.usernameHint,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  prefixIcon: const Icon(Icons.person),
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? loc.usernameRequired
                                        : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: loc.passwordLabel,
                                  hintText: loc.passwordHint,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? loc.passwordRequired
                                        : null,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _rememberMe,
                                        onChanged: (value) {
                                          setState(() {
                                            _rememberMe = value!;
                                          });
                                        },
                                      ),
                                      Text(loc.rememberMe),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/forgot-password',
                                      );
                                    },
                                    child: Text(
                                      loc.forgotPassword,
                                      style: const TextStyle(
                                        color: Colors.purple,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              // OFFLINE MODE MESSAGE
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.offline_bolt,
                                      size: 48,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      loc.offlineLoginHint,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.orange,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : ElevatedButton(
                                      onPressed: _signIn,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppConstants.primaryBlue,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                      ),
                                      child: Text(
                                        connectivityService.isOnline
                                            ? loc.signInButton
                                            : 'Continue Offline',
                                        style: const TextStyle(
                                          color: AppConstants.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 16),
                            if (connectivityService.isOnline)
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                child: Text(
                                  loc.dontHaveAccount,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}