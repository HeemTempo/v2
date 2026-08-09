import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/repository/profile_repository.dart';
import '../l10n/app_localizations.dart';
import '../providers/user_provider.dart';
import '../service/auth_service.dart';
import '../utils/constants.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _usernameController.text = context.read<UserProvider>().user.username;
    _loadProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ProfileRepository.fetchProfile();
      if (!mounted) return;
      _usernameController.text =
          profile['username']?.toString().trim().isNotEmpty == true
              ? profile['username'].toString().trim()
              : _usernameController.text;
      _emailController.text = profile['email']?.toString().trim() ?? '';
      setState(() {
        _isLoading = false;
        _loadError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = _errorMessage(error);
      });
    }
  }

  Future<void> _saveChanges() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false) || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      final updatedProfile = await ProfileRepository.updateProfile(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
      );
      if (!mounted) return;

      final provider = context.read<UserProvider>();
      final updatedUser = provider.user.copyWith(
        username:
            updatedProfile['username']?.toString().trim().isNotEmpty == true
                ? updatedProfile['username'].toString().trim()
                : _usernameController.text.trim(),
      );
      provider.setUser(updatedUser);
      await AuthService().cacheUserCredentials(updatedUser);
      if (!mounted) return;

      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.profileUpdatedSuccess),
          backgroundColor: AppConstants.primaryGreen,
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage(error)),
          backgroundColor: AppConstants.danger,
        ),
      );
    }
  }

  String _errorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppConstants.darkBackground : AppConstants.pageBackground,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppConstants.darkBackground : AppConstants.pageBackground,
        foregroundColor: isDark ? Colors.white : AppConstants.navy,
        elevation: 0,
        title: Text(
          loc.editProfileTitle,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  color: AppConstants.primaryGreen,
                ),
              )
              : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_loadError != null) ...[
                          Container(
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: AppConstants.danger.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: AppConstants.danger.withValues(
                                  alpha: 0.25,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  color: AppConstants.danger,
                                ),
                                const SizedBox(width: 9),
                                Expanded(child: Text(_loadError!)),
                                TextButton(
                                  onPressed: () {
                                    setState(() => _isLoading = true);
                                    _loadProfile();
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        _ProfileField(
                          controller: _usernameController,
                          label: loc.usernameLabel,
                          icon: Icons.person_outline_rounded,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            final username = value?.trim() ?? '';
                            if (username.isEmpty) return loc.usernameRequired;
                            if (username.length < 3) {
                              return 'Username must have at least 3 characters.';
                            }
                            return null;
                          },
                          isDark: isDark,
                        ),
                        const SizedBox(height: 15),
                        _ProfileField(
                          controller: _emailController,
                          label: loc.emailLabel,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _saveChanges(),
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            if (email.isEmpty) return loc.emailRequired;
                            if (!RegExp(
                              r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                            ).hasMatch(email)) {
                              return loc.emailInvalid;
                            }
                            return null;
                          },
                          isDark: isDark,
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed:
                                    _isSaving
                                        ? null
                                        : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                  foregroundColor:
                                      isDark ? Colors.white : AppConstants.navy,
                                  side: BorderSide(
                                    color:
                                        isDark
                                            ? AppConstants.darkBorder
                                            : AppConstants.border,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                                child: Text(loc.cancelButton),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: _isSaving ? null : _saveChanges,
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                  backgroundColor: AppConstants.primaryGreen,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                                child:
                                    _isSaving
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                        : Text(
                                          loc.saveChanges,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    required this.isDark,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?) validator;
  final bool isDark;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: TextStyle(color: isDark ? Colors.white : AppConstants.navy),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppConstants.primaryGreen),
        filled: true,
        fillColor: isDark ? AppConstants.darkCard : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppConstants.darkBorder : AppConstants.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppConstants.darkBorder : AppConstants.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppConstants.primaryGreen,
            width: 1.6,
          ),
        ),
      ),
    );
  }
}
