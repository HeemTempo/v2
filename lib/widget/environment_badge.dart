import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kinondoni_openspace_app/config/app_config.dart';

class EnvironmentBadge extends StatelessWidget {
  const EnvironmentBadge({super.key});

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!kDebugMode) return const SizedBox.shrink();

    final isDev = AppConfig.isDevelopment;
    
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDev ? Colors.orange : Colors.green,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDev ? Icons.code : Icons.rocket_launch,
              size: 12,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              isDev ? 'DEV' : 'PROD',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
