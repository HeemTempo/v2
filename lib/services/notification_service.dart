import 'package:flutter/material.dart';

import '../utils/constants.dart';

class NotificationService {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSuccess(
    String message, {
    Duration duration = const Duration(milliseconds: 2400),
  }) => _show(
    message,
    icon: Icons.check_rounded,
    accent: AppConstants.primaryGreen,
    duration: duration,
  );

  static void showError(
    String message, {
    Duration duration = const Duration(milliseconds: 3200),
  }) => _show(
    message,
    icon: Icons.priority_high_rounded,
    accent: AppConstants.danger,
    duration: duration,
  );

  static void showInfo(
    String message, {
    Duration duration = const Duration(milliseconds: 2200),
  }) => _show(
    message,
    icon: Icons.info_outline_rounded,
    accent: AppConstants.info,
    duration: duration,
  );

  static void showWarning(
    String message, {
    Duration duration = const Duration(milliseconds: 2800),
  }) => _show(
    message,
    icon: Icons.warning_amber_rounded,
    accent: AppConstants.warning,
    duration: duration,
  );

  static void _show(
    String message, {
    required IconData icon,
    required Color accent,
    required Duration duration,
  }) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null || message.trim().isEmpty) return;

    final context = messenger.context;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // A new toast replaces the old one immediately so messages never queue.
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 18),
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
        duration: duration,
        content: _ModernToast(
          message: message,
          icon: icon,
          accent: accent,
          isDark: isDark,
          onClose: messenger.hideCurrentSnackBar,
        ),
      ),
    );
  }
}

class _ModernToast extends StatelessWidget {
  const _ModernToast({
    required this.message,
    required this.icon,
    required this.accent,
    required this.isDark,
    required this.onClose,
  });

  final String message;
  final IconData icon;
  final Color accent;
  final bool isDark;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppConstants.darkCardAlt : Colors.white;
    final foreground = isDark ? AppConstants.darkText : AppConstants.navy;

    return Container(
      constraints: const BoxConstraints(minHeight: 66),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppConstants.darkBorder : AppConstants.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.13),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Row(
          children: [
            Container(
              width: 5,
              constraints: const BoxConstraints(minHeight: 66),
              color: accent,
            ),
            const SizedBox(width: 13),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.22 : 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              onPressed: onClose,
              visualDensity: VisualDensity.compact,
              color: isDark ? Colors.white54 : AppConstants.muted,
              icon: const Icon(Icons.close_rounded, size: 19),
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}
