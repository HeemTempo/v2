import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kinondoni_openspace_app/core/network/connectivity_service.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        // Don't show anything if online
        if (connectivity.isOnline && !connectivity.isReconnecting) {
          return const SizedBox.shrink();
        }

        // Determine status
        Color backgroundColor;
        IconData icon;
        String message;

        if (connectivity.isReconnecting) {
          backgroundColor = Colors.orange;
          icon = Icons.wifi_find;
          message = 'Reconnecting...';
        } else {
          backgroundColor =
              isDark ? Colors.grey[900]! : theme.colorScheme.primary;
          icon = Icons.cloud_off;
          message =
              "Sorry, you can't get any data right now because you're offline.";
        }

        return Container(
          width: double.infinity,
          color: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!connectivity.isReconnecting) ...[
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      connectivity.checkConnectivity();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      minimumSize: const Size(60, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'RETRY',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
