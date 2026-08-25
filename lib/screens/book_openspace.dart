import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:kinondoni_openspace_app/providers/booking_provider.dart';
import 'package:kinondoni_openspace_app/providers/user_provider.dart';
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
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();

  // User input fields
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _activitiesController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _userInitialized = false;

  DateTime get _minimumStartDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(const Duration(days: 4));
  }

  @override
  void initState() {
    super.initState();
    if (widget.spaceName != null) {
      _locationController.text = widget.spaceName!;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_userInitialized) return;

    final user = context.read<UserProvider>().user;
    if (!user.isAnonymous) {
      _nameController.text = user.username;
    }
    _userInitialized = true;
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final firstAllowedDate =
        isStart
            ? _minimumStartDate
            : (_startDate ?? _minimumStartDate).add(const Duration(days: 1));
    final selectedDate = isStart ? _startDate : _endDate;
    final initialDate =
        selectedDate != null && !selectedDate.isBefore(firstAllowedDate)
            ? selectedDate
            : firstAllowedDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstAllowedDate,
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && !_endDate!.isAfter(_startDate!)) {
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

    final bookingProvider = context.read<BookingProvider>();

    if (_startDate == null || _endDate == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Validation Error',
        text: 'Select both dates. The end date must be after the start date.',
      );
      return;
    }

    final token = await AuthService.getToken();
    if (!mounted) return;
    if (token == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Authentication Error',
        text: 'Please log in to submit a booking.',
      );
      return;
    }

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
        await _showBookingSuccessDialog();
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

  Future<void> _showBookingSuccessDialog() async {
    final confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Booking submitted',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder:
          (dialogContext, animation, secondaryAnimation) => PopScope(
            canPop: false,
            child: _BookingSuccessDialog(
              onConfirm: () => Navigator.of(dialogContext).pop(true),
            ),
          ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final entrance = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.82, end: 1).animate(entrance),
            child: child,
          ),
        );
      },
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? Colors.white70 : Colors.grey[700],
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.white10 : Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.white10 : Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      filled: true,
      fillColor: isDark ? AppConstants.darkCardAlt : AppConstants.white,
      prefixIcon: Icon(icon, color: primaryColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<BookingProvider>().isSubmitting;
    final primaryColor = AppConstants.primaryGreen;
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
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppConstants.primaryGreen,
                    AppConstants.primaryGreenDark,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(26),
                  bottomRight: Radius.circular(26),
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
                    _buildSectionHeader(
                      Icons.person_outline,
                      loc.yourInfoTitle,
                    ),
                    _buildTextFormField(
                      controller: _nameController,
                      label: loc.fullNameLabel,
                      icon: Icons.person_outline,
                      readOnly: true,
                      validator:
                          (v) =>
                              v == null || v.isEmpty ? loc.fullNameLabel : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextFormField(
                      controller: _phoneController,
                      label: loc.phoneBookingLabel,
                      icon: Icons.phone_android,
                      keyboardType: TextInputType.phone,
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? loc.phoneBookingLabel
                                  : null,
                    ),
                    const SizedBox(height: 24),

                    // Space & Schedule Category
                    _buildSectionHeader(
                      Icons.map_outlined,
                      loc.locationDetailsTitle,
                    ),
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

                    const SizedBox(height: 24),

                    // Details Category
                    _buildSectionHeader(
                      Icons.info_outline,
                      loc.activitiesLabel,
                    ),
                    _buildTextFormField(
                      controller: _activitiesController,
                      label: loc.activitiesLabel,
                      icon: Icons.notes_outlined,
                      maxLines: 4,
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? loc.activitiesLabel
                                  : null,
                    ),

                    const SizedBox(height: 30),

                    // Submit Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: isSubmitting ? null : _submitForm,
                      child:
                          isSubmitting
                              ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                loc.submitBookingButton,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
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
          Icon(icon, size: 20, color: AppConstants.primaryGreen),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryGreen,
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
          color: isDark ? AppConstants.darkCardAlt : AppConstants.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppConstants.darkBorder : AppConstants.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppConstants.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  date != null
                      ? DateFormat('MMM dd, yyyy').format(date)
                      : 'Select date',
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        date != null
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.grey,
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
    _locationController.dispose();
    _activitiesController.dispose();
    super.dispose();
  }
}

class _BookingSuccessDialog extends StatelessWidget {
  const _BookingSuccessDialog({required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: theme.colorScheme.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _AnimatedSuccessTick(),
              const SizedBox(height: 22),
              Text(
                'Booking Submitted!',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your booking has been successfully submitted! Our team will review your request shortly.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onConfirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppConstants.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Great!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedSuccessTick extends StatefulWidget {
  const _AnimatedSuccessTick();

  @override
  State<_AnimatedSuccessTick> createState() => _AnimatedSuccessTickState();
}

class _AnimatedSuccessTickState extends State<_AnimatedSuccessTick>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.62, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Booking successful',
      image: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder:
            (context, child) => Transform.scale(
              scale: 0.72 + (_scale.value * 0.28),
              child: CustomPaint(
                key: const ValueKey('animated-booking-success-tick'),
                size: const Size.square(96),
                painter: _SuccessTickPainter(_controller.value),
              ),
            ),
      ),
    );
  }
}

class _SuccessTickPainter extends CustomPainter {
  const _SuccessTickPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 5;
    final green = AppConstants.primaryGreen;
    final circleProgress = Curves.easeOutCubic.transform(
      (progress / 0.58).clamp(0.0, 1.0),
    );
    final tickProgress = Curves.easeOutCubic.transform(
      ((progress - 0.42) / 0.48).clamp(0.0, 1.0),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = green.withValues(alpha: 0.12),
    );

    final stroke =
        Paint()
          ..color = green
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * circleProgress,
      false,
      stroke,
    );

    final tick =
        Path()
          ..moveTo(size.width * 0.28, size.height * 0.52)
          ..lineTo(size.width * 0.44, size.height * 0.68)
          ..lineTo(size.width * 0.73, size.height * 0.37);
    final metric = tick.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * tickProgress),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _SuccessTickPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
