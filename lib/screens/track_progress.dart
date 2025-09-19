import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../model/Report.dart';
import '../service/openspace_service.dart';
import '../utils/constants.dart';

class TrackProgressScreen extends StatefulWidget {
  const TrackProgressScreen({super.key});

  @override
  _TrackProgressScreenState createState() => _TrackProgressScreenState();
}

class _TrackProgressScreenState extends State<TrackProgressScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _referenceIdController = TextEditingController();
  Report? reportData;
  bool _isLoading = false;
  String? _errorMessage;
  late final OpenSpaceService _openSpaceService;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _openSpaceService = OpenSpaceService();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _referenceIdController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchReportDetails() async {
    final enteredRefId = _referenceIdController.text.trim();
    if (enteredRefId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.enterReferenceIdError;
        reportData = null;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      reportData = null;
    });

    try {
      final reports = await _openSpaceService.getAllReports();
      Report? matchingReport;
      try {
        matchingReport = reports.firstWhere(
          (report) => report.reportId.toLowerCase() == enteredRefId.toLowerCase(),
        );
      } catch (e) {
        matchingReport = null;
      }

      if (!mounted) return;
      setState(() {
        reportData = matchingReport;
        _isLoading = false;
        if (matchingReport == null) {
          _errorMessage = AppLocalizations.of(context)!.noReportFound(enteredRefId);
        } else {
          _animationController.forward(from: 0);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        reportData = null;
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _icon(IconData icon, {Color? color, double size = 18}) {
    return Icon(icon, color: color ?? AppConstants.primaryBlue, size: size);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          loc.trackProgress,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppConstants.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
        ),
        backgroundColor: AppConstants.primaryBlue,
        elevation: 2,
        centerTitle: true,
        leading: Semantics(
          label: loc.backButton,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppConstants.white),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            tooltip: loc.backButton,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: loc.enterReferenceId,
                child: Text(
                  loc.enterReferenceId,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppConstants.primaryBlue,
                        fontSize: 16,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _referenceIdController,
                      decoration: InputDecoration(
                        hintText: loc.enterReferenceIdHint,
                        hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[400],
                            ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppConstants.primaryBlue, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                      onFieldSubmitted: (_) => _fetchReportDetails(),
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _fetchReportDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppConstants.white,
                            ),
                          )
                        : Semantics(
                            label: loc.search,
                            child: Text(
                              loc.search,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppConstants.white,
                                    fontSize: 16,
                                  ),
                            ),
                          ),
                  ),
                ],
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    _errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: AppConstants.primaryBlue),
                        )
                      : reportData == null
                          ? Center(
                              child: Text(
                                loc.enterReferenceIdPrompt,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : _buildReportDetailsView(reportData!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportDetailsView(Report currentReport) {
    final loc = AppLocalizations.of(context)!;
    final String reportId = currentReport.reportId;
    final String spaceName = currentReport.spaceName ?? loc.notAvailable;
    final String formattedDate = DateFormat('MMMM dd, yyyy').format(currentReport.createdAt.toLocal());
    final String description = currentReport.description;
    final String email = currentReport.email ?? loc.notAvailable;
    final String? fileUrl = currentReport.file;
    final bool hasAttachment = fileUrl != null && fileUrl.isNotEmpty;
    final String attachmentName = hasAttachment ? fileUrl.split('/').last : loc.noAttachments;
    final String status = currentReport.status ?? 'Pending';
    final Color statusColor = _getStatusColor(status);
    final String userName = currentReport.user?.username ?? loc.anonymousUser;

    return SingleChildScrollView(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.grey[50],
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _icon(Icons.report_problem, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${loc.reportId}: $reportId',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: 20,
                            color: AppConstants.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Space & Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        _icon(Icons.location_on, size: 20),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            spaceName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Row(
                      children: [
                        _icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          formattedDate,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Submitted by & Email
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        _icon(Icons.person, size: 20),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            userName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Row(
                      children: [
                        _icon(Icons.email, size: 20),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            email,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Description
              Text(
                loc.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppConstants.primaryBlue,
                      fontSize: 18,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                      height: 1.5,
                      fontSize: 16,
                    ),
              ),
              const SizedBox(height: 24),

              // Attachments
              Text(
                loc.attachments,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppConstants.primaryBlue,
                      fontSize: 18,
                    ),
              ),
              const SizedBox(height: 8),
              hasAttachment
                  ? Wrap(
                      spacing: 12,
                      children: [
                        ActionChip(
                          avatar: Icon(Icons.insert_drive_file, color: AppConstants.primaryBlue),
                          label: Text(
                            attachmentName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.attachmentViewNotImplemented)),
                            );
                          },
                        ),
                      ],
                    )
                  : Text(
                      loc.noAttachments,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
              const SizedBox(height: 24),

              // Location
              if (currentReport.latitude != null && currentReport.longitude != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.location,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppConstants.primaryBlue,
                            fontSize: 18,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${loc.latitudeLabel}: ${currentReport.latitude}, ${loc.longitudeLabel}: ${currentReport.longitude}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
