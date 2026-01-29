import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:kinondoni_openspace_app/providers/booking_provider.dart';
import 'package:kinondoni_openspace_app/service/auth_service.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:kinondoni_openspace_app/utils/constants.dart';
import 'package:kinondoni_openspace_app/l10n/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.spaceName != null) {
      _locationController.text = widget.spaceName!;
    }
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
        file: null, // Removed attachment support
      );

      if (!mounted) return;

      if (success) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Booking Submitted!',
          text: 'Your booking has been successfully submitted! Our team will review your request shortly.',
          confirmBtnText: 'Great!',
          onConfirmBtnTap: () {
            Navigator.of(context).pop(); // Close alert
            Navigator.of(context).pop(); // Close booking page
          },
        );
      }
    } catch (e) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700], fontWeight: FontWeight.w500),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[50],
      prefixIcon: Icon(icon, color: primaryColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<BookingProvider>().isSubmitting;
    final primaryColor = AppConstants.primaryBlue;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.bookSpace),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Top branding/welcome section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.bookingHeader,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete the form below to reserve this open space.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Personal Information Category
                    _buildSectionHeader(Icons.person_outline, loc.yourInfoTitle),
                    _buildTextFormField(
                      controller: _nameController,
                      label: loc.fullNameLabel,
                      icon: Icons.person_outline,
                      validator: (v) => v == null || v.isEmpty ? loc.fullNameLabel : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextFormField(
                      controller: _phoneController,
                      label: loc.phoneBookingLabel,
                      icon: Icons.phone_android,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v == null || v.isEmpty ? loc.phoneBookingLabel : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextFormField(
                      controller: _emailController,
                      label: loc.emailBookingLabel,
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Space & Schedule Category
                    _buildSectionHeader(Icons.map_outlined, loc.locationDetailsTitle),
                    _buildTextFormField(
                      controller: _locationController,
                      label: loc.spaceDistrictLabel,
                      icon: Icons.location_on_outlined,
                      readOnly: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDatePickerField(
                            label: loc.startDateLabel,
                            date: _startDate,
                            onTap: () => _selectDate(context, true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDatePickerField(
                            label: loc.endDateLabel,
                            date: _endDate,
                            onTap: () => _selectDate(context, false),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Details Category
                    _buildSectionHeader(Icons.info_outline, loc.activitiesLabel),
                    _buildTextFormField(
                      controller: _activitiesController,
                      label: loc.activitiesLabel,
                      icon: Icons.notes_outlined,
                      maxLines: 4,
                      validator: (v) => v == null || v.isEmpty ? loc.activitiesLabel : null,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Submit Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: isSubmitting ? null : _submitForm,
                      child: isSubmitting
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              loc.submitBookingButton,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppConstants.primaryBlue),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _buildInputDecoration(label, icon),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      readOnly: readOnly,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppConstants.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  date != null ? DateFormat('MMM dd, yyyy').format(date) : 'Select date',
                  style: TextStyle(
                    fontSize: 14,
                    color: date != null ? Theme.of(context).colorScheme.onSurface : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
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
