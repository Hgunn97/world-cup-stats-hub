import 'package:flutter/material.dart';
import '../models/team_stats_model.dart';
import '../services/api_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final _api = ApiService();

  late Future<List<TeamStats>> _topScoring;
  late Future<List<TeamStats>> _mostConceded;
  late Future<List<TeamStats>> _bestGD;
  late Future<List<TeamStats>> _cleanSheets;
  late Future<List<HighScoringMatch>> _highestScoring;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _topScoring = _api.getTopScoringTeams(limit: 8);
      _mostConceded = _api.getMostConcededTeams(limit: 8);
      _bestGD = _api.getBestGoalDifferenceTeams(limit: 8);
      _cleanSheets = _api.getCleanSheetTeams(limit: 8);
      _highestScoring = _api.getHighestScoringMatches(limit: 8);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TeamStatSection(
                title: 'Top Scoring Teams',
                icon: Icons.sports_soccer,
                accentColor: const Color(0xFFDC2626),
                future: _topScoring,
                statLabel: 'Goals',
                statValue: (s) => s.goalsScored,
                subValue: (s) => '${s.matchesPlayed} played · ${s.goalsPerMatch.toStringAsFixed(1)}/game',
              ),
              _TeamStatSection(
                title: 'Best Goal Difference',
                icon: Icons.trending_up,
                accentColor: const Color(0xFF2E7D32),
                future: _bestGD,
                statLabel: 'GD',
                statValue: (s) => s.goalDifference,
                statDisplay: (s) => s.goalDifference >= 0 ? '+${s.goalDifference}' : '${s.goalDifference}',
                subValue: (s) => 'GF ${s.goalsScored}  ·  GA ${s.goalsConceded}',
              ),
              _TeamStatSection(
                title: 'Most Goals Conceded',
                icon: Icons.shield_outlined,
                accentColor: const Color(0xFF0288D1),
                future: _mostConceded,
                statLabel: 'Conceded',
                statValue: (s) => s.goalsConceded,
                subValue: (s) => '${s.matchesPlayed} played',
              ),
              _TeamStatSection(
                title: 'Clean Sheets',
                icon: Icons.lock_outline,
                accentColor: const Color(0xFF6A1B9A),
                future: _cleanSheets,
                statLabel: 'CS',
                statValue: (s) => s.cleanSheets,
                subValue: (s) => '${s.matchesPlayed} played',
              ),
              _HighScoringSection(future: _highestScoring),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Team stat leaderboard section ─────────────────────────────────────────────

class _TeamStatSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final Future<List<TeamStats>> future;
  final String statLabel;
  final int Function(TeamStats) statValue;
  final String Function(TeamStats)? statDisplay;
  final String Function(TeamStats) subValue;

  const _TeamStatSection({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.future,
    required this.statLabel,
    required this.statValue,
    this.statDisplay,
    required this.subValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: title, icon: icon, accentColor: accentColor),
            const SizedBox(height: 4),
            FutureBuilder<List<TeamStats>>(
              future: future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                if (snap.hasError || snap.data == null) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('Failed to load',
                        style: TextStyle(color: theme.colorScheme.error)),
                  );
                }
                final items = snap.data!;
                if (items.isEmpty) {
                  return _EmptyState(label: statLabel);
                }

                final maxVal = items
                    .map(statValue)
                    .fold(1, (a, b) => a > b ? a : b);

                return Column(
                  children: [
                    // Header row
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(children: [
                        const SizedBox(width: 36),
                        Expanded(
                          child: Text('Team',
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withAlpha(130))),
                        ),
                        SizedBox(
                          width: 52,
                          child: Text(statLabel,
                              textAlign: TextAlign.right,
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withAlpha(130))),
                        ),
                      ]),
                    ),
                    const Divider(height: 1),
                    for (int i = 0; i < items.length; i++) ...[
                      _LeaderboardRow(
                        rank: i + 1,
                        teamName: items[i].teamName,
                        group: items[i].groupCode,
                        statDisplay: statDisplay != null
                            ? statDisplay!(items[i])
                            : '${statValue(items[i])}',
                        subText: subValue(items[i]),
                        barFraction: maxVal == 0 ? 0 : statValue(items[i]) / maxVal,
                        accentColor: accentColor,
                      ),
                      if (i < items.length - 1) const Divider(height: 1, indent: 36),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Leaderboard row ───────────────────────────────────────────────────────────

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final String teamName;
  final String? group;
  final String statDisplay;
  final String subText;
  final double barFraction;
  final Color accentColor;

  const _LeaderboardRow({
    required this.rank,
    required this.teamName,
    this.group,
    required this.statDisplay,
    required this.subText,
    required this.barFraction,
    required this.accentColor,
  });

  static const _gold = Color(0xFFFFB300);
  static const _silver = Color(0xFF90A4AE);
  static const _bronze = Color(0xFF8D6E63);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTop3 = rank <= 3;

    final medalColor = switch (rank) {
      1 => _gold,
      2 => _silver,
      3 => _bronze,
      _ => null,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Rank badge
          SizedBox(
            width: 28,
            height: 28,
            child: medalColor != null
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      color: medalColor.withAlpha(30),
                      shape: BoxShape.circle,
                      border: Border.all(color: medalColor.withAlpha(120)),
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: medalColor,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      '$rank',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(120),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          // Team name + sub text + bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        teamName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              isTop3 ? FontWeight.bold : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (group != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          group!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: barFraction.clamp(0.0, 1.0),
                    minHeight: 3,
                    backgroundColor:
                        theme.colorScheme.onSurface.withAlpha(15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      rank == 1
                          ? accentColor
                          : accentColor.withAlpha(rank == 2 ? 180 : rank == 3 ? 140 : 90),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(120),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Stat value
          SizedBox(
            width: 44,
            child: Text(
              statDisplay,
              textAlign: TextAlign.right,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: rank == 1 ? accentColor : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Highest scoring matches section ──────────────────────────────────────────

class _HighScoringSection extends StatelessWidget {
  final Future<List<HighScoringMatch>> future;
  const _HighScoringSection({required this.future});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const accent = Color(0xFFDC2626);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              title: 'Highest Scoring Matches',
              icon: Icons.local_fire_department,
              accentColor: accent,
            ),
            const SizedBox(height: 4),
            FutureBuilder<List<HighScoringMatch>>(
              future: future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                if (snap.hasError || snap.data == null) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('Failed to load',
                        style: TextStyle(color: theme.colorScheme.error)),
                  );
                }
                final items = snap.data!;
                if (items.isEmpty) {
                  return const _EmptyState(label: 'matches');
                }

                return Column(
                  children: [
                    const Divider(height: 8),
                    for (int i = 0; i < items.length; i++) ...[
                      _HighScoringRow(match: items[i]),
                      if (i < items.length - 1) const Divider(height: 1, indent: 36),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HighScoringRow extends StatelessWidget {
  final HighScoringMatch match;
  const _HighScoringRow({required this.match});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final goalColor = switch (match.totalGoals) {
      >= 7 => const Color(0xFFDC2626),
      >= 5 => const Color(0xFFD97706),
      _ => const Color(0xFF2E7D32),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 28,
            child: Text(
              '${match.rank}.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(120),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          // Teams + score
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    match.homeTeamName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: match.homeScore > match.awayScore
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '${match.homeScore}  –  ${match.awayScore}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    match.awayTeamName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: match.awayScore > match.homeScore
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Goals badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: goalColor.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: goalColor.withAlpha(80)),
            ),
            child: Text(
              '${match.totalGoals}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: goalColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: accentColor.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: accentColor),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String label;
  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          'No $label data yet',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
              ),
        ),
      ),
    );
  }
}
