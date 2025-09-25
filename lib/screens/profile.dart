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
        _error = 'Failed to load profile';
        _isLoading = false;
      });

      if (errorMessage.toLowerCase().contains('authentication') ||
          errorMessage.toLowerCase().contains('token') ||
          errorMessage.toLowerCase().contains('unauthorized')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired or invalid. Please log in again.'),
              duration: Duration(seconds: 2),
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
    final user = Provider.of<UserProvider>(context).user;
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
                title: const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.white,
                  ),
                ),
                centerTitle: true,
              ),
              body: const Center(
                child: Text("Please log in to view your profile."),
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

    return Scaffold(
      backgroundColor: Colors.white, // Changed background to white
      appBar: AppBar(
        backgroundColor: AppConstants.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppConstants.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppConstants.white),
            onPressed: _isLoading ? null : _fetchProfile,
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppConstants.white),
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
      body: _buildBody(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchProfile,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }
    if (_profile == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "No profile data available.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orange, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchProfile,
                child: const Text("Fetch Profile"),
              ),
            ],
          ),
        ),
      );
    }
    String name = _profile?['name'] ?? _profile?['username'] ?? 'N/A';
    String email = _profile?['email'] ?? 'No email provided';
    String? photoUrl =
        _profile?['photoUrl'] ?? _profile?['profile_picture'] ?? _profile?['user']?['profile_picture'];

    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(24.0), // Increased padding for better spacing
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60, // Larger avatar radius
                      backgroundColor: Colors.grey[200],
                      backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                          ? NetworkImage(photoUrl)
                          : null,
                      child: (photoUrl == null || photoUrl.isEmpty)
                          ? Icon(Icons.person, size: 60, color: Colors.grey[500])
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'GENERAL',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryBlue.withOpacity(0.85),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingsItem(
            context,
            icon: Icons.settings_outlined,
            title: 'Profile Settings',
            subtitle: 'Update and modify your profile',
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
            title: 'Privacy',
            subtitle: 'Change your password',
            onTap: () {
              _showPopup(
                context,
                title: 'Privacy Settings',
                message: 'Password change feature coming soon!',
                buttonText: 'Got it!',
                icon: Icons.lock_outline,
                iconColor: Colors.blueAccent,
                onConfirm: () => Navigator.pop(context),
              );
            },
          ),
          _buildSettingsItem(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage your notification preferences',
            onTap: () {
              Navigator.pushNamed(context, '/user-notification');
            },
          ),
          const SizedBox(height: 24),
          Text(
            'ACTIVITY',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryBlue.withOpacity(0.85),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingsItem(
            context,
            icon: Icons.report_problem_outlined,
            title: 'My Reports',
            subtitle: 'View and manage your reports',
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
            title: 'My Bookings',
            subtitle: 'View and manage your bookings',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyBookingsPage(),
              ),
            ),
          ),
        ],
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