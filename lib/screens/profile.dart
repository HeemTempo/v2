import 'package:flutter/material.dart';
import 'package:kinondoni_openspace_app/data/repository/profile_repository.dart';
import 'package:kinondoni_openspace_app/screens/userreports.dart';
import 'package:kinondoni_openspace_app/utils/constants.dart';
import 'package:kinondoni_openspace_app/screens/misc/access_denied_screen.dart';
import 'package:provider/provider.dart';
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
      });
    } catch (e) {
      if (!mounted) return;
      String errorMessage = e.toString();
      if (errorMessage.startsWith("Exception: ")) {
        errorMessage = errorMessage.substring("Exception: ".length);
      }
      setState(() {
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

    switch (index) {
      case 0:
        Navigator.pop(context, 0);
        break;
      case 1:
        Navigator.pushNamed(context, '/map');
        break;
      case 2:
        // Already on Profile
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = Provider.of<UserProvider>(context).user;
    final theme = Theme.of(context);

    if (user.isAnonymous) {
      // Extract placeholder data for anonymous
      String name = "Guest User";
      String email = "Sign in to see your profile";
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Navigate to access denied screen instead of showing dialog
        // so user has the 'X' and 'Go Home' buttons
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AccessDeniedScreen(featureName: "profile"),
          ),
        );
      });

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
                            AppConstants.primaryBlue.withValues(alpha: 0.7),
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
                          ),
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.person, size: 50, color: Colors.white),
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
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(context, loc.activitySection),
                    const SizedBox(height: 10),
                    _buildSettingsItem(
                      context,
                      icon: Icons.login_rounded,
                      title: "Sign In Required",
                      subtitle: "Please sign in to view your activity",
                      onTap: () => Navigator.pushNamed(context, '/login'),
                    ),
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
                          AppConstants.primaryBlue.withValues(alpha: 0.7),
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
                              color: AppConstants.primaryBlue.withValues(alpha: 0.3),
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
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, loc.activitySection),
                  const SizedBox(height: 10),
                  if (!user.isAnonymous)
                    _buildSettingsItem(
                      context,
                      icon: Icons.notifications_outlined,
                      title: loc.notificationsTitle,
                      subtitle: loc.notificationSettings,
                      onTap: () {
                        Navigator.pushNamed(context, '/user-notification');
                      },
                    ),
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
          backgroundColor: AppConstants.primaryBlue.withValues(alpha: 0.15),
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
          color: AppConstants.grey.withValues(alpha: 0.7),
          size: 28,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      ),
    );
  }
}
