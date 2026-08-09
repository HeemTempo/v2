import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/repository/profile_repository.dart';
import '../l10n/app_localizations.dart';
import '../providers/user_provider.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import '../widget/custom_navigation_bar.dart';
import 'bookings.dart';
import 'misc/access_denied_screen.dart';
import 'userreports.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key, this.showBottomNav = true});

  final bool showBottomNav;

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  final int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    if (user.isAnonymous) {
      _isLoading = false;
    } else {
      _fetchProfile();
    }
  }

  Future<void> _fetchProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final profileData = await ProfileRepository.fetchProfile();
      if (!mounted) return;
      setState(() {
        _profile = profileData;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final message = error.toString().replaceFirst('Exception: ', '');
      final isAuthenticationError =
          message.toLowerCase().contains('authentication') ||
          message.toLowerCase().contains('token') ||
          message.toLowerCase().contains('unauthorized');

      if (isAuthenticationError) {
        NotificationService.showError(
          AppLocalizations.of(context)!.sessionExpired,
        );
        await Future<void>.delayed(const Duration(milliseconds: 900));
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      }
    }
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      case 1:
        Navigator.pushNamed(context, '/map');
      case 2:
        break;
      case 3:
        Navigator.pushNamed(context, '/setting');
    }
  }

  String _profileValue(List<String> keys, {required String fallback}) {
    for (final key in keys) {
      final value = _profile?[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return fallback;
  }

  Future<void> _openEditProfile() async {
    await Navigator.pushNamed(context, '/edit-profile');
    if (mounted) await _fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = context.watch<UserProvider>().user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user.isAnonymous) {
      return const AccessDeniedScreen(featureName: 'profile');
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppConstants.darkBackground : AppConstants.pageBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor:
            isDark ? AppConstants.darkBackground : AppConstants.pageBackground,
        foregroundColor: isDark ? Colors.white : AppConstants.navy,
        elevation: 0,
        title: Text(
          loc.profileNavLabel,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton.filledTonal(
              tooltip: loc.fetchProfile,
              onPressed: _isLoading ? null : _fetchProfile,
              icon:
                  _isLoading
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.refresh_rounded, size: 21),
            ),
          ),
        ],
      ),
      body:
          _isLoading && _profile == null
              ? const _ProfileLoadingView()
              : RefreshIndicator(
                onRefresh: _fetchProfile,
                color: AppConstants.primaryGreen,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                  children: [
                    _ProfileHero(
                      name: _profileValue([
                        'username',
                        'name',
                      ], fallback: user.username),
                      email: _profileValue([
                        'email',
                      ], fallback: loc.profileNoData),
                      onEdit: _openEditProfile,
                      usernameLabel: loc.usernameLabel,
                      emailLabel: loc.emailInput,
                      editLabel: loc.editProfileTitle,
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle(
                      icon: Icons.manage_accounts_outlined,
                      title: loc.generalSection,
                    ),
                    const SizedBox(height: 11),
                    _ProfileActionCard(
                      icon: Icons.manage_accounts_rounded,
                      color: AppConstants.primaryGreen,
                      title: loc.profileSettings,
                      subtitle: loc.profileSettingsSubtitle,
                      onTap: _openEditProfile,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 22),
                    _SectionTitle(
                      icon: Icons.auto_graph_rounded,
                      title: loc.activitySection,
                    ),
                    const SizedBox(height: 11),
                    _ProfileActionCard(
                      icon: Icons.campaign_rounded,
                      color: AppConstants.warning,
                      title: loc.myReports,
                      subtitle: loc.myReportsSubtitle,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const UserReportsPage(),
                            ),
                          ),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 11),
                    _ProfileActionCard(
                      icon: Icons.event_available_rounded,
                      color: AppConstants.info,
                      title: loc.myBookings,
                      subtitle: loc.myBookingsSubtitle,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const MyBookingsPage(),
                            ),
                          ),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
      bottomNavigationBar:
          widget.showBottomNav
              ? CustomBottomNavBar(
                currentIndex: _currentIndex,
                onTap: _onNavTap,
              )
              : null,
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.name,
    required this.email,
    required this.onEdit,
    required this.usernameLabel,
    required this.emailLabel,
    required this.editLabel,
  });

  final String name;
  final String email;
  final VoidCallback onEdit;
  final String usernameLabel;
  final String emailLabel;
  final String editLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppConstants.navy;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCard : Colors.white,
        border: Border.all(
          color: isDark ? AppConstants.darkBorder : AppConstants.border,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppConstants.navy.withValues(alpha: isDark ? 0.12 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
            child: Column(
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$usernameLabel: ',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(text: name),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 9),
                Container(
                  constraints: const BoxConstraints(maxWidth: 290),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? AppConstants.darkCardAlt
                            : AppConstants.primaryGreenSoft,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color:
                          isDark
                              ? AppConstants.darkBorder
                              : AppConstants.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.mail_outline_rounded,
                        size: 16,
                        color: AppConstants.primaryGreen,
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '$emailLabel: ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(text: email),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 17),
                SizedBox(
                  width: 172,
                  height: 44,
                  child: FilledButton.icon(
                    onPressed: onEdit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppConstants.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(
                      editLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color:
                isDark
                    ? AppConstants.darkCardAlt
                    : AppConstants.primaryGreenSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppConstants.primaryGreen),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : AppConstants.navy,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _ProfileActionCard extends StatelessWidget {
  const _ProfileActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppConstants.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: isDark ? AppConstants.darkBorder : AppConstants.border,
            ),
            boxShadow:
                isDark
                    ? null
                    : [
                      BoxShadow(
                        color: AppConstants.navy.withValues(alpha: 0.055),
                        blurRadius: 18,
                        offset: const Offset(0, 7),
                      ),
                    ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.20 : 0.11),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppConstants.navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                            isDark
                                ? AppConstants.darkTextSecondary
                                : AppConstants.muted,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : AppConstants.pageBackground,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark ? Colors.white54 : AppConstants.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileLoadingView extends StatelessWidget {
  const _ProfileLoadingView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppConstants.darkCard : Colors.white;
    final shimmer = isDark ? AppConstants.darkCardAlt : AppConstants.border;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
      children: [
        Container(
          height: 174,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 128,
                  height: 15,
                  decoration: BoxDecoration(
                    color: shimmer,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 180,
                  height: 11,
                  decoration: BoxDecoration(
                    color: shimmer.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        for (var index = 0; index < 3; index++) ...[
          Container(
            height: 78,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(19),
              border: Border.all(
                color: isDark ? AppConstants.darkBorder : AppConstants.border,
              ),
            ),
          ),
          const SizedBox(height: 11),
        ],
      ],
    );
  }
}
