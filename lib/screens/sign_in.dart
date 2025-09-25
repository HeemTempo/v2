import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/core/network/connectivity_service.dart';
import 'package:quickalert/quickalert.dart';
import 'package:provider/provider.dart';
import '../service/auth_service.dart';
import '../utils/constants.dart';
import '../model/user_model.dart';
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

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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

  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  final connectivityService = Provider.of<ConnectivityService>(context, listen: false);

  try {
    User? user;

    if (connectivityService.isOnline) {
      // ONLINE login
      user = await _authService.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );
    } else {
      // OFFLINE login
      user = await _authService.loginOffline();
      if (user == null) throw Exception('No cached credentials for offline login.');
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Set user in provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.setUser(user);

    // Show success alert
    _showAlert(
      QuickAlertType.success,
      connectivityService.isOnline
          ? loc.loginSuccess
          : loc.offlineLoginSuccess,
      onConfirmed: () {
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      },
    );
  } catch (e) {
    if (!mounted) return;
    setState(() => _isLoading = false);

    final errorMessage = e.toString().replaceFirst('Exception: ', '');

    _showAlert(
      QuickAlertType.error,
      errorMessage.contains('timeout')
          ? loc.connectionTimeout
          : errorMessage.contains('Offline login failed')
              ? loc.offlineNoCachedToken
              : loc.loginFailed,
    );
  }
}




  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

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
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: loc.usernameLabel,
                                hintText: loc.usernameHint,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              validator:
                                  (value) =>
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
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? loc.passwordRequired
                                          : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child:
                                  _isLoading
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
                                          loc.signInButton,
                                          style: const TextStyle(
                                            color: AppConstants.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                            ),
                            const SizedBox(height: 16),
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
