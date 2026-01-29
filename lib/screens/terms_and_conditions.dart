import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';

class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({super.key});

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  bool _termsExpanded = true;
  bool _privacyExpanded = true;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Environment-aware accent color
    final accentColor = isDark ? Colors.greenAccent : AppConstants.primaryBlue;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.termsConditions,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isDark ? theme.cardColor : AppConstants.primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          tooltip: loc.backButton,
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Terms of Service Section
              Card(
                elevation: isDark ? 4 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  initiallyExpanded: _termsExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _termsExpanded = expanded;
                    });
                  },
                  leading: Icon(Icons.description, color: accentColor, size: 28),
                  title: Text(
                    loc.termsOfService,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        '''${loc.termsContent}
                        
1. **${loc.termsUserResponsibilitiesTitle}**:
   - ${loc.termsUserResponsibilitiesContent}

2. **${loc.termsAccountUsageTitle}**:
   - ${loc.termsAccountUsageContent}

3. **${loc.termsContentOwnershipTitle}**:
   - ${loc.termsContentOwnershipContent}

4. **${loc.termsLiabilityTitle}**:
   - ${loc.termsLiabilityContent}

5. **${loc.termsUpdatesTitle}**:
   - ${loc.termsUpdatesContent}''',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Privacy Policy Section
              Card(
                elevation: isDark ? 4 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  initiallyExpanded: _privacyExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _privacyExpanded = expanded;
                    });
                  },
                  leading: Icon(Icons.privacy_tip, color: accentColor, size: 28),
                  title: Text(
                    loc.privacyPolicy,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        '''${loc.privacyContent}

1. **${loc.privacyDataCollectionTitle}**:
   - ${loc.privacyDataCollectionContent}

2. **${loc.privacyDataUsageTitle}**:
   - ${loc.privacyDataUsageContent}

3. **${loc.privacyDataSecurityTitle}**:
   - ${loc.privacyDataSecurityContent}

4. **${loc.privacyCookiesTitle}**:
   - ${loc.privacyCookiesContent}

5. **${loc.privacyUserRightsTitle}**:
   - ${loc.privacyUserRightsContent}

${loc.privacyInquiries}''',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Footer Information
              Center(
                child: Column(
                  children: [
                    Text(
                      loc.effectiveDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.copyrightNotice,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Accept Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check_circle),
                  label: Text(loc.okButton),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
