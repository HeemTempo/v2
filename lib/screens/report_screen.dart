import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kinondoni_openspace_app/providers/report_provider.dart';
import 'package:kinondoni_openspace_app/providers/user_provider.dart';
import 'package:kinondoni_openspace_app/screens/file_attachment_section.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/constants.dart';

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
  final TextEditingController _descriptionController = TextEditingController();
  // For image/document upload

  bool _isSubmitting = false;
  bool _guidelinesExpanded = false;

  @override
  void initState() {
    super.initState();
    // Sync is handled automatically by ReportProvider when connectivity changes
    // No need to sync on every screen load - this prevents UI freezing
  }

  Future<void> _showSubmissionResult({
    required _ReportResultType type,
    required String title,
    required String message,
    String? reportId,
  }) async {
    if (!mounted) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;
    final color = switch (type) {
      _ReportResultType.success => AppConstants.primaryGreen,
      _ReportResultType.queued => AppConstants.info,
      _ReportResultType.failure => AppConstants.danger,
    };
    final icon = switch (type) {
      _ReportResultType.success => Icons.check_rounded,
      _ReportResultType.queued => Icons.cloud_done_rounded,
      _ReportResultType.failure => Icons.close_rounded,
    };

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppConstants.navy.withValues(alpha: 0.62),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final surface = isDark ? AppConstants.darkCard : Colors.white;
        final foreground = isDark ? AppConstants.darkText : AppConstants.navy;
        final secondary =
            isDark ? AppConstants.darkTextSecondary : AppConstants.muted;

        return SafeArea(
          top: false,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              22,
              10,
              22,
              22 + MediaQuery.paddingOf(sheetContext).bottom,
            ),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.34 : 0.2),
                  blurRadius: 34,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? AppConstants.darkTextSecondary.withValues(
                              alpha: 0.45,
                            )
                            : AppConstants.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.22 : 0.11),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 29),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 23,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.35,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondary, fontSize: 14, height: 1.5),
                ),
                if (reportId != null && reportId.trim().isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? AppConstants.darkCardAlt
                              : AppConstants.pageBackground,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color:
                            isDark
                                ? AppConstants.darkBorder
                                : AppConstants.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.tag_rounded, color: color, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizations.reportReferenceLabel,
                                style: TextStyle(
                                  color: secondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                reportId,
                                style: TextStyle(
                                  color: foreground,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    type == _ReportResultType.failure
                        ? localizations.reportTryAgainButton
                        : localizations.reportDoneButton,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
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
      debugPrint('Image pick error: $e');
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
      debugPrint('File pick error: $e');
    }
  }

  void _removeFile(int index) {
    setState(() {
      _attachedFiles.removeAt(index); // Remove file name
      _selectedFiles.removeAt(index); // Remove actual file
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      final loc = AppLocalizations.of(context)!;
      final primaryColor = Theme.of(context).colorScheme.primary;
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            loc.reportIssue,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          backgroundColor:
              isDark ? AppConstants.darkBackground : AppConstants.primaryGreen,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
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
                          color: AppConstants.warning,
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Form(
              key: _formKey,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? AppConstants.darkCardAlt
                              : AppConstants.primaryGreenSoft,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color:
                            isDark
                                ? AppConstants.darkBorder
                                : AppConstants.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                isDark ? AppConstants.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.campaign_rounded,
                            color: AppConstants.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            loc.reportHeader,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Issue Description
                  _InfoCard(
                    icon: Icons.edit_note_rounded,
                    title: loc.reportFormSectionTitle,
                    children: [
                      TextFormField(
                        controller: _descriptionController,
                        minLines: 5,
                        maxLines: 8,
                        maxLength: 1200,
                        textCapitalization: TextCapitalization.sentences,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: _inputDecoration(
                          label: loc.issueDescriptionTitle,
                          hint: loc.issueDescriptionHint,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return loc.reportDescriptionRequired;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Supporting evidence
                  FileAttachmentSection(
                    selectedFileNames: _attachedFiles,
                    pickImages: _pickImages,
                    pickGeneralFiles: _pickGeneralFiles,
                    removeFile: _removeFile,
                  ),

                  const SizedBox(height: 20),

                  // Optional contact information
                  _InfoCard(
                    icon: Icons.alternate_email_rounded,
                    title: loc.reportContactOptionalTitle,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: _inputDecoration(
                          label: loc.emailLabel,
                          hint: loc.emailHint,
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
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Reporting Guidelines
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color:
                            isDark
                                ? AppConstants.darkBorder
                                : AppConstants.border,
                      ),
                    ),
                    elevation: 0,
                    child: ExpansionTile(
                      initiallyExpanded: _guidelinesExpanded,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _guidelinesExpanded = expanded;
                        });
                      },
                      leading: CircleAvatar(
                        backgroundColor: primaryColor,
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        loc.reportGuidelinesTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
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

                  // Actions
                  FilledButton.icon(
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
                            : const Icon(Icons.send_rounded, size: 21),
                    label: Text(
                      _isSubmitting
                          ? loc.submittingLabel
                          : loc.submitReportButton,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      backgroundColor: AppConstants.primaryGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppConstants.primaryGreen
                          .withValues(alpha: 0.45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isSubmitting ? null : _cancelReport,
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      foregroundColor:
                          isDark
                              ? AppConstants.darkTextSecondary
                              : AppConstants.muted,
                    ),
                    child: Text(
                      loc.cancelButton,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
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
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppConstants.danger,
              ),
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
    return InputDecoration(
      labelText: label,
      hintText: hint,
      alignLabelWithHint: true,
      prefixIcon: icon != null ? Icon(icon, color: primaryColor) : null,
      filled: true,
      fillColor: isDark ? AppConstants.darkCardAlt : Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? AppConstants.darkBorder : AppConstants.border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? AppConstants.darkBorder : AppConstants.border,
        ),
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
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.error,
          width: 2,
        ),
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
        file: _selectedFiles.isNotEmpty ? _selectedFiles.first : null,
        spaceName: widget.spaceName,
        district: widget.district,
        street: widget.street,
        userId: userId,
        latitude: widget.latitude,
        longitude: widget.longitude,
      );

      if (!mounted) return;

      if (report.status == 'pending') {
        await _showSubmissionResult(
          type: _ReportResultType.queued,
          title: AppLocalizations.of(context)!.reportQueuedTitle,
          message: AppLocalizations.of(context)!.reportQueuedMessage,
          reportId: report.reportId,
        );
      } else {
        await _showSubmissionResult(
          type: _ReportResultType.success,
          title: AppLocalizations.of(context)!.reportSuccessTitle,
          message: AppLocalizations.of(context)!.reportSuccessMessage,
          reportId: report.reportId,
        );
      }

      if (!mounted) return;
      _clearForm();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      debugPrint('Failed to submit report: $e');
      await _showSubmissionResult(
        type: _ReportResultType.failure,
        title: AppLocalizations.of(context)!.reportFailedTitle,
        message: AppLocalizations.of(context)!.reportFailedMessage,
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
    _descriptionController.clear();
    setState(() {
      _attachedFiles.clear();
      _selectedFiles.clear();
    });
  }
}

enum _ReportResultType { success, queued, failure }

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
    final foreground = isDark ? AppConstants.darkText : AppConstants.navy;
    final border = isDark ? AppConstants.darkBorder : AppConstants.border;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: AppConstants.navy.withValues(alpha: isDark ? 0.14 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppConstants.primaryGreen.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: AppConstants.primaryGreen, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
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
