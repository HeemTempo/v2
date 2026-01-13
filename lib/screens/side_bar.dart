import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    // Define menu items here for extensibility
    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.help_outline, 'title': locale.helpFaqs, 'route': '/help-support'},
      {'icon': Icons.description, 'title': locale.termsConditions, 'route': '/terms'},
      {'icon': Icons.lock, 'title': locale.privacyPolicyMenu, 'route': '/privacy'}, // Assuming route exists or placeholder
      {'icon': Icons.star, 'title': locale.rateApp, 'action': () {}}, // Custom action example
      {'divider': true},
      {'icon': Icons.info_outline, 'title': locale.about, 'action': () {}},
    ];

    return Drawer(
      child: Column(
        children: [
          // 🔹 Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppConstants.primaryBlue, AppConstants.primaryBlue.withOpacity(0.8)],
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Online",
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
                  locale.version,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
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
                  leading: Icon(item['icon'] as IconData, color: Colors.grey[700]),
                  title: Text(
                    item['title'] as String,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    if (item.containsKey('route')) {
                      Navigator.pushReplacementNamed(context, item['route'] as String);
                    } else if (item.containsKey('action')) {
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

          // 🔹 Bottom Actions (Settings & Sign Out)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              children: [
                _buildBottomButton(
                  context,
                  icon: Icons.settings,
                  label: locale.settings,
                  color: Colors.grey[800]!,
                  onTap: () => Navigator.pushReplacementNamed(context, "/setting"),
                ),
                const SizedBox(height: 8),
                _buildBottomButton(
                  context,
                  icon: Icons.logout,
                  label: locale.signOut,
                  color: Colors.redAccent,
                  onTap: () => Navigator.pushReplacementNamed(context, "/login"),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
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
