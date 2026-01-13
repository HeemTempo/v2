import 'package:flutter/material.dart';
import 'package:kinondoni_openspace_app/screens/language_change.dart';
import 'package:kinondoni_openspace_app/screens/reported_issue.dart';
import 'package:kinondoni_openspace_app/screens/theme_change.dart';
import 'package:kinondoni_openspace_app/utils/constants.dart';
import '../l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.settings),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        backgroundColor: AppConstants.primaryBlue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildListTile(
            context,
            Icons.language,
            locale.changeLanguage,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LanguageSettings()),
              );
            },
          ),
          _buildListTile(
            context,
            Icons.light_mode,
            locale.theme,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ThemeChangePage()),
              );
            },
          ),
          _buildListTile(
            context,
            Icons.notifications,
            locale.notificationSettings,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportedIssuesPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryBlue),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
