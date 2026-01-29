import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:kinondoni_openspace_app/utils/constants.dart';
import '../widget/faqs.dart';
import '../l10n/app_localizations.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  bool _showContactForm = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.helpSupportTitle, style: const TextStyle(color: AppConstants.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        backgroundColor: AppConstants.primaryBlue,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.greenAccent.withValues(alpha: 0.3)
                      : AppConstants.primaryBlue.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.support_agent, 
                        size: 40, 
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.greenAccent 
                            : AppConstants.primaryBlue,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.needHelpTitle,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context)!.needHelpSubtitle,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showContactForm = !_showContactForm;
                      });
                    },
                    icon: Icon(_showContactForm ? Icons.close : Icons.email),
                    label: Text(_showContactForm ? AppLocalizations.of(context)!.hideContactForm : AppLocalizations.of(context)!.contactSupport),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contact Form
            if (_showContactForm) ...[ 
              const SizedBox(height: 20),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.message, color: AppConstants.primaryBlue),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.sendMessageTitle,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _messageController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.messageHint,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[50],
                            prefixIcon: Icon(Icons.edit, color: AppConstants.primaryBlue),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.messageRequired;
                            }
                            if (value.length < 10) {
                              return AppLocalizations.of(context)!.messageTooShort;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.success,
                                  title: AppLocalizations.of(context)!.messageSentTitle,
                                  text: AppLocalizations.of(context)!.messageSentContent,
                                  confirmBtnColor: AppConstants.primaryBlue,
                                );

                                setState(() {
                                  _showContactForm = false;
                                  _messageController.clear();
                                });
                              }
                            },
                            icon: const Icon(Icons.send),
                            label: Text(AppLocalizations.of(context)!.sendMessageButton),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: AppConstants.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 30),
            
            // FAQs Section
            Row(
              children: [
                Icon(
                  Icons.question_answer, 
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.greenAccent 
                      : AppConstants.primaryBlue,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.faqTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Account & Authentication FAQs
            _buildFAQCategory(
              AppLocalizations.of(context)!.faqCategoryAccount,
              Icons.account_circle,
              [
                FAQItem(
                  AppLocalizations.of(context)!.faqQuestionResetPass,
                  AppLocalizations.of(context)!.faqAnswerResetPass,
                ),
                FAQItem(
                  AppLocalizations.of(context)!.faqQuestionAnonymous,
                  AppLocalizations.of(context)!.faqAnswerAnonymous,
                ),
                FAQItem(
                  AppLocalizations.of(context)!.faqQuestionUpdateProfile,
                  AppLocalizations.of(context)!.faqAnswerUpdateProfile,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Reports & Bookings FAQs
            _buildFAQCategory(
              AppLocalizations.of(context)!.faqCategoryReports,
              Icons.report_problem,
              [
                FAQItem(
                  AppLocalizations.of(context)!.faqQuestionFindReports,
                  AppLocalizations.of(context)!.faqAnswerFindReports,
                ),
                FAQItem(
                  AppLocalizations.of(context)!.faqQuestionBookSpace,
                  AppLocalizations.of(context)!.faqAnswerBookSpace,
                ),
                FAQItem(
                  AppLocalizations.of(context)!.faqQuestionCancelBooking,
                  AppLocalizations.of(context)!.faqAnswerCancelBooking,
                ),
                FAQItem(
                  AppLocalizations.of(context)!.faqQuestionReportResponse,
                  AppLocalizations.of(context)!.faqAnswerReportResponse,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Technical FAQs
            _buildFAQCategory(
              AppLocalizations.of(context)!.faqCategoryTechnical,
              Icons.settings,
              [
                FAQItem(
                  AppLocalizations.of(context)!.faqQuestionOffline,
                  AppLocalizations.of(context)!.faqAnswerOffline,
                ),
                FAQItem(
                  AppLocalizations.of(context)!.faqQuestionLanguage,
                  AppLocalizations.of(context)!.faqAnswerLanguage,
                ),
                FAQItem(
                  AppLocalizations.of(context)!.faqQuestionMapIssue,
                  AppLocalizations.of(context)!.faqAnswerMapIssue,
                ),
                FAQItem(
                  AppLocalizations.of(context)!.faqQuestionCrash,
                  AppLocalizations.of(context)!.faqAnswerCrash,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Contact Information Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.stillNeedHelp,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildContactInfo(Icons.email, AppLocalizations.of(context)!.contactEmailLabel, 'support@openspace.go.tz'),
                    const SizedBox(height: 8),
                    _buildContactInfo(Icons.phone, AppLocalizations.of(context)!.contactPhoneLabel, '+255 750666252')
              
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
            Center(
              child: Text(
                AppLocalizations.of(context)!.copyrightFooter,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQCategory(String title, IconData icon, List<FAQItem> faqs) {
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
                Icon(icon, color: AppConstants.primaryBlue, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...faqs,
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppConstants.primaryBlue),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}
