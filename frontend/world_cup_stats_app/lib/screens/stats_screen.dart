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
              _StatSection<TeamStats>(
                title: 'Top Scoring Teams',
                icon: Icons.sports_soccer,
                future: _topScoring,
                headerColumns: const ['#', 'Team', 'Grp', 'Goals', 'MP', 'G/M'],
                rowBuilder: (s, i) => [
                  '${i + 1}',
                  s.teamName,
                  s.groupCode ?? '-',
                  '${s.goalsScored}',
                  '${s.matchesPlayed}',
                  s.goalsPerMatch.toStringAsFixed(2),
                ],
              ),
              _StatSection<TeamStats>(
                title: 'Most Goals Conceded',
                icon: Icons.shield_outlined,
                future: _mostConceded,
                headerColumns: const ['#', 'Team', 'Grp', 'Conceded', 'MP'],
                rowBuilder: (s, i) => [
                  '${i + 1}',
                  s.teamName,
                  s.groupCode ?? '-',
                  '${s.goalsConceded}',
                  '${s.matchesPlayed}',
                ],
              ),
              _StatSection<TeamStats>(
                title: 'Best Goal Difference',
                icon: Icons.trending_up,
                future: _bestGD,
                headerColumns: const ['#', 'Team', 'Grp', 'GD', 'GF', 'GA'],
                rowBuilder: (s, i) => [
                  '${i + 1}',
                  s.teamName,
                  s.groupCode ?? '-',
                  s.goalDifference >= 0 ? '+${s.goalDifference}' : '${s.goalDifference}',
                  '${s.goalsScored}',
                  '${s.goalsConceded}',
                ],
              ),
              _StatSection<TeamStats>(
                title: 'Clean Sheets',
                icon: Icons.lock_outline,
                future: _cleanSheets,
                headerColumns: const ['#', 'Team', 'Grp', 'CS', 'MP'],
                rowBuilder: (s, i) => [
                  '${i + 1}',
                  s.teamName,
                  s.groupCode ?? '-',
                  '${s.cleanSheets}',
                  '${s.matchesPlayed}',
                ],
              ),
              _HighScoringSection(future: _highestScoring),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatSection<T> extends StatelessWidget {
  final String title;
  final IconData icon;
  final Future<List<T>> future;
  final List<String> headerColumns;
  final List<String> Function(T item, int index) rowBuilder;

  const _StatSection({
    required this.title,
    required this.icon,
    required this.future,
    required this.headerColumns,
    required this.rowBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 8),
            FutureBuilder<List<T>>(
              future: future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                      padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
                }
                if (snap.hasError || snap.data == null) {
                  return const Text('Failed to load', style: TextStyle(color: Colors.red));
                }
                final items = snap.data!;
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('No data yet',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.onSurface.withAlpha(140))),
                  );
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowHeight: 32,
                    dataRowMinHeight: 36,
                    dataRowMaxHeight: 36,
                    columnSpacing: 16,
                    columns: [
                      for (final h in headerColumns)
                        DataColumn(label: Text(h, style: theme.textTheme.labelSmall)),
                    ],
                    rows: [
                      for (int i = 0; i < items.length; i++)
                        DataRow(cells: [
                          for (final v in rowBuilder(items[i], i))
                            DataCell(Text(v,
                                style: v == rowBuilder(items[i], i)[1]
                                    ? theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)
                                    : theme.textTheme.bodySmall)),
                        ]),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HighScoringSection extends StatelessWidget {
  final Future<List<HighScoringMatch>> future;
  const _HighScoringSection({required this.future});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.local_fire_department, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text('Highest Scoring Matches',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 8),
            FutureBuilder<List<HighScoringMatch>>(
              future: future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                }
                if (snap.hasError || snap.data == null) {
                  return const Text('Failed to load', style: TextStyle(color: Colors.red));
                }
                final items = snap.data!;
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('No matches played yet',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.onSurface.withAlpha(140))),
                  );
                }
                return Column(
                  children: [
                    for (final m in items)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(children: [
                          SizedBox(
                              width: 24,
                              child: Text('${m.rank}.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withAlpha(140)))),
                          Expanded(
                            child: Text(
                              '${m.homeTeamName} ${m.homeScore} – ${m.awayScore} ${m.awayTeamName}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                          Chip(
                            label: Text('${m.totalGoals} goals'),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            labelStyle: theme.textTheme.labelSmall,
                            visualDensity: VisualDensity.compact,
                          ),
                        ]),
                      ),
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
