import 'package:flutter/material.dart';
import '../models/tournament_summary_model.dart';
import '../services/api_service.dart';
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
  late Future<TournamentSummary> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() { _future = _api.getTournamentSummary(); });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('World Cup 2026'),
        centerTitle: false,
      ),
      body: FutureBuilder<TournamentSummary>(
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
          final s = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _load(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, 'Tournament Progress'),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: StatCard(
                        label: 'Matches Played',
                        value: '${s.matchesPlayed}',
                        subtitle: 'of ${s.totalMatches}',
                        icon: Icons.sports_soccer,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatCard(
                        label: 'Remaining',
                        value: '${s.matchesRemaining}',
                        icon: Icons.schedule,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: StatCard(
                        label: 'Total Goals',
                        value: '${s.totalGoals}',
                        icon: Icons.star,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatCard(
                        label: 'Goals/Match',
                        value: s.goalsPerMatch.toStringAsFixed(2),
                        icon: Icons.bar_chart,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _sectionTitle(context, 'Highlights'),
                  const SizedBox(height: 8),
                  if (s.topScoringTeam != null)
                    StatCard(
                      label: 'Top Scoring Team',
                      value: s.topScoringTeam!.teamName,
                      subtitle: '${s.topScoringTeam!.value} goals',
                      icon: Icons.emoji_events,
                    ),
                  const SizedBox(height: 8),
                  if (s.mostConcededTeam != null)
                    StatCard(
                      label: 'Most Conceded',
                      value: s.mostConcededTeam!.teamName,
                      subtitle: '${s.mostConcededTeam!.value} goals conceded',
                      icon: Icons.shield_outlined,
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
                    ),
                  const SizedBox(height: 8),
                  if (s.mostCleanSheetsTeam != null)
                    StatCard(
                      label: 'Most Clean Sheets',
                      value: s.mostCleanSheetsTeam!.teamName,
                      subtitle: '${s.mostCleanSheetsTeam!.value} clean sheets',
                      icon: Icons.lock_outline,
                    ),
                  const SizedBox(height: 8),
                  if (s.highestScoringMatch != null)
                    StatCard(
                      label: 'Highest Scoring Match',
                      value:
                          '${s.highestScoringMatch!.homeTeamName} ${s.highestScoringMatch!.homeScore} – ${s.highestScoringMatch!.awayScore} ${s.highestScoringMatch!.awayTeamName}',
                      subtitle: '${s.highestScoringMatch!.totalGoals} goals',
                      icon: Icons.local_fire_department,
                    ),
                  if (s.matchesPlayed == 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Tournament stats will appear once matches are played.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(140)),
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
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold));
}
