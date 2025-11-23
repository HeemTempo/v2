import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/data/repository/profile_repository.dart';
import 'package:openspace_mobile_app/screens/userreports.dart';
import 'package:openspace_mobile_app/utils/constants.dart';
import 'package:openspace_mobile_app/screens/edit_profile.dart';
import 'package:openspace_mobile_app/screens/pop_card.dart';
import 'package:provider/provider.dart';
import '../utils/alert/access_denied_dialog.dart';
import '../widget/custom_navigation_bar.dart';
import 'bookings.dart';
import '../providers/user_provider.dart';
import '../l10n/app_localizations.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  String? _error;
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (!user.isAnonymous) {
      _fetchProfile();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final profileData = await ProfileRepository.fetchProfile();
      if (!mounted) return;
      setState(() {
        _profile = profileData;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      String errorMessage = e.toString();
      if (errorMessage.startsWith("Exception: ")) {
        errorMessage = errorMessage.substring("Exception: ".length);
      }
      setState(() {
        _error = AppLocalizations.of(context)!.profileFailedLoad;
        _isLoading = false;
      });

      if (errorMessage.toLowerCase().contains('authentication') ||
          errorMessage.toLowerCase().contains('token') ||
          errorMessage.toLowerCase().contains('unauthorized')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.sessionExpired),
              duration: const Duration(seconds: 2),
            ),
          );
          Future.delayed(const Duration(milliseconds: 2100), () {
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            }
          });
        }
      }
    }
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/map');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/user-profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = Provider.of<UserProvider>(context).user;
    final theme = Theme.of(context);

    if (user.isAnonymous) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAccessDeniedDialog(context, featureName: "profile");
      });
      return Container(
        color: AppConstants.primaryBlue,
        child: SafeArea(
          top: false,
          child: ClipRect(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: AppConstants.primaryBlue,
                title: Text(
                  loc.profileTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.white,
                  ),
                ),
                centerTitle: true,
              ),
              body: Center(
                child: Text(loc.profileNoLogin),
              ),
              bottomNavigationBar: CustomBottomNavBar(
                currentIndex: _currentIndex,
                onTap: _onNavTap,
              ),
            ),
          ),
        ),
      );
    }

    // Extract profile data safely
    String name = _profile?['name'] ?? _profile?['username'] ?? loc.notAvailable;
    String email = _profile?['email'] ?? loc.notAvailable;
    String? photoUrl =
        _profile?['photoUrl'] ?? _profile?['profile_picture'] ?? _profile?['user']?['profile_picture'];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280.0,
            floating: false,
            pinned: true,
            backgroundColor: AppConstants.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppConstants.primaryBlue,
                          AppConstants.primaryBlue.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                              ? NetworkImage(photoUrl)
                              : null,
                          child: (photoUrl == null || photoUrl.isEmpty)
                              ? Icon(Icons.person, size: 50, color: Colors.grey[500])
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _isLoading ? null : _fetchProfile,
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: _isLoading || _error != null
                    ? null
                    : () {
                        if (_profile != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfilePage(),
                            ),
                          );
                        }
                      },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, loc.generalSection),
                  const SizedBox(height: 10),
                  _buildSettingsItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: loc.profileSettings,
                    subtitle: loc.profileSettingsSubtitle,
                    onTap: () {
                      if (_profile != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfilePage(),
                          ),
                        );
                      }
                    },
                  ),
                  _buildSettingsItem(
                    context,
                    icon: Icons.lock_outline,
                    title: loc.privacy,
                    subtitle: loc.privacySubtitle,
                    onTap: () {
                      _showPopup(
                        context,
                        title: loc.privacyPopupTitle,
                        message: loc.privacyPopupMessage,
                        buttonText: loc.privacyPopupButton,
                        icon: Icons.lock_outline,
                        iconColor: Colors.blueAccent,
                        onConfirm: () => Navigator.pop(context),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: loc.notificationsTitle,
                    subtitle: loc.notificationSettings,
                    onTap: () {
                      Navigator.pushNamed(context, '/user-notification');
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, loc.activitySection),
                  const SizedBox(height: 10),
                  _buildSettingsItem(
                    context,
                    icon: Icons.report_problem_outlined,
                    title: loc.myReports,
                    subtitle: loc.myReportsSubtitle,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserReportsPage(),
                      ),
                    ),
                  ),
                  _buildSettingsItem(
                    context,
                    icon: Icons.event_available_outlined,
                    title: loc.myBookings,
                    subtitle: loc.myBookingsSubtitle,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyBookingsPage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppConstants.primaryBlue,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: AppConstants.primaryBlue.withOpacity(0.15),
          child: Icon(icon, color: AppConstants.primaryBlue, size: 24),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppConstants.grey.withOpacity(0.7),
          size: 28,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      ),
    );
  }

  void _showPopup(
    BuildContext context, {
    required String title,
    required String message,
    required String buttonText,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return PopupCard(
          title: title,
          message: message,
          buttonText: buttonText,
          icon: icon,
          iconColor: iconColor,
          onConfirm: onConfirm,
        );
      },
    );
  }
}
