import 'package:flutter/material.dart';
import '../models/group_table_model.dart';
import '../services/api_service.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';

class GroupTablesScreen extends StatefulWidget {
  const GroupTablesScreen({super.key});

  @override
  State<GroupTablesScreen> createState() => _GroupTablesScreenState();
}

class _GroupTablesScreenState extends State<GroupTablesScreen> {
  final _api = ApiService();
  late Future<List<GroupTable>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() { _future = _api.getAllGroupTables(); });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Tables')),
      body: FutureBuilder<List<GroupTable>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const LoadingView();
          if (snapshot.hasError) {
            return ErrorView(message: 'Could not load group tables.', onRetry: _load);
          }
          final groups = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _load(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: groups.length + 1,
              itemBuilder: (context, i) {
                if (i < groups.length) return _GroupTableCard(table: groups[i]);
                return _BestThirdPlaceCard(groups: groups);
              },
            ),
          );
        },
      ),
    );
  }
}

// ── Individual group table ────────────────────────────────────────────────────

class _GroupTableCard extends StatelessWidget {
  final GroupTable table;
  const _GroupTableCard({required this.table});

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
            Text('Group ${table.groupCode}',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _StatsTable(
              rows: table.teams,
              showGroup: false,
              qualifyingCount: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Best 3rd place card ───────────────────────────────────────────────────────

class _BestThirdPlaceCard extends StatelessWidget {
  final List<GroupTable> groups;
  const _BestThirdPlaceCard({required this.groups});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Collect the 3rd-placed team from each group
    final third = <GroupTableRow>[];
    for (final g in groups) {
      final sorted = [...g.teams]..sort((a, b) {
          final pts = b.points.compareTo(a.points);
          if (pts != 0) return pts;
          final gd = b.goalDifference.compareTo(a.goalDifference);
          if (gd != 0) return gd;
          return b.goalsFor.compareTo(a.goalsFor);
        });
      if (sorted.length >= 3) third.add(sorted[2]);
    }

    // Rank by points → GD → GF → name
    third.sort((a, b) {
      final pts = b.points.compareTo(a.points);
      if (pts != 0) return pts;
      final gd = b.goalDifference.compareTo(a.goalDifference);
      if (gd != 0) return gd;
      final gf = b.goalsFor.compareTo(a.goalsFor);
      if (gf != 0) return gf;
      return a.teamName.compareTo(b.teamName);
    });

    final anyPlayed = third.any((r) => r.played > 0);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Best 3rd Place Teams',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF004B87).withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF004B87).withAlpha(60)),
                  ),
                  child: Text(
                    'Top 8 advance',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF004B87),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!anyPlayed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Rankings will appear once group matches are played.',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(140)),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              _StatsTable(
                rows: third,
                showGroup: true,
                qualifyingCount: 8,
              ),
            const SizedBox(height: 10),
            _Legend(),
          ],
        ),
      ),
    );
  }
}

// ── Shared stats table ────────────────────────────────────────────────────────

class _StatsTable extends StatelessWidget {
  final List<GroupTableRow> rows;
  final bool showGroup;
  final int qualifyingCount;

  const _StatsTable({
    required this.rows,
    required this.showGroup,
    required this.qualifyingCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final headers = showGroup
        ? ['', 'Team', 'Grp', 'P', 'W', 'D', 'L', 'GF', 'GA', 'GD', 'Pts']
        : ['', 'Team', 'P', 'W', 'D', 'L', 'GF', 'GA', 'GD', 'Pts'];

    final colWidths = showGroup
        ? const {
            0: FixedColumnWidth(24),
            1: FlexColumnWidth(),
            2: FixedColumnWidth(32),
            3: FixedColumnWidth(28),
            4: FixedColumnWidth(28),
            5: FixedColumnWidth(28),
            6: FixedColumnWidth(28),
            7: FixedColumnWidth(36),
            8: FixedColumnWidth(36),
            9: FixedColumnWidth(36),
            10: FixedColumnWidth(32),
          }
        : const {
            0: FixedColumnWidth(24),
            1: FlexColumnWidth(),
            2: FixedColumnWidth(28),
            3: FixedColumnWidth(28),
            4: FixedColumnWidth(28),
            5: FixedColumnWidth(28),
            6: FixedColumnWidth(36),
            7: FixedColumnWidth(36),
            8: FixedColumnWidth(36),
            9: FixedColumnWidth(32),
          };

    return Table(
      columnWidths: colWidths,
      children: [
        TableRow(
          decoration:
              BoxDecoration(border: Border(bottom: BorderSide(color: theme.dividerColor))),
          children: [
            for (final h in headers)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(h,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.onSurface.withAlpha(150)),
                    textAlign: h == 'Team' ? TextAlign.left : TextAlign.center),
              ),
          ],
        ),
        for (int i = 0; i < rows.length; i++)
          _buildRow(context, rows[i], i + 1, qualifyingCount, showGroup),
      ],
    );
  }

  TableRow _buildRow(BuildContext context, GroupTableRow row, int rank,
      int qualifyingCount, bool showGroup) {
    final theme = Theme.of(context);
    final qualifies = rank <= qualifyingCount;

    // Determine row status for the 3rd-place table
    // A team is "possibly qualifying" if they haven't finished their group yet
    // but are currently in a qualifying position
    final possiblyQualifying = showGroup && qualifies && row.played < 3;
    final confirmed = qualifies && row.played == 3;

    Color? indicatorColor;
    if (confirmed) {
      indicatorColor = const Color(0xFF43A047);
    } else if (possiblyQualifying || (!showGroup && qualifies)) {
      indicatorColor = const Color(0xFFFFC107);
    }

    final statValues = showGroup
        ? [row.played, row.won, row.drawn, row.lost, row.goalsFor, row.goalsAgainst, row.goalDifference, row.points]
        : [row.played, row.won, row.drawn, row.lost, row.goalsFor, row.goalsAgainst, row.goalDifference, row.points];

    return TableRow(
      decoration: BoxDecoration(
        color: qualifies
            ? (confirmed
                ? const Color(0xFF43A047).withAlpha(15)
                : const Color(0xFFFFC107).withAlpha(15))
            : null,
      ),
      children: [
        // Rank / position with qualifying indicator bar
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 3,
                height: 16,
                color: indicatorColor ?? Colors.transparent,
              ),
              const SizedBox(width: 3),
              Text('$rank',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurface.withAlpha(150))),
            ],
          ),
        ),
        // Team name
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            row.teamName,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: qualifies ? FontWeight.w600 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Group column (only in 3rd place table)
        if (showGroup)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(row.groupCode,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurface.withAlpha(140)),
                textAlign: TextAlign.center),
          ),
        // Stat columns
        for (final v in statValues)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              '$v',
              style: v == row.points
                  ? theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)
                  : theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

// ── Legend ────────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
        );
    return Row(
      children: [
        _dot(const Color(0xFF43A047)),
        const SizedBox(width: 4),
        Text('Qualified', style: style),
        const SizedBox(width: 16),
        _dot(const Color(0xFFFFC107)),
        const SizedBox(width: 4),
        Text('Possible qualification', style: style),
      ],
    );
  }

  Widget _dot(Color color) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
