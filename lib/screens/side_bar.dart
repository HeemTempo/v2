import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/connectivity_service.dart';
import '../service/auth_service.dart';
import '../providers/user_provider.dart';
import '../model/user_model.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  Future<void> _handleSignOut(BuildContext context) async {
    // Clear authentication
    await AuthService.logout();
    
    if (!context.mounted) return;
    
    // Reset user to anonymous
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.setUser(User.anonymous());
    
    // Clear the onboarding flag so user can choose again
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', false);
    
    // Navigate to intro slider (onboarding) screen
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (route) => false, // Remove all previous routes
      );
    }
  }

  void _showAboutDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppConstants.primaryBlue, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(loc.aboutTitle(loc.appName)),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                loc.appName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.version,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                loc.aboutMissionContent,
                style: const TextStyle(height: 1.5),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(context, Icons.business, loc.aboutDeveloper, loc.aboutDeveloperValue),
              const SizedBox(height: 8),
              _buildInfoRow(context, Icons.location_city, loc.aboutLocation, loc.aboutLocationValue),
              const SizedBox(height: 8),
              _buildInfoRow(context, Icons.email, loc.aboutContact, loc.aboutContactValue),
              const SizedBox(height: 16),
              Text(
                loc.aboutKeyFeatures,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildFeatureItem(loc.aboutFeature1),
              _buildFeatureItem(loc.aboutFeature2),
              _buildFeatureItem(loc.aboutFeature3),
              _buildFeatureItem(loc.aboutFeature4),
              _buildFeatureItem(loc.aboutFeature5),
              const SizedBox(height: 16),
              Text(
                loc.aboutCopyright,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.close),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppConstants.primaryBlue),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final connectivityService = Provider.of<ConnectivityService>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Define menu items here for extensibility
    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.help_outline, 'title': locale.helpFaqs, 'route': '/help-support'},
      {'icon': Icons.description, 'title': locale.termsConditions, 'route': '/terms'},
      {'divider': true},
      {
        'icon': Icons.info_outline,
        'title': locale.about,
        'action': () => _showAboutDialog(context)
      },
    ];

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // 🔹 Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor : AppConstants.primaryBlue,
              gradient: isDark ? null : LinearGradient(
                colors: [AppConstants.primaryBlue, AppConstants.primaryBlue.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.park, size: 32, color: AppConstants.primaryBlue),
                    ),
                    const Spacer(),
                    // Dynamic Online/Offline Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: connectivityService.isOnline 
                            ? Colors.green 
                            : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (connectivityService.isOnline 
                                ? Colors.green 
                                : Colors.orange).withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            connectivityService.isOnline 
                                ? Icons.wifi 
                                : Icons.wifi_off,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            connectivityService.isOnline ? "Online" : "Offline",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  locale.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.isAnonymous ? "Anonymous User" : user.username,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Menu Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];

                if (item.containsKey('divider')) {
                  return const Divider(indent: 16, endIndent: 16);
                }

                return ListTile(
                  leading: Icon(
                    item['icon'] as IconData, 
                    color: isDark ? Colors.white70 : Colors.grey[700]
                  ),
                  title: Text(
                    item['title'] as String,
                    style: TextStyle(
                      fontSize: 15, 
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  onTap: () {
                    if (item.containsKey('route')) {
                      Navigator.pushReplacementNamed(context, item['route'] as String);
                    } else if (item.containsKey('action')) {
                      Navigator.pop(context); // Close drawer first
                      (item['action'] as VoidCallback)();
                    }
                  },
                  dense: true,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                );
              },
            ),
          ),

          // 🔹 Bottom Actions (Settings & Sign Out/Login)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.grey[50],
              border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!)),
            ),
            child: Column(
              children: [
                _buildBottomButton(
                  context,
                  icon: Icons.settings,
                  label: locale.settings,
                  color: isDark ? Colors.white70 : Colors.grey[800]!,
                  onTap: () => Navigator.pushReplacementNamed(context, "/setting"),
                ),
                const SizedBox(height: 8),
                user.isAnonymous 
                ? _buildBottomButton(
                    context,
                    icon: Icons.login_rounded,
                    label: "Login / Sign In",
                    color: AppConstants.primaryBlue,
                    onTap: () => Navigator.pushNamed(context, "/login"),
                  )
                : _buildBottomButton(
                    context,
                    icon: Icons.logout,
                    label: locale.signOut,
                    color: Colors.redAccent,
                    onTap: () => _handleSignOut(context),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: isDark ? Colors.white10 : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
