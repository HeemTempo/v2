import 'package:flutter/material.dart';
import 'package:kinondoni_openspace_app/l10n/app_localizations.dart';
import 'package:quickalert/quickalert.dart';
import 'package:kinondoni_openspace_app/service/auth_service.dart';
import 'package:kinondoni_openspace_app/utils/constants.dart';

import 'sign_in.dart';
import '../widget/modern_auth_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isChecked = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  void _submitForm() async {
    final loc = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    if (!_isChecked) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: loc.signUpErrorAgree,
        confirmBtnText: loc.okButton,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.register(
        username: _usernameController.text.trim(),
        email:
            _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      if (user.isStaff == true || user.role?.toLowerCase() == "admin") {
        throw Exception('Administrators are not allowed to register here.');
      }

      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: loc.signUpSuccess,
        confirmBtnText: loc.okButton,
        onConfirmBtnTap: () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SignInScreen()),
            );
          }
        },
      );
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      setState(() => _errorMessage = errorMessage);

      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        text: _errorMessage!,
        confirmBtnText: loc.okButton,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppConstants.darkBackground : AppConstants.pageBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton.outlined(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 126,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/kinondoni-booking-v2.jpg',
                          fit: BoxFit.cover,
                          alignment: const Alignment(0.15, 0.25),
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xC907543F), Color(0x1807543F)],
                            ),
                          ),
                        ),
                        const Positioned(
                          left: 16,
                          bottom: 15,
                          child: Icon(
                            Icons.person_add_alt_1_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  loc.createAccountTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: isDark ? Colors.white : AppConstants.navy,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.signUpSubtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.white70 : AppConstants.muted,
                  ),
                ),
                const SizedBox(height: 28),
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.danger.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppConstants.danger),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                TextFormField(
                  controller: _usernameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: loc.usernameLabel,
                    hintText: loc.usernameHint,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                  validator:
                      (value) =>
                          value == null || value.trim().isEmpty
                              ? loc.usernameRequired
                              : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: loc.emailLabel,
                    hintText: loc.emailHint,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return loc.emailRequired;
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return loc.emailInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: loc.passwordLabel,
                    hintText: loc.passwordHint,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed:
                          () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return loc.passwordRequired;
                    }
                    if (value.length < 8) return loc.passwordMinLength;
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: loc.passwordConfirmLabel,
                    hintText: loc.passwordHint,
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return loc.passwordConfirmRequired;
                    }
                    if (value != _passwordController.text) {
                      return loc.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => setState(() => _isChecked = !_isChecked),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Checkbox(
                            value: _isChecked,
                            onChanged:
                                (value) =>
                                    setState(() => _isChecked = value ?? false),
                          ),
                        ),
                        Expanded(child: Text(loc.agreeTerms)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ModernAuthButton(
                  label: loc.signUpButton,
                  icon: Icons.person_add_alt_1_rounded,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _submitForm,
                ),
                const SizedBox(height: 12),
                ModernAuthSecondaryButton(
                  label: loc.alreadyHaveAccount,
                  icon: Icons.login_rounded,
                  onPressed:
                      _isLoading
                          ? null
                          : () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignInScreen(),
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
