import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/tournament_summary_model.dart';
import '../models/match_model.dart';
import '../services/api_service.dart';
import '../utils/time_utils.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import '../widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = _loadData();
    });
  }

  Future<_HomeData> _loadData() async {
    final results = await Future.wait([
      _api.getTournamentSummary(),
      _api.getMatches(),
    ]);
    final summary = results[0] as TournamentSummary;
    final allMatches = results[1] as List<Match>;

    final upcoming = allMatches
        .where((m) => m.isScheduled)
        .toList()
      ..sort((a, b) => a.kickOffUtc.compareTo(b.kickOffUtc));

    return _HomeData(summary: summary, upcoming: upcoming.take(5).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('World Cup 2026'),
        centerTitle: false,
      ),
      body: FutureBuilder<_HomeData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: 'Could not load dashboard.\n${snapshot.error}',
              onRetry: _load,
            );
          }
          final data = snapshot.data!;
          final s = data.summary;
          return RefreshIndicator(
            onRefresh: () async => _load(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Upcoming matches ──────────────────────────────────────
                  if (data.upcoming.isNotEmpty) ...[
                    _sectionTitle(context, 'Upcoming Matches'),
                    const SizedBox(height: 8),
                    _UpcomingMatchesCard(matches: data.upcoming),
                    const SizedBox(height: 20),
                  ],

                  // ── Tournament progress ───────────────────────────────────
                  _sectionTitle(context, 'Tournament Progress'),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: StatCard(
                        label: 'Matches Played',
                        value: '${s.matchesPlayed}',
                        subtitle: 'of ${s.totalMatches}',
                        icon: Icons.sports_soccer,
                        accentColor: const Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatCard(
                        label: 'Remaining',
                        value: '${s.matchesRemaining}',
                        icon: Icons.schedule,
                        accentColor: const Color(0xFF0288D1),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: StatCard(
                        label: 'Total Goals',
                        value: '${s.totalGoals}',
                        icon: Icons.sports_soccer_outlined,
                        accentColor: const Color(0xFFDC2626),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatCard(
                        label: 'Goals/Match',
                        value: s.goalsPerMatch.toStringAsFixed(2),
                        icon: Icons.bar_chart,
                        accentColor: const Color(0xFFD97706),
                      ),
                    ),
                  ]),

                  // ── Highlights ────────────────────────────────────────────
                  if (s.matchesPlayed > 0) ...[
                    const SizedBox(height: 20),
                    _sectionTitle(context, 'Highlights'),
                    const SizedBox(height: 8),
                    if (s.topScoringTeam != null)
                      StatCard(
                        label: 'Top Scoring Team',
                        value: s.topScoringTeam!.teamName,
                        subtitle: '${s.topScoringTeam!.value} goals',
                        icon: Icons.emoji_events,
                        accentColor: const Color(0xFFD97706),
                      ),
                    const SizedBox(height: 8),
                    if (s.mostConcededTeam != null)
                      StatCard(
                        label: 'Most Conceded',
                        value: s.mostConcededTeam!.teamName,
                        subtitle: '${s.mostConcededTeam!.value} goals conceded',
                        icon: Icons.shield_outlined,
                        accentColor: const Color(0xFF0288D1),
                      ),
                    const SizedBox(height: 8),
                    if (s.bestGoalDifferenceTeam != null)
                      StatCard(
                        label: 'Best Goal Difference',
                        value: s.bestGoalDifferenceTeam!.teamName,
                        subtitle: s.bestGoalDifferenceTeam!.value >= 0
                            ? '+${s.bestGoalDifferenceTeam!.value}'
                            : '${s.bestGoalDifferenceTeam!.value}',
                        icon: Icons.trending_up,
                        accentColor: const Color(0xFF2E7D32),
                      ),
                    const SizedBox(height: 8),
                    if (s.mostCleanSheetsTeam != null)
                      StatCard(
                        label: 'Most Clean Sheets',
                        value: s.mostCleanSheetsTeam!.teamName,
                        subtitle: '${s.mostCleanSheetsTeam!.value} clean sheets',
                        icon: Icons.lock_outline,
                        accentColor: const Color(0xFF6A1B9A),
                      ),
                    const SizedBox(height: 8),
                    if (s.highestScoringMatch != null)
                      StatCard(
                        label: 'Highest Scoring Match',
                        value:
                            '${s.highestScoringMatch!.homeTeamName} ${s.highestScoringMatch!.homeScore} – ${s.highestScoringMatch!.awayScore} ${s.highestScoringMatch!.awayTeamName}',
                        subtitle: '${s.highestScoringMatch!.totalGoals} goals',
                        icon: Icons.local_fire_department,
                        accentColor: const Color(0xFFDC2626),
                      ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Tournament stats will appear once matches are played.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withAlpha(140)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) => Text(text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.bold));
}

// ── Upcoming matches card ─────────────────────────────────────────────────────

class _UpcomingMatchesCard extends StatelessWidget {
  final List<Match> matches;
  const _UpcomingMatchesCard({required this.matches});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (int i = 0; i < matches.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 12, endIndent: 12),
            _UpcomingMatchTile(match: matches[i]),
          ],
          if (matches.length == 5)
            TextButton(
              onPressed: () => context.go('/matches'),
              child: const Text('View all matches'),
            ),
        ],
      ),
    );
  }
}

class _UpcomingMatchTile extends StatelessWidget {
  final Match match;
  const _UpcomingMatchTile({required this.match});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ukTime = toUkTime(match.kickOffUtc);
    final dateStr = DateFormat('EEE d MMM').format(ukTime);
    final timeStr = '${DateFormat('HH:mm').format(ukTime)} BST';

    return InkWell(
      onTap: () => context.push('/matches/${match.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Date/time column
            SizedBox(
              width: 72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateStr,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(140),
                      )),
                  Text(timeStr,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      )),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Teams
            Expanded(
              child: Text(
                '${match.homeDisplay} vs ${match.awayDisplay}',
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Group badge
            if (match.groupCode != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Grp ${match.groupCode}',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Data holder ───────────────────────────────────────────────────────────────

class _HomeData {
  final TournamentSummary summary;
  final List<Match> upcoming;

  _HomeData({required this.summary, required this.upcoming});
}
