import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../utils/constants.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;
    final surface = isDark ? AppConstants.darkCard : Colors.white;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppConstants.darkBorder : AppConstants.border,
          ),
          boxShadow: [
            BoxShadow(
              color: AppConstants.navy.withValues(alpha: isDark ? 0.30 : 0.13),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return TextStyle(
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color:
                      selected
                          ? AppConstants.primaryGreen
                          : isDark
                          ? Colors.white60
                          : AppConstants.muted,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return IconThemeData(
                  size: selected ? 25 : 23,
                  color:
                      selected
                          ? AppConstants.primaryGreen
                          : isDark
                          ? Colors.white60
                          : AppConstants.muted,
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: currentIndex.clamp(0, 3),
              onDestinationSelected: onTap,
              height: 66,
              elevation: 0,
              backgroundColor: surface,
              indicatorColor:
                  isDark
                      ? AppConstants.darkCardAlt
                      : AppConstants.primaryGreenSoft,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home_rounded),
                  label: loc.homeNavLabel,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.park_outlined),
                  selectedIcon: const Icon(Icons.park_rounded),
                  label: loc.openSpaces,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.account_circle_outlined),
                  selectedIcon: const Icon(Icons.account_circle_rounded),
                  label: loc.profileNavLabel,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.tune_outlined),
                  selectedIcon: const Icon(Icons.tune_rounded),
                  label: loc.settings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
