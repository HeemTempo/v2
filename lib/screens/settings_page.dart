import 'package:flutter/material.dart';
import 'package:kinondoni_openspace_app/screens/how_to_use_page.dart';
import 'package:kinondoni_openspace_app/screens/language_change.dart';
import 'package:kinondoni_openspace_app/screens/offline_map_download_screen.dart';
import 'package:kinondoni_openspace_app/screens/theme_change.dart';
import 'package:kinondoni_openspace_app/utils/constants.dart';
import '../l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, this.showBackButton = true});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.settings),
        centerTitle: false,
        automaticallyImplyLeading: showBackButton,
        leading:
            showBackButton
                ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.maybePop(context),
                )
                : null,
        backgroundColor:
            isDark ? AppConstants.darkBackground : AppConstants.pageBackground,
        foregroundColor: isDark ? Colors.white : AppConstants.navy,
        elevation: 0,
      ),
      backgroundColor:
          isDark ? AppConstants.darkBackground : AppConstants.pageBackground,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        children: [
          _buildListTile(context, Icons.help_outline, locale.howToUseTitle, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HowToUsePage()),
            );
          }),
          _buildListTile(
            context,
            Icons.map_outlined,
            locale.offlineMapsTitle,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OfflineMapDownloadScreen(),
                ),
              );
            },
          ),
          _buildListTile(context, Icons.language, locale.changeLanguage, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LanguageSettings()),
            );
          }),
          _buildListTile(context, Icons.light_mode, locale.theme, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ThemeChangePage()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isDark ? AppConstants.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: isDark ? AppConstants.darkBorder : AppConstants.border,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 6,
          ),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppConstants.primaryGreenSoft,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppConstants.primaryGreen, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
          onTap: onTap,
        ),
      ),
    );
  }
}
