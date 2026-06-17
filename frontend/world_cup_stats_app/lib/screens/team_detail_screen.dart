import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/group_table_model.dart';
import '../models/match_model.dart';
import '../services/api_service.dart';
import '../utils/flag_utils.dart';
import '../utils/time_utils.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';

class TeamDetailScreen extends StatefulWidget {
  final int teamId;
  final String teamName;
  final String groupCode;

  const TeamDetailScreen({
    super.key,
    required this.teamId,
    required this.teamName,
    required this.groupCode,
  });

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  final _api = ApiService();
  late Future<_TeamData> _future;

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

  Future<_TeamData> _loadData() async {
    final results = await Future.wait([
      _api.getGroupTable(widget.groupCode),
      _api.getMatches(groupCode: widget.groupCode),
    ]);
    final table = results[0] as GroupTable;
    final matches = results[1] as List<Match>;

    final row = table.teams.firstWhere(
      (t) => t.teamId == widget.teamId,
    );
    final teamMatches = matches
        .where((m) => m.homeTeamId == widget.teamId || m.awayTeamId == widget.teamId)
        .toList()
      ..sort((a, b) => a.kickOffUtc.compareTo(b.kickOffUtc));

    return _TeamData(row: row, matches: teamMatches, table: table);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teamName),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: FutureBuilder<_TeamData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: 'Could not load team details.',
              onRetry: _load,
            );
          }
          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _load(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatsCard(row: data.row),
                  const SizedBox(height: 20),
                  Text(
                    'Group ${data.row.groupCode} Fixtures',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  for (final match in data.matches)
                    _MatchRow(match: match, teamId: widget.teamId),
                  if (data.matches.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No fixtures found.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(140),
                              ),
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
}

// ── Stats summary card ────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final GroupTableRow row;
  const _StatsCard({required this.row});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TeamFlag(countryCode: row.countryCode, height: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Group ${row.groupCode}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withAlpha(60)),
                  ),
                  child: Text(
                    '#${row.position}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat('Pts', '${row.points}', bold: true),
                _Stat('P', '${row.played}'),
                _Stat('W', '${row.won}'),
                _Stat('D', '${row.drawn}'),
                _Stat('L', '${row.lost}'),
                _Stat('GF', '${row.goalsFor}'),
                _Stat('GA', '${row.goalsAgainst}'),
                _Stat('GD', row.goalDifference >= 0 ? '+${row.goalDifference}' : '${row.goalDifference}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _Stat(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: bold ? theme.colorScheme.primary : null,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(140),
          ),
        ),
      ],
    );
  }
}

// ── Fixture row ───────────────────────────────────────────────────────────────

class _MatchRow extends StatelessWidget {
  final Match match;
  final int teamId;

  const _MatchRow({required this.match, required this.teamId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ukTime = toUkTime(match.kickOffUtc);
    final dateStr = DateFormat('EEE d MMM').format(ukTime);
    final timeStr = DateFormat('HH:mm').format(ukTime);

    final isHome = match.homeTeamId == teamId;
    final isFinished = match.isFinished;
    final myScore = isHome ? match.homeScore : match.awayScore;
    final theirScore = isHome ? match.awayScore : match.homeScore;
    final opponentName = isHome ? match.awayDisplay : match.homeDisplay;

    final won = isFinished && myScore != null && theirScore != null && myScore > theirScore;
    final drawn = isFinished && myScore != null && theirScore != null && myScore == theirScore;
    final lost = isFinished && myScore != null && theirScore != null && myScore < theirScore;

    Color? resultColor;
    String? resultLabel;
    if (won) { resultColor = const Color(0xFF43A047); resultLabel = 'W'; }
    else if (drawn) { resultColor = const Color(0xFFFFC107); resultLabel = 'D'; }
    else if (lost) { resultColor = const Color(0xFFE53935); resultLabel = 'L'; }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Result badge or home/away indicator
            SizedBox(
              width: 28,
              child: resultLabel != null
                  ? Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: resultColor!.withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: resultColor.withAlpha(100)),
                      ),
                      child: Text(
                        resultLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: resultColor,
                        ),
                      ),
                    )
                  : Text(
                      isHome ? 'H' : 'A',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(100),
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
            const SizedBox(width: 10),
            // Opponent
            Expanded(
              child: Text(
                isHome ? 'vs $opponentName' : '@ $opponentName',
                style: theme.textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Score or date/time
            if (isFinished)
              Text(
                '$myScore – $theirScore',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              )
            else
              Text(
                '$dateStr · $timeStr BST',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(140),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Data holder ───────────────────────────────────────────────────────────────

class _TeamData {
  final GroupTableRow row;
  final List<Match> matches;
  final GroupTable table;

  _TeamData({required this.row, required this.matches, required this.table});
}
