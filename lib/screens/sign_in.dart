import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kinondoni_openspace_app/core/network/connectivity_service.dart';
import 'package:quickalert/quickalert.dart';
import 'package:provider/provider.dart';
import '../service/auth_service.dart';
import '../utils/constants.dart';
import '../providers/user_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';
import '../widget/modern_auth_button.dart';

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
    print('🔐 SignInScreen: Starting auto-login check...');
    try {
      // Add timeout to prevent hanging
      await Future.delayed(const Duration(milliseconds: 100));

      final connectivityService = Provider.of<ConnectivityService>(
        context,
        listen: false,
      );
      print('🔐 SignInScreen: Connectivity service obtained');

      // Only auto-login if offline and has cached credentials
      if (!connectivityService.isOnline) {
        print(
          '📴 SignInScreen: Device offline, checking cached credentials...',
        );
        final offlineUser = await _authService.getOfflineUser().timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            print('⚠️ SignInScreen: getOfflineUser timeout');
            return null;
          },
        );

        if (offlineUser != null && mounted) {
          print('✅ SignInScreen: Found cached user, auto-logging in');
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          userProvider.setUser(offlineUser);

          // Navigate to home
          Navigator.pushReplacementNamed(context, '/home');
          return;
        } else {
          print('ℹ️ SignInScreen: No cached user found');
        }
      } else {
        print('🌐 SignInScreen: Device online, skipping auto-login');
      }
    } catch (e) {
      print('❌ SignInScreen: Auto-login error: $e');
    } finally {
      print('✅ SignInScreen: Auto-login check complete, showing login screen');
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
    if (type == QuickAlertType.success) {
      NotificationService.showSuccess(message);
      onConfirmed?.call();
      return;
    }

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
    final connectivityService = Provider.of<ConnectivityService>(
      context,
      listen: false,
    );

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
      final user = await _authService
          .login(
            _usernameController.text.trim(),
            _passwordController.text.trim(),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(loc.errorTimeout);
            },
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
    } on TimeoutException catch (_) {
      _showAlert(QuickAlertType.error, loc.errorTimeout);
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
    final connectivityService = context.watch<ConnectivityService>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isCheckingAutoLogin) {
      return Scaffold(
        backgroundColor:
            isDark ? AppConstants.darkBackground : AppConstants.pageBackground,
        body: const Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppConstants.darkBackground : AppConstants.pageBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder:
              (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 38,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton.outlined(
                              onPressed: () => Navigator.maybePop(context),
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                            const Spacer(),
                            _ConnectionBadge(
                              isOnline: connectivityService.isOnline,
                              onlineLabel: loc.onlineMode,
                              offlineLabel: loc.offlineMode,
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          height: 144,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  'assets/images/kinondoni-home-hero-v2.jpg',
                                  fit: BoxFit.cover,
                                  alignment: Alignment.centerRight,
                                ),
                                const DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xD907543F),
                                        Color(0x1407543F),
                                      ],
                                    ),
                                  ),
                                ),
                                const Positioned(
                                  left: 18,
                                  bottom: 18,
                                  child: Icon(
                                    Icons.park_rounded,
                                    color: Colors.white,
                                    size: 34,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          loc.welcomeBack,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: isDark ? Colors.white : AppConstants.navy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loc.signInSubtitle,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark ? Colors.white70 : AppConstants.muted,
                          ),
                        ),
                        const SizedBox(height: 30),
                        if (connectivityService.isOnline) ...[
                          TextFormField(
                            controller: _usernameController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: loc.usernameLabel,
                              hintText: loc.usernameHint,
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                            validator:
                                (value) =>
                                    value == null || value.trim().isEmpty
                                        ? loc.usernameRequired
                                        : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            onFieldSubmitted: (_) => _signIn(),
                            decoration: InputDecoration(
                              labelText: loc.passwordLabel,
                              hintText: loc.passwordHint,
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                onPressed:
                                    () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? loc.passwordRequired
                                        : null,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged:
                                      (value) => setState(
                                        () => _rememberMe = value ?? false,
                                      ),
                                ),
                              ),
                              Text(loc.rememberMe),
                              const Spacer(),
                              TextButton(
                                onPressed:
                                    () => Navigator.pushNamed(
                                      context,
                                      '/forgot-password',
                                    ),
                                child: Text(loc.forgotPassword),
                              ),
                            ],
                          ),
                        ] else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppConstants.warning.withValues(
                                alpha: isDark ? 0.16 : 0.10,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppConstants.warning.withValues(
                                  alpha: 0.32,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.offline_bolt_outlined,
                                  color: AppConstants.warning,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    loc.offlineLoginHint,
                                    style: const TextStyle(height: 1.45),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child:
                              connectivityService.isOnline
                                  ? ModernAuthButton(
                                    label: loc.signInButton,
                                    icon: Icons.login_rounded,
                                    isLoading: _isLoading,
                                    onPressed: _isLoading ? null : _signIn,
                                  )
                                  : _OfflineAccessButton(
                                    label: loc.continueOfflineButton,
                                    isLoading: _isLoading,
                                    onPressed: _signIn,
                                  ),
                        ),
                        if (connectivityService.isOnline) ...[
                          const SizedBox(height: 12),
                          ModernAuthSecondaryButton(
                            label: loc.dontHaveAccount,
                            icon: Icons.person_add_alt_1_rounded,
                            onPressed:
                                () => Navigator.pushNamed(context, '/register'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }
}

class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge({
    required this.isOnline,
    required this.onlineLabel,
    required this.offlineLabel,
  });

  final bool isOnline;
  final String onlineLabel;
  final String offlineLabel;

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? AppConstants.primaryGreen : AppConstants.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? onlineLabel : offlineLabel,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineAccessButton extends StatelessWidget {
  const _OfflineAccessButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppConstants.warning, Color(0xFFB96A18)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppConstants.warning.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 58,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        isLoading
                            ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(
                              Icons.offline_bolt_rounded,
                              color: Colors.white,
                              size: 21,
                            ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white.withValues(alpha: 0.88),
                    size: 21,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
