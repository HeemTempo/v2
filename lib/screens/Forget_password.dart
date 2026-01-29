import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:kinondoni_openspace_app/service/PasswordService.dart';
import 'package:kinondoni_openspace_app/utils/constants.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final PasswordService _passService = PasswordService();
  bool _isLoading = false;

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final message = await _passService.requestPasswordReset(_emailController.text.trim());
        
        if (mounted) {
          _showAlert(
            QuickAlertType.success,
            'Password Reset Email Sent',
            message.isNotEmpty 
              ? message 
              : 'A password reset link has been sent to your email address. Please check your inbox and follow the instructions to reset your password.',
            onConfirm: () {
              Navigator.pop(context); // Go back to login screen
            },
          );
        }
      } catch (e) {
        final errorMsg = e.toString().replaceFirst('Exception: ', '');
        
        if (mounted) {
          // Provide detailed error messages based on error type
          String title = 'Password Reset Failed';
          String detailedMessage = errorMsg;
          
          // Handle specific error cases
          if (errorMsg.toLowerCase().contains('email') && 
              (errorMsg.toLowerCase().contains('not found') || 
               errorMsg.toLowerCase().contains('does not exist') ||
               errorMsg.toLowerCase().contains('not registered'))) {
            title = 'Email Not Found';
            detailedMessage = 'The email address "${_emailController.text.trim()}" is not registered in our system. Please check the email address and try again, or sign up for a new account.';
          } else if (errorMsg.toLowerCase().contains('timeout') || 
                     errorMsg.toLowerCase().contains('timed out')) {
            title = 'Request Timeout';
            detailedMessage = 'The request took too long to complete. Please check your internet connection and try again.';
          } else if (errorMsg.toLowerCase().contains('network') || 
                     errorMsg.toLowerCase().contains('connection')) {
            title = 'Network Error';
            detailedMessage = 'Unable to connect to the server. Please check your internet connection and try again.';
          } else if (errorMsg.isEmpty) {
            detailedMessage = 'An unexpected error occurred while processing your request. Please try again later.';
          }
          
          _showAlert(
            QuickAlertType.error,
            title,
            detailedMessage,
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showAlert(
    QuickAlertType type,
    String title,
    String message, {
    VoidCallback? onConfirm,
  }) {
    QuickAlert.show(
      context: context,
      type: type,
      title: title,
      text: message,
      confirmBtnText: 'OK',
      confirmBtnColor: type == QuickAlertType.success ? Colors.green : AppConstants.primaryBlue,
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        if (onConfirm != null) onConfirm();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? Colors.greenAccent : AppConstants.primaryBlue;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Forgot Password', style: TextStyle(color: isDark ? Colors.white : Colors.white)),
        backgroundColor: AppConstants.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_reset_rounded,
                  size: 80,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Reset Your Password',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppConstants.primaryBlue,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Enter your email address and we will send you a link to reset your password.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white60 : Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              TextFormField(
                controller: _emailController,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'example@email.com',
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : AppConstants.primaryBlue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accentColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.email_outlined, color: accentColor),
                  filled: true,
                  fillColor: isDark ? theme.cardColor : Colors.grey[50],
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Send Reset Link',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Back to Login',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
