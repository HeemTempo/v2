import 'package:flutter/material.dart';

class NotificationService {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = 
      GlobalKey<ScaffoldMessengerState>();

  static void showSuccess(String message, {Duration duration = const Duration(seconds: 4)}) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static void showError(String message, {Duration duration = const Duration(seconds: 5)}) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'SAWA',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  static void showInfo(String message, {Duration duration = const Duration(seconds: 3)}) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static void showSyncSuccess(int reportCount, int bookingCount, List<String> reportIds) {
    final buffer = StringBuffer();
    
    if (reportCount > 0) {
      buffer.write('✓ Ripoti $reportCount zimewekwa');
      if (reportIds.isNotEmpty) {
        buffer.write('\\n');
        for (var id in reportIds.take(3)) {
          buffer.write('  • Nambari: $id\\n');
        }
        if (reportIds.length > 3) {
          buffer.write('  ... na ${reportIds.length - 3} zaidi');
        }
      }
    }
    
    if (bookingCount > 0) {
      if (buffer.isNotEmpty) buffer.write('\\n');
      buffer.write('✓ Miadi $bookingCount imewekwa');
    }

    if (buffer.isNotEmpty) {
      showSuccess(
        'Mafanikio! \\n$buffer',
        duration: const Duration(seconds: 6),
      );
    }
  }
}

// Friendly error messages for Tanzania
class ErrorMessages {
  static String getNetworkError() {
    return 'Hakuna mtandao. Tafadhali angalia muunganisho wako wa intaneti.';
  }

  static String getServerError() {
    return 'Tatizo la seva. Tafadhali jaribu tena baadaye.';
  }

  static String getTimeoutError() {
    return 'Muda umeisha. Mtandao unakuwa polepole, jaribu tena.';
  }

  static String getValidationError(String field) {
    return 'Tafadhali jaza $field kwa usahihi.';
  }

  static String getAuthError() {
    return 'Tafadhali ingia tena katika akaunti yako.';
  }

  static String getGenericError() {
    return 'Kuna tatizo. Tafadhali jaribu tena.';
  }

  static String getOfflineSaved() {
    return 'Mtandao haupo. Takwimu zimehifadhiwa na zitatumwa mara mtandao utakaporejesha.';
  }
}
