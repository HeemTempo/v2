import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openspace_mobile_app/providers/report_provider.dart';
import 'package:openspace_mobile_app/providers/user_provider.dart';
import 'package:openspace_mobile_app/screens/file_attachment_section.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../l10n/app_localizations.dart';

class ReportIssuePage extends StatefulWidget {
  final String? spaceName;
  final double? latitude;
  final double? longitude;
  final String? district;
  final String? street;

  const ReportIssuePage({
    super.key,
    this.spaceName,
    this.latitude,
    this.longitude,
    this.district,
    this.street,
  });

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final List<String> _attachedFiles = []; // For showing file names
  final List<File> _selectedFiles = []; // For uploading actual files

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
// For image/document upload

  bool _isSubmitting = false;
  bool _guidelinesExpanded = false;

  @override
  void initState() {
    super.initState();
    // Defer sync to avoid blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final reportProvider = context.read<ReportProvider>();
          reportProvider.syncPendingReports();
        } catch (e) {
          debugPrint('Error syncing reports: $e');
        }
      }
    });
  }


  void _showAlert(
    QuickAlertType type,
    String message, {
    VoidCallback? onConfirmed,
  }) {
    if (!mounted) return;
    QuickAlert.show(
      context: context,
      type: type,
      text: message,
      showConfirmBtn: true,
      confirmBtnText: AppLocalizations.of(context)!.okButton,
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        if (onConfirmed != null) onConfirmed();
      },
    );
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> pickedFiles = await picker.pickMultiImage(
        imageQuality: 80,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          for (var file in pickedFiles) {
            _attachedFiles.add(file.name);
            _selectedFiles.add(File(file.path));
          }
        });
      }
    } catch (e) {
      print("Image pick error: $e");
    }
  }

  Future<void> _pickGeneralFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          for (var pickedFile in result.files) {
            if (pickedFile.path != null) {
              _attachedFiles.add(pickedFile.name);
              _selectedFiles.add(File(pickedFile.path!));
            }
          }
        });
      }
    } catch (e) {
      print("File pick error: $e");
    }
  }

  void _removeFile(int index) {
    setState(() {
      _attachedFiles.removeAt(index); // Remove file name
      _selectedFiles.removeAt(index); // Remove actual file
    });
  }

  @override
  Widget build(BuildContext context) {
    try {
      final loc = AppLocalizations.of(context)!;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final primaryBlue = Theme.of(context).colorScheme.primary;

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
        title: Text(loc.reportPageTitle),
        backgroundColor: primaryBlue,
        centerTitle: true,
        actions: [
          // Show pending reports count
          Consumer<ReportProvider>(
            builder: (context, provider, _) {
              final count = provider.pendingReportsCount;
              if (count == 0) return const SizedBox.shrink();

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/pending-reports');
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count pending',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Form(
            key: _formKey,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Text(
                        loc.reportHeader,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Location Card
                _InfoCard(
                  icon: Icons.location_on_outlined,
                  title: loc.locationDetailsTitle,
                  children: [
                    _InfoRow(
                      label: loc.spaceNameLabel,
                      value: widget.spaceName ?? loc.notAvailable,
                    ),
                    _InfoRow(
                      label: loc.districtLabel,
                      value: widget.district ?? loc.notAvailable,
                    ),
                    _InfoRow(
                      label: loc.streetLabel,
                      value: widget.street ?? loc.notAvailable,
                    ),
                    _InfoRow(
                      label: loc.coordinatesLabel,
                      value:
                          (widget.latitude != null && widget.longitude != null)
                              ? '${widget.latitude!.toStringAsFixed(5)}°, ${widget.longitude!.toStringAsFixed(5)}°'
                              : loc.notAvailable,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Contact Information
                _InfoCard(
                  icon: Icons.person_outline,
                  title: loc.yourInfoTitle,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration(
                        label: loc.emailLabel,
                        hint: 'your.email@example.com',
                        icon: Icons.email_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        final emailRegex = RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return '${loc.emailLabel} is invalid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration(
                        label: loc.phoneLabel,
                        hint: '+1 (555) 000-0000',
                        icon: Icons.phone_outlined,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Issue Description
                _InfoCard(
                  icon: Icons.edit_outlined,
                  title: loc.issueDescriptionTitle,
                  children: [
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: _inputDecoration(
                        label: loc.issueDescriptionTitle,
                        hint: loc.issueDescriptionHint,
                        icon: Icons.edit,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '${loc.issueDescriptionTitle} is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Attachments
                FileAttachmentSection(
                  selectedFileNames: _attachedFiles,
                  pickImages: _pickImages,
                  pickGeneralFiles: _pickGeneralFiles,
                  removeFile: _removeFile,
                ),

                const SizedBox(height: 30),

                // Reporting Guidelines
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                  child: ExpansionTile(
                    initiallyExpanded: _guidelinesExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _guidelinesExpanded = expanded;
                      });
                    },
                    leading: CircleAvatar(
                      backgroundColor: primaryBlue,
                      child: const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      loc.reportGuidelinesTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                        fontSize: 16,
                      ),
                    ),
                    childrenPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    children: [
                      _GuidelineText(loc.guideline1),
                      _GuidelineText(loc.guideline2),
                      _GuidelineText(loc.guideline3),
                      _GuidelineText(loc.guideline4),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            context.watch<ReportProvider>().isSubmitting
                                ? null
                                : _submitReport,

                        icon:
                            _isSubmitting
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.send),
                        label: Text(
                          _isSubmitting
                              ? loc.submittingLabel
                              : loc.submitReportButton,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isSubmitting ? null : _cancelReport,
                        icon: const Icon(Icons.cancel_outlined),
                        label: Text(
                          loc.cancelButton,
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error building report screen: $e');
      debugPrint('Stack trace: $stackTrace');
      return Scaffold(
        appBar: AppBar(title: const Text('Report Issue')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to load report screen'),
              const SizedBox(height: 8),
              Text('Error: ${e.toString()}', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    IconData? icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: primaryColor) : null,
      filled: true,
      fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
      ),
      labelStyle: TextStyle(
        color: isDark ? Colors.grey[400] : Colors.grey[700],
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[500]),
    );
  }

  void _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    final reportProvider = context.read<ReportProvider>();

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get current user ID
      final userProvider = context.read<UserProvider>();
      final userId = userProvider.user.id;

      // Submit report (provider handles online/offline automatically)
      final report = await reportProvider.submitReport(
        description: _descriptionController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        file: _selectedFiles.isNotEmpty ? _selectedFiles.first : null,
        spaceName: widget.spaceName,
        district: widget.district,
        street: widget.street,
        userId: userId,
        latitude: widget.latitude,
        longitude: widget.longitude,
      );

      if (!mounted) return;

      // Check if report was submitted online or saved offline
      if (report.status == 'pending') {
        // Offline submission
        _showAlert(
          QuickAlertType.info,
          '''
You are offline. Your report has been saved locally and will be submitted automatically when you reconnect.

Report ID: ${report.reportId}
Location: ${report.spaceName ?? 'Not specified'}
Saved Date: ${report.createdAt.toLocal().toString().split('.')[0]}

${reportProvider.pendingReports.length} pending report(s) waiting to sync.
''',
          onConfirmed: () {
            _clearForm();
            Navigator.of(context).pop();
          },
        );
      } else {
        // Online submission successful
        _showAlert(
          QuickAlertType.success,
          '''
Your report has been successfully received.

Report ID: ${report.reportId}
Location: ${report.spaceName ?? 'Not specified'}
Submission Date: ${report.createdAt.toLocal().toString().split('.')[0]}

Thank you for reporting. Our team will review and act as soon as possible.
''',
          onConfirmed: () {
            _clearForm();
            Navigator.of(context).pop();
          },
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showAlert(
        QuickAlertType.error,
        'Failed to submit report: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _cancelReport() {
    _clearForm();
    Navigator.of(context).pop();
  }

  void _clearForm() {
    _emailController.clear();
    _phoneController.clear();
    _descriptionController.clear();
    setState(() {
      _attachedFiles.clear();
    });
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isDark ? primaryColor.withOpacity(0.2) : primaryColor.withOpacity(0.1),
                  child: Icon(icon, color: primaryColor),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: textColor)),
          ),
        ],
      ),
    );
  }
}

class _GuidelineText extends StatelessWidget {
  final String text;

  const _GuidelineText(this.text);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textColor = Theme.of(context).colorScheme.onSurface;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: primaryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, height: 1.4, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
