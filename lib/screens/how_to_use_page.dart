import 'package:flutter/material.dart';
import 'package:kinondoni_openspace_app/utils/constants.dart';
import '../l10n/app_localizations.dart';

class HowToUsePage extends StatelessWidget {
  const HowToUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.howToUseTitle),
        centerTitle: true,
        backgroundColor: AppConstants.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, loc),
            const SizedBox(height: 24),
            _buildSection(
              context,
              Icons.cloud_off,
              loc.offlineModeTitle,
              loc.offlineModeDescription,
              Colors.blue,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              Icons.wifi,
              loc.firstTimeUseTitle,
              loc.firstTimeUseDescription,
              Colors.green,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              Icons.offline_bolt,
              loc.offlineAccessTitle,
              loc.offlineAccessDescription,
              Colors.orange,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              Icons.sync,
              loc.autoSyncTitle,
              loc.autoSyncDescription,
              Colors.purple,
            ),
            const SizedBox(height: 24),
            _buildTipsSection(context, loc),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  loc.gotItButton,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations loc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppConstants.primaryBlue.withOpacity(isDark ? 0.2 : 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 40, color: AppConstants.primaryBlue),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                loc.howToUseTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black87;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsSection(BuildContext context, AppLocalizations loc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.amber.shade900.withOpacity(0.2) : Colors.amber.shade50;
    final iconColor = isDark ? Colors.amber.shade400 : Colors.amber.shade700;
    final titleColor = isDark ? Colors.amber.shade300 : Colors.amber.shade900;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: iconColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  loc.offlineTipsTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTipItem(context, loc.offlineTip1),
            _buildTipItem(context, loc.offlineTip2),
            _buildTipItem(context, loc.offlineTip3),
            _buildTipItem(context, loc.offlineTip4),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, String tip) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(fontSize: 14, height: 1.4, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
