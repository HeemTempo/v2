import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback submitReport; // Changed from onSubmit to submitReport to match your usage
  final VoidCallback? onCancel; // Optional: To make cancel button more flexible if needed elsewhere

  const ActionButtons({
    super.key,
    required this.isSubmitting,
    required this.submitReport,
    this.onCancel, // Make onCancel optional
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: OutlinedButton(
            // Use the passed onCancel callback if available, otherwise default to Navigator.pop
            onPressed: isSubmitting ? null : (onCancel ?? () => Navigator.pop(context)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12), // Added padding for better tap target
            ),
            child: const Text("Cancel"),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: isSubmitting ? null : submitReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // This is the "Report" button color from your previous context
              padding: const EdgeInsets.symmetric(vertical: 12), // Added padding
            ),
            child: isSubmitting
                ? const SizedBox(
              height: 24, // Matched height with text for better alignment
              width: 24,  // Matched width
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
                : const Text("Report"), // Changed text to "Report"
          ),
        ),
      ],
    );
  }
}