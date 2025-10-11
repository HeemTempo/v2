import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:openspace_mobile_app/providers/booking_provider.dart';
import 'package:openspace_mobile_app/service/auth_service.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:openspace_mobile_app/utils/constants.dart';

class BookingPage extends StatefulWidget {
  final int spaceId;
  final String? spaceName;
  const BookingPage({super.key, required this.spaceId, this.spaceName});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();

  // User input fields
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _activitiesController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    if (widget.spaceName != null) {
      _locationController.text = widget.spaceName!;
    }

    // Auto-sync pending bookings when page opens
    Future.microtask(() {
      final bookingProvider = context.read<BookingProvider>();
      bookingProvider.syncPendingBookings();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Validation Error',
        text: 'Please select a start date.',
      );
      return;
    }

    if (_endDate != null && _endDate!.isBefore(_startDate!)) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Validation Error',
        text: 'End date cannot be before start date.',
      );
      return;
    }

    final token = await AuthService.getToken();
    if (token == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Authentication Error',
        text: 'Please log in to submit a booking.',
      );
      return;
    }

    final bookingProvider = context.read<BookingProvider>();

    try {
      final formattedStart = DateFormat('yyyy-MM-dd').format(_startDate!);
      final formattedEnd =
          _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : null;

      final success = await bookingProvider.addBooking(
        spaceId: widget.spaceId,
        username: _nameController.text.trim(),
        contact: _phoneController.text.trim(),
        startDate: formattedStart,
        endDate: formattedEnd,
        purpose: _activitiesController.text.trim(),
        district:
            _locationController.text.isNotEmpty
                ? _locationController.text
                : "Kinondoni",
        file: _selectedFile,
      );

      if (!mounted) return;

      if (success) {
        final pendingCount = bookingProvider.pendingBookingsCount;

        // Check if this booking is offline
        final isOffline = pendingCount > 0;

        QuickAlert.show(
          context: context,
          type: isOffline ? QuickAlertType.info : QuickAlertType.success,
          title: isOffline ? 'Booking Saved Offline' : 'Booking Submitted!',
          text:
              isOffline
                  ? 'You are offline. Your booking has been saved locally and will be submitted automatically when you reconnect.\n\n$pendingCount pending booking(s) waiting to sync.'
                  : 'Your booking has been successfully submitted!\n\nOur team will review your request shortly.',
          confirmBtnText: 'OK',
          onConfirmBtnTap: () {
            Navigator.of(context).pop(); // Close alert
            Navigator.of(context).pop(); // Close booking page
          },
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Booking Error: $e\nStackTrace: $stackTrace');

      if (!mounted) return;

      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Booking Error',
        text: e.toString(),
      );
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppConstants.primaryBlue),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: AppConstants.primaryBlue),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: _buildInputDecoration(label, icon),
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required IconData icon,
    required DateTime? date,
    required VoidCallback onTap,
    bool isRequired = false,
  }) {
    final isSubmitting = context.watch<BookingProvider>().isSubmitting;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isSubmitting ? null : onTap,
        child: InputDecorator(
          decoration: _buildInputDecoration(
            label + (isRequired ? ' *' : ''),
            icon,
          ),
          child: Text(
            date != null ? DateFormat('yyyy-MM-dd').format(date) : 'YYYY-MM-DD',
            style: TextStyle(
              color: date != null ? Colors.black87 : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<BookingProvider>().isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Community Space'),
        centerTitle: true,
        actions: [
          Consumer<BookingProvider>(
            builder: (context, provider, _) {
              final count =
                  provider.pendingBookingsCount; // You must expose this getter
              if (count == 0) return const SizedBox.shrink();

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/pending-bookings');
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

        backgroundColor: AppConstants.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isSubmitting ? null : () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Booking Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryBlue,
                ),
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _nameController,
                label: 'Full Name *',
                icon: Icons.person_outline,
                validator:
                    (v) =>
                        v == null || v.isEmpty
                            ? 'Please enter your name'
                            : null,
              ),
              _buildFormField(
                controller: _phoneController,
                label: 'Phone Number *',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator:
                    (v) =>
                        v == null || v.isEmpty
                            ? 'Please enter phone number'
                            : null,
              ),
              _buildFormField(
                controller: _emailController,
                label: 'Email (Optional)',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    final valid = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(v);
                    if (!valid) return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              _buildFormField(
                controller: _locationController,
                label: 'Space Name / District *',
                icon: Icons.location_on,
                validator:
                    (v) =>
                        v == null || v.isEmpty
                            ? 'Specify location/district'
                            : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDateTimeField(
                      label: 'Start Date *',
                      icon: Icons.calendar_today,
                      date: _startDate,
                      onTap: () => _selectDate(context, true),
                      isRequired: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateTimeField(
                      label: 'End Date',
                      icon: Icons.calendar_today,
                      date: _endDate,
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              _buildFormField(
                controller: _activitiesController,
                label: 'Activities Planned *',
                icon: Icons.description,
                maxLines: 3,
                validator:
                    (v) =>
                        v == null || v.isEmpty
                            ? 'Describe planned activities'
                            : null,
              ),
              const SizedBox(height: 20),

              // File picker
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attachment (Optional)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: isSubmitting ? null : _pickFile,
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Select File'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedFile != null
                                ? _selectedFile!.path
                                    .split(Platform.pathSeparator)
                                    .last
                                : 'No file selected',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  _selectedFile != null
                                      ? Colors.black87
                                      : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isSubmitting ? null : _submitForm,
                child:
                    isSubmitting
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          'Submit Booking Request',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _activitiesController.dispose();
    super.dispose();
  }
}
