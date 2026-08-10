import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/local/report_local.dart';
import '../data/repository/booking_repository.dart';
import '../data/repository/report_repository.dart';
import '../l10n/app_localizations.dart';
import '../providers/user_provider.dart';
import '../service/openspace_service.dart';
import '../utils/constants.dart';
import 'map_screen.dart';
import 'side_bar.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key, required this.onOpenMap});

  final ValueChanged<MapLaunchIntent> onOpenMap;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int _openSpacesCount = 0;
  int _activeReportsCount = 0;
  int _bookingsCount = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchQuickStats());
  }

  Future<void> _fetchQuickStats() async {
    if (!mounted) return;
    setState(() => _isLoadingStats = true);

    final user = context.read<UserProvider>().user;
    var openSpaces = 0;
    var reports = 0;
    var bookings = 0;

    try {
      try {
        openSpaces = await OpenSpaceService().getOpenSpaceCount().timeout(
          const Duration(seconds: 10),
        );
      } catch (error) {
        debugPrint('Unable to load open-space count: $error');
      }

      if (!user.isAnonymous) {
        try {
          final allReports =
              await ReportRepository(
                localService: ReportLocal(),
              ).getAllReports();
          reports =
              allReports
                  .where(
                    (report) =>
                        report.status?.toLowerCase() == 'pending' ||
                        report.status?.toLowerCase() == 'in_progress',
                  )
                  .length;
        } catch (error) {
          debugPrint('Unable to load report count: $error');
        }

        try {
          bookings = (await BookingRepository().getMyBookings()).length;
        } catch (error) {
          debugPrint('Unable to load booking count: $error');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _openSpacesCount = openSpaces;
          _activeReportsCount = reports;
          _bookingsCount = bookings;
          _isLoadingStats = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor:
          isDark ? AppConstants.darkBackground : AppConstants.pageBackground,
      drawer: const Sidebar(),
      appBar: AppBar(
        backgroundColor:
            isDark ? AppConstants.darkBackground : AppConstants.pageBackground,
        foregroundColor: isDark ? Colors.white : AppConstants.navy,
        elevation: 0,
        leading: Builder(
          builder:
              (context) => IconButton(
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu_rounded),
              ),
        ),
        titleSpacing: 4,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.appName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            if (!user.isAnonymous)
              Text(
                user.username,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white60 : AppConstants.muted,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: loc.emergencyContacts,
            onPressed: () => _showEmergencyDialog(loc, isDark),
            icon: const Icon(Icons.phone_in_talk_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchQuickStats,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
          children: [
            _buildHero(loc),
            const SizedBox(height: 24),
            _SectionHeading(title: loc.quickActions),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.report_outlined,
              title: loc.reportIssue,
              subtitle: loc.reportIssueSubtitle,
              color: AppConstants.danger,
              onTap: () => widget.onOpenMap(MapLaunchIntent.report),
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.calendar_month_outlined,
              title: loc.bookSpace,
              subtitle: loc.bookSpaceSubtitle,
              color: AppConstants.primaryGreen,
              onTap: () => widget.onOpenMap(MapLaunchIntent.booking),
            ),
            const SizedBox(height: 24),
            _SectionHeading(title: loc.quickStats),
            const SizedBox(height: 12),
            _buildStats(loc, isDark, user.isAnonymous),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(AppLocalizations loc) {
    return SizedBox(
      height: 188,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/kinondoni-home-hero-v2.jpg',
              fit: BoxFit.cover,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x16071F27), Color(0xE607543F)],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      loc.openSpaces,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    loc.heroTitle1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    loc.heroSubtitle1,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(AppLocalizations loc, bool isDark, bool isAnonymous) {
    if (_isLoadingStats) {
      return Row(
        children: [
          Expanded(
            child: _StatItem(
              value: '',
              label: loc.openSpaces,
              icon: Icons.park_rounded,
              accent: AppConstants.primaryGreen,
              isDark: isDark,
              isLoading: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatItem(
              value: '',
              label: loc.activeReports,
              icon: Icons.campaign_rounded,
              accent: AppConstants.warning,
              isDark: isDark,
              isLoading: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatItem(
              value: '',
              label: loc.bookings,
              icon: Icons.event_available_rounded,
              accent: AppConstants.info,
              isDark: isDark,
              isLoading: true,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _StatItem(
            value: '$_openSpacesCount',
            label: loc.openSpaces,
            icon: Icons.park_rounded,
            accent: AppConstants.primaryGreen,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatItem(
            value: isAnonymous ? '—' : '$_activeReportsCount',
            label: loc.activeReports,
            icon: Icons.campaign_rounded,
            accent: AppConstants.warning,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatItem(
            value: isAnonymous ? '—' : '$_bookingsCount',
            label: loc.bookings,
            icon: Icons.event_available_rounded,
            accent: AppConstants.info,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  void _showEmergencyDialog(AppLocalizations loc, bool isDark) {
    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: isDark ? AppConstants.darkCard : Colors.white,
            title: Text(loc.emergencyContacts),
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _EmergencyContact(title: loc.police, number: '112'),
                _EmergencyContact(title: loc.fire, number: '114'),
                _EmergencyContact(title: loc.ambulance, number: '115'),
              ],
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
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppConstants.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppConstants.darkBorder : AppConstants.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 25),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
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
                        height: 1.35,
                        fontSize: 12,
                        color: isDark ? Colors.white60 : AppConstants.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDark ? Colors.white38 : AppConstants.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.accent,
    required this.isDark,
    this.isLoading = false,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color accent;
  final bool isDark;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 126,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? AppConstants.darkCardAlt : Colors.white,
            accent.withValues(alpha: isDark ? 0.12 : 0.07),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isDark ? AppConstants.darkBorder : accent.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.08 : 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -24,
            right: -22,
            child: IgnorePointer(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.08 : 0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: isDark ? 0.20 : 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: accent),
                ),
                const Spacer(),
                if (isLoading)
                  SizedBox(
                    width: 34,
                    child: LinearProgressIndicator(
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(99),
                      color: accent,
                      backgroundColor: accent.withValues(alpha: 0.12),
                    ),
                  )
                else
                  Text(
                    value,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppConstants.navy,
                      fontSize: 24,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    height: 1.15,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : AppConstants.muted,
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

class _EmergencyContact extends StatelessWidget {
  const _EmergencyContact({required this.title, required this.number});

  final String title;
  final String number;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppConstants.danger.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(13),
        ),
        child: const Icon(
          Icons.phone_outlined,
          color: AppConstants.danger,
          size: 21,
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(number),
      trailing: const Icon(
        Icons.call_rounded,
        color: AppConstants.primaryGreen,
      ),
      onTap: () async {
        final uri = Uri(scheme: 'tel', path: number);
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      },
    );
  }
}
