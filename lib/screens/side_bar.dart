import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/connectivity_service.dart';
import '../l10n/app_localizations.dart';
import '../model/user_model.dart';
import '../providers/user_provider.dart';
import '../service/auth_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  Future<void> _handleSignOut(BuildContext context) async {
    final successMessage = AppLocalizations.of(context)!.logoutSuccess;
    await AuthService.logout();
    if (!context.mounted) return;

    context.read<UserProvider>().setUser(User.anonymous());
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('hasSeenOnboarding', false);
    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => NotificationService.showSuccess(successMessage),
    );
  }

  void _openRoute(BuildContext context, String route) {
    Navigator.pop(context);
    Navigator.pushNamed(context, route);
  }

  void _showAboutDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: isDark ? AppConstants.darkCard : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            title: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? AppConstants.darkCardAlt
                            : AppConstants.primaryGreenSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.park_rounded,
                    color: AppConstants.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.appName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        loc.version,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : AppConstants.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    loc.aboutMissionContent,
                    style: const TextStyle(height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  _AboutRow(
                    icon: Icons.business_outlined,
                    label: loc.aboutDeveloper,
                    value: loc.aboutDeveloperValue,
                  ),
                  _AboutRow(
                    icon: Icons.location_city_outlined,
                    label: loc.aboutLocation,
                    value: loc.aboutLocationValue,
                  ),
                  _AboutRow(
                    icon: Icons.email_outlined,
                    label: loc.aboutContact,
                    value: loc.aboutContactValue,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    loc.aboutCopyright,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : AppConstants.muted,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(loc.close),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final connectivity = context.watch<ConnectivityService>();
    final user = context.watch<UserProvider>().user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      width:
          MediaQuery.sizeOf(context).width < 410
              ? MediaQuery.sizeOf(context).width * 0.88
              : 360,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      backgroundColor:
          isDark ? AppConstants.darkBackground : AppConstants.pageBackground,
      child: Column(
        children: [
          _SidebarHeader(
            userName: user.isAnonymous ? loc.anonymousUser : user.username,
            isAnonymous: user.isAnonymous,
            isOnline: connectivity.isOnline,
            onlineLabel: loc.onlineMode,
            offlineLabel: loc.offlineMode,
            appName: loc.appName,
            closeLabel: loc.close,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
              children: [
                _MenuTile(
                  icon: Icons.help_outline_rounded,
                  title: loc.helpFaqs,
                  onTap: () => _openRoute(context, '/help-support'),
                ),
                _MenuTile(
                  icon: Icons.description_outlined,
                  title: loc.termsConditions,
                  onTap: () => _openRoute(context, '/terms'),
                ),
                _MenuTile(
                  icon: Icons.info_outline_rounded,
                  title: loc.about,
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              decoration: BoxDecoration(
                color:
                    isDark
                        ? AppConstants.darkCard
                        : AppConstants.pageBackground,
                border: Border(
                  top: BorderSide(
                    color:
                        isDark ? AppConstants.darkBorder : AppConstants.border,
                  ),
                ),
              ),
              child: Column(
                children: [
                  _FooterButton(
                    icon: Icons.tune_rounded,
                    label: loc.settings,
                    color: isDark ? Colors.white70 : AppConstants.navy,
                    onTap: () => _openRoute(context, '/setting'),
                  ),
                  const SizedBox(height: 10),
                  if (user.isAnonymous)
                    _FooterButton(
                      icon: Icons.login_rounded,
                      label: loc.signInButton,
                      color: AppConstants.primaryGreen,
                      filled: true,
                      onTap: () => _openRoute(context, '/login'),
                    )
                  else
                    _FooterButton(
                      icon: Icons.logout_rounded,
                      label: loc.signOut,
                      color: AppConstants.danger,
                      filled: true,
                      onTap: () => _handleSignOut(context),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({
    required this.userName,
    required this.isAnonymous,
    required this.isOnline,
    required this.onlineLabel,
    required this.offlineLabel,
    required this.appName,
    required this.closeLabel,
  });

  final String userName;
  final bool isAnonymous;
  final bool isOnline;
  final String onlineLabel;
  final String offlineLabel;
  final String appName;
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.viewPaddingOf(context).top + 14,
            20,
            24,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppConstants.primaryGreen,
                AppConstants.primaryGreenDark,
                AppConstants.navy,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.park_rounded,
                      size: 26,
                      color: AppConstants.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      appName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: closeLabel,
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.close_rounded, size: 21),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.32),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isAnonymous
                          ? Icons.person_outline_rounded
                          : Icons.person_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color:
                                      isOnline
                                          ? AppConstants.accentMint
                                          : AppConstants.warning,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isOnline ? onlineLabel : offlineLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: -44,
          right: -38,
          child: IgnorePointer(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isDark ? AppConstants.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppConstants.darkBorder : AppConstants.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? AppConstants.darkCardAlt
                            : AppConstants.primaryGreenSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppConstants.primaryGreen, size: 21),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark ? Colors.white38 : AppConstants.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterButton extends StatelessWidget {
  const _FooterButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = filled ? Colors.white : color;

    return Material(
      color:
          filled
              ? color
              : isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  filled
                      ? color
                      : isDark
                      ? AppConstants.darkBorder
                      : AppConstants.border,
            ),
            boxShadow:
                filled
                    ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: foreground),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppConstants.primaryGreen),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : AppConstants.muted,
                  ),
                ),
                Text(value, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
