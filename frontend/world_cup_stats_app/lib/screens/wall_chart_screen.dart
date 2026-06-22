import 'package:flutter/material.dart';
import '../models/wall_chart_model.dart';
import '../models/group_table_model.dart';
import '../services/api_service.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';

// ── Layout constants ──────────────────────────────────────────────────────────
const double _slotH = 68.0; // height of one R32 slot
const double _cardH = 58.0; // match card height
const double _cardW = 132.0; // match card width
const int _r32N = 8; // R32 matches per side
const double _totalH = _slotH * _r32N; // 544 – shared bracket height
const double _headerH = 26.0; // stage label height
const double _groupW = 152.0;
const double _groupGap = 4.0;
const double _groupCardH = (_totalH - 5 * _groupGap) / 6; // ~88

// ── Colour palettes (A–L) ─────────────────────────────────────────────────────
const _groupBg = [
  Color(0xFFE8F5E9), Color(0xFFE3F2FD), Color(0xFFFCE4EC), Color(0xFFFFF8E1),
  Color(0xFFF3E5F5), Color(0xFFE0F2F1), Color(0xFFFBE9E7), Color(0xFFF1F8E9),
  Color(0xFFE8EAF6), Color(0xFFFFF3E0), Color(0xFFE0F7FA), Color(0xFFEDE7F6),
];
const _groupHd = [
  Color(0xFF2E7D32), Color(0xFF1565C0), Color(0xFFC62828), Color(0xFFF57F17),
  Color(0xFF6A1B9A), Color(0xFF00695C), Color(0xFFBF360C), Color(0xFF558B2F),
  Color(0xFF283593), Color(0xFFE65100), Color(0xFF006064), Color(0xFF4527A0),
];

// ── Data holder ───────────────────────────────────────────────────────────────
class _Data {
  final List<GroupTable> groups;
  final WallChart chart;
  _Data(this.groups, this.chart);
}

// ── Screen ────────────────────────────────────────────────────────────────────
class WallChartScreen extends StatefulWidget {
  const WallChartScreen({super.key});

  @override
  State<WallChartScreen> createState() => _WallChartScreenState();
}

class _WallChartScreenState extends State<WallChartScreen> {
  final _api = ApiService();
  late Future<_Data> _future;
  bool _isRecalculating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() {
        _future = Future.wait([_api.getAllGroupTables(), _api.getWallChart()])
            .then((r) => _Data(r[0] as List<GroupTable>, r[1] as WallChart));
      });

  Future<void> _recalculate() async {
    setState(() => _isRecalculating = true);
    try {
      await _api.recalculateKnockout();
      if (!mounted) return;
      _load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bracket recalculated'), duration: Duration(seconds: 2)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recalculation failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isRecalculating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(
        title: const Text('Wall Chart'),
        backgroundColor: const Color(0xFF004B87),
        foregroundColor: Colors.white,
        actions: [
          if (_isRecalculating)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Recalculate bracket',
              onPressed: _recalculate,
            ),
        ],
      ),
      body: FutureBuilder<_Data>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const LoadingView();
          if (snap.hasError) return ErrorView(message: 'Could not load wall chart.', onRetry: _load);
          return InteractiveViewer(
            constrained: false,
            boundaryMargin: const EdgeInsets.all(64),
            minScale: 0.2,
            maxScale: 3.0,
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _WallChart(data: snap.data!),
            ),
          );
        },
      ),
    );
  }
}

// ── Root layout ───────────────────────────────────────────────────────────────
class _WallChart extends StatelessWidget {
  final _Data data;
  const _WallChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final groups = [...data.groups]..sort((a, b) => a.groupCode.compareTo(b.groupCode));
    final leftGrp = groups.where((g) => 'ABCDEF'.contains(g.groupCode)).toList();
    final rightGrp = groups.where((g) => 'GHIJKL'.contains(g.groupCode)).toList();

    final sm = {for (final s in data.chart.stages) s.stage: s.matches};

    List<WallChartMatch?> pad(String key, int n) {
      final list = sm[key] ?? [];
      return List.generate(n, (i) => i < list.length ? list[i] : null);
    }

    final r32 = pad('RoundOf32', 16);
    final r16 = pad('RoundOf16', 8);
    final qf = pad('QuarterFinal', 4);
    final sf = pad('SemiFinal', 2);
    final fn = sm['Final'] ?? [];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GroupsPanel(groups: leftGrp, paletteOffset: 0),
        const SizedBox(width: 10),
        _StageCol(label: 'Round of 32', matches: r32.sublist(0, 8)),
        const SizedBox(width: 5),
        _StageCol(label: 'Round of 16', matches: r16.sublist(0, 4)),
        const SizedBox(width: 5),
        _StageCol(label: 'Quarter Final', matches: qf.sublist(0, 2)),
        const SizedBox(width: 5),
        _StageCol(label: 'Semi Final', matches: [sf[0]]),
        const SizedBox(width: 5),
        _FinalCol(match: fn.isNotEmpty ? fn[0] : null),
        const SizedBox(width: 5),
        _StageCol(label: 'Semi Final', matches: [sf[1]]),
        const SizedBox(width: 5),
        _StageCol(label: 'Quarter Final', matches: qf.sublist(2, 4)),
        const SizedBox(width: 5),
        _StageCol(label: 'Round of 16', matches: r16.sublist(4, 8)),
        const SizedBox(width: 5),
        _StageCol(label: 'Round of 32', matches: r32.sublist(8, 16)),
        const SizedBox(width: 10),
        _GroupsPanel(groups: rightGrp, paletteOffset: 6),
      ],
    );
  }
}

// ── Stage column (R32 / R16 / QF / SF) ───────────────────────────────────────
class _StageCol extends StatelessWidget {
  final String label;
  final List<WallChartMatch?> matches;
  const _StageCol({required this.label, required this.matches});

  @override
  Widget build(BuildContext context) {
    final n = matches.length;
    final slotH = (_r32N / n) * _slotH;

    return SizedBox(
      width: _cardW,
      child: Column(
        children: [
          _Header(label: label, color: const Color(0xFF004B87)),
          const SizedBox(height: 4),
          SizedBox(
            height: _totalH,
            child: Column(
              children: [
                for (final m in matches)
                  SizedBox(
                    height: slotH,
                    child: Center(child: _MatchTile(match: m)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Final column ──────────────────────────────────────────────────────────────
class _FinalCol extends StatelessWidget {
  final WallChartMatch? match;
  const _FinalCol({this.match});

  @override
  Widget build(BuildContext context) {
    const w = _cardW + 24;
    return SizedBox(
      width: w,
      child: Column(
        children: [
          Container(
            height: _headerH,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: const Text(
              'FINAL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: _totalH,
            child: Center(
              child: _MatchTile(match: match, isFinal: true, width: w),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stage header chip ─────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String label;
  final Color color;
  const _Header({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _headerH,
      width: _cardW,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ── Match tile ────────────────────────────────────────────────────────────────
class _MatchTile extends StatelessWidget {
  final WallChartMatch? match;
  final bool isFinal;
  final double width;

  const _MatchTile({this.match, this.isFinal = false, double? width})
      : width = width ?? _cardW;

  @override
  Widget build(BuildContext context) {
    final borderColor = isFinal ? const Color(0xFFFFB300) : Colors.grey.shade300;
    final bgColor = isFinal ? const Color(0xFFFFFBF0) : Colors.white;

    if (match == null) {
      return Container(
        width: width,
        height: _cardH,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(140),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Text('TBD', style: TextStyle(color: Colors.grey, fontSize: 11)),
        ),
      );
    }

    final finished = match!.status == 'Finished';
    final homeWon = finished && match!.winnerTeamId == match!.homeTeamId && match!.winnerTeamId != null;
    final awayWon = finished && match!.winnerTeamId == match!.awayTeamId && match!.winnerTeamId != null;

    return Container(
      width: width,
      height: _cardH,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: borderColor, width: isFinal ? 1.5 : 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(18), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          _TileRow(
            name: match!.homeDisplay,
            score: finished ? match!.homeScore : null,
            isWinner: homeWon,
            isTop: true,
          ),
          Divider(height: 1, thickness: 0.8, color: Colors.grey.shade200),
          _TileRow(
            name: match!.awayDisplay,
            score: finished ? match!.awayScore : null,
            isWinner: awayWon,
            isTop: false,
          ),
        ],
      ),
    );
  }
}

class _TileRow extends StatelessWidget {
  final String name;
  final int? score;
  final bool isWinner;
  final bool isTop;

  const _TileRow({
    required this.name,
    this.score,
    required this.isWinner,
    required this.isTop,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isWinner ? const Color(0xFFE8F5E9) : null,
          borderRadius: isTop
              ? const BorderRadius.vertical(top: Radius.circular(6))
              : const BorderRadius.vertical(bottom: Radius.circular(6)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Row(
          children: [
            if (isWinner)
              const Padding(
                padding: EdgeInsets.only(right: 3),
                child: Icon(Icons.star, size: 9, color: Color(0xFF2E7D32)),
              ),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (score != null)
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isWinner ? const Color(0xFF1B5E20) : Colors.black87,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Groups panel (6 groups, one side) ─────────────────────────────────────────
class _GroupsPanel extends StatelessWidget {
  final List<GroupTable> groups;
  final int paletteOffset;

  const _GroupsPanel({required this.groups, required this.paletteOffset});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _groupW,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: _headerH + 4), // align with stage label row
          for (int i = 0; i < groups.length; i++) ...[
            if (i > 0) const SizedBox(height: _groupGap),
            SizedBox(
              height: _groupCardH,
              child: _GroupCard(
                table: groups[i],
                bg: _groupBg[paletteOffset + i],
                hd: _groupHd[paletteOffset + i],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupTable table;
  final Color bg;
  final Color hd;

  const _GroupCard({required this.table, required this.bg, required this.hd});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: hd.withAlpha(70)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: hd,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
            child: Text(
              'Group ${table.groupCode}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < table.teams.length; i++)
                  _GroupRow(row: table.teams[i], qualifies: i < 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupRow extends StatelessWidget {
  final GroupTableRow row;
  final bool qualifies;

  const _GroupRow({required this.row, required this.qualifies});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: qualifies ? const Color(0xFF43A047) : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
            alignment: Alignment.center,
            child: Text(
              '${row.position}',
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              row.teamName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: qualifies ? FontWeight.w700 : FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            '${row.points}',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
