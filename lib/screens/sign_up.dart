import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/l10n/app_localizations.dart';
import 'package:quickalert/quickalert.dart';
import 'package:openspace_mobile_app/service/auth_service.dart';
import 'package:openspace_mobile_app/utils/constants.dart';

import 'sign_in.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      if (user.isStaff == true || user.role?.toLowerCase() == "admin") {
        throw Exception(
          loc.adminNotAllowed ?? "Admins are not allowed to register here.",
        );
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
                    elevation: 10.0,
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
                              loc.createAccountTitle,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              loc.signUpSubtitle,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: loc.usernameLabel,
                                hintText: loc.usernameHint,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? loc.usernameRequired
                                      : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: loc.emailLabel,
                                hintText: loc.emailHint,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return loc.emailRequired;
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
                                  return loc.emailInvalid;
                                return null;
                              },
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
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return loc.passwordRequired;
                                if (value.length < 8)
                                  return loc.passwordMinLength;
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: loc.passwordConfirmLabel,
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
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return loc.passwordConfirmRequired;
                                if (value != _passwordController.text)
                                  return loc.passwordsDoNotMatch;
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Checkbox(
                                  value: _isChecked,
                                  onChanged: (value) =>
                                      setState(() => _isChecked = value!),
                                ),
                                Flexible(child: Text(loc.agreeTerms)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.primaryBlue,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        loc.signUpButton,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const SignInScreen(),
                                        ),
                                      ),
                              child: Text(
                                loc.alreadyHaveAccount,
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
