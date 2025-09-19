import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms & Privacy Policy',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppConstants.white,
            fontSize: 24, // Slightly smaller for app bar
          ),
        ),
        backgroundColor: AppConstants.primaryBlue,
        elevation: 0,
        leading: Semantics(
          label: 'Back to previous screen',
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppConstants.white),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            tooltip: 'Back',
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppConstants.primaryBlue,
              AppConstants.primaryBlue.withOpacity(0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  label: 'Terms of Service Heading',
                  child: ExpansionTile(
                    title: Text(
                      'Terms of Service',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    initiallyExpanded: _termsExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _termsExpanded = expanded;
                      });
                    },
                    children: [
                      Semantics(
                        label: 'Terms of Service Content',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            '''
Welcome to OpenSpace, a platform dedicated to enhancing community engagement through reporting issues and booking public spaces. By using OpenSpace, you agree to the following terms, compliant with Tanzania’s e-Government Agency guidelines:

1. **User Responsibilities**:
   - You agree to use OpenSpace for lawful purposes, ensuring all reports and bookings are accurate and respectful of community spaces.
   - Misuse, including false reporting or unauthorized access, may result in account suspension.

2. **Account Usage**:
   - Registered users must provide accurate information during sign-up, including a valid username and contact details.
   - Anonymous users can explore public spaces but cannot access tracking features for reports or bookings.

3. **Content Ownership**:
   - Content submitted (e.g., issue reports, booking requests) may be used by OpenSpace to improve services, anonymized where necessary, in accordance with Tanzania’s Personal Data Protection Act, 2022.
   - Users retain ownership of their content but grant OpenSpace a non-exclusive license to use it for operational purposes.

4. **Liability**:
   - OpenSpace is not liable for damages arising from misuse of the platform or inaccuracies in user-submitted data.
   - Users are responsible for complying with local laws and platform policies.

5. **Updates to Terms**:
   - We may update these terms periodically. Continued use of OpenSpace after updates constitutes acceptance.
   - Notifications of changes will be provided via the app or official communication channels.
                            ''',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppConstants.white,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: 'Privacy Policy Heading',
                  child: ExpansionTile(
                    title: Text(
                      'Privacy Policy',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    initiallyExpanded: _privacyExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _privacyExpanded = expanded;
                      });
                    },
                    children: [
                      Semantics(
                        label: 'Privacy Policy Content',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            '''
At OpenSpace, we prioritize your privacy and adhere to Tanzania’s Personal Data Protection Act, 2022, and e-Government Agency standards.

1. **Data Collection**:
   - We collect minimal personal data (e.g., username, location for reports/bookings) to enable app functionality.
   - Anonymous users’ interactions are not linked to personal identifiers.

2. **Data Usage**:
   - Data is used to process reports, manage bookings, and enhance community services.
   - Anonymized data may be shared with local authorities for urban planning and safety initiatives.

3. **Data Security**:
   - We employ encryption and secure protocols to protect registered users’ credentials and data.
   - Regular security audits ensure compliance with national regulations.

4. **Cookies and Analytics**:
   - OpenSpace may use cookies or analytics tools to improve user experience. You can opt out via the Settings page.
   - Analytics data is anonymized and used to optimize app performance.

5. **Your Rights**:
   - You have the right to access, correct, or delete your personal data. Contact us via the Help & Support page.
   - Requests for data access or deletion will be processed within 30 days, per regulatory requirements.

For further inquiries, contact support@openspace.tz or use the Help & Support page.
                            ''',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppConstants.white,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Semantics(
                  label: 'Effective Date',
                  child: Center(
                    child: Text(
                      'Effective Date: 30 July 2025',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConstants.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: 'Copyright Notice',
                  child: Center(
                    child: Text(
                      '© 2025 OpenSpace Tanzania',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConstants.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                      minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
                    ),
                    child: Semantics(
                      label: 'Accept and Return',
                      child: Text(
                        'Accept and Return',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}