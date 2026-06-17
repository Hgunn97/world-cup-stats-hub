import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/match_model.dart';
import '../services/api_service.dart';
import '../utils/time_utils.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';

class MatchDetailScreen extends StatefulWidget {
  final int matchId;
  const MatchDetailScreen({super.key, required this.matchId});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  final _api = ApiService();
  late Future<Match> _future;
  final _homeController = TextEditingController();
  final _awayController = TextEditingController();
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() { _future = _api.getMatch(widget.matchId); });

  Future<void> _updateResult() async {
    final home = int.tryParse(_homeController.text);
    final away = int.tryParse(_awayController.text);
    if (home == null || away == null || home < 0 || away < 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter valid scores (0 or above).')));
      return;
    }
    setState(() { _updating = true; });
    try {
      await _api.updateMatchResult(widget.matchId, home, away);
      _homeController.clear();
      _awayController.clear();
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() { _updating = false; });
    }
  }

  @override
  void dispose() {
    _homeController.dispose();
    _awayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match Detail')),
      body: FutureBuilder<Match>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const LoadingView();
          if (snapshot.hasError) {
            return ErrorView(message: 'Could not load match.', onRetry: _load);
          }
          final match = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _InfoRow('Match', '#${match.matchNumber}'),
                _InfoRow('Stage', _stageLabel(match.stage)),
                if (match.groupCode != null) _InfoRow('Group', 'Group ${match.groupCode}'),
                _InfoRow('Status', match.status),
                _InfoRow(
                  'Kick-off',
                  '${DateFormat('EEE d MMM yyyy · HH:mm').format(toUkTime(match.kickOffUtc))} BST',
                ),
                if (match.venue != null) _InfoRow('Venue', match.venue!),
                const Divider(height: 32),
                _ScorePanel(match: match),
                if (match.winnerTeamId != null) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: Chip(
                      label: Text('Winner: ${match.winnerTeamName}'),
                      avatar: const Icon(Icons.emoji_events, size: 16),
                    ),
                  ),
                ],
                const Divider(height: 32),
                Text('Update Result',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _homeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: match.homeDisplay,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('–', style: TextStyle(fontSize: 20)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _awayController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: match.awayDisplay,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _updating ? null : _updateResult,
                  child: _updating
                      ? const SizedBox(
                          height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save Result'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _stageLabel(String stage) => switch (stage) {
        'GroupStage' => 'Group Stage',
        'RoundOf32' => 'Round of 32',
        'RoundOf16' => 'Round of 16',
        'QuarterFinal' => 'Quarter-final',
        'SemiFinal' => 'Semi-final',
        'ThirdPlacePlayoff' => 'Third Place Playoff',
        'Final' => 'Final',
        _ => stage,
      };
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(150))),
        ),
        Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
      ]),
    );
  }
}

class _ScorePanel extends StatelessWidget {
  final Match match;
  const _ScorePanel({required this.match});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Text(match.homeDisplay,
              textAlign: TextAlign.end,
              style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: match.winnerTeamId == match.homeTeamId
                      ? FontWeight.bold
                      : FontWeight.normal)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: match.isFinished
              ? Text('${match.homeScore}  –  ${match.awayScore}',
                  style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold))
              : Text('vs', style: theme.textTheme.titleLarge),
        ),
        Expanded(
          child: Text(match.awayDisplay,
              style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: match.winnerTeamId == match.awayTeamId
                      ? FontWeight.bold
                      : FontWeight.normal)),
        ),
      ],
    );
  }
}
