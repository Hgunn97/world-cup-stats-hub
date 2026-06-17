import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/match_model.dart';
import '../utils/time_utils.dart';

class MatchCard extends StatelessWidget {
  final Match match;
  final VoidCallback? onTap;

  const MatchCard({super.key, required this.match, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ukTime = toUkTime(match.kickOffUtc);
    final dateStr = DateFormat('EEE d MMM').format(ukTime);
    final timeStr = '${DateFormat('HH:mm').format(ukTime)} BST';

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (match.groupCode != null)
                    _chip('Group ${match.groupCode}', theme.colorScheme.primaryContainer,
                        theme.colorScheme.onPrimaryContainer),
                  _chip(_stageLabel(match.stage), theme.colorScheme.secondaryContainer,
                      theme.colorScheme.onSecondaryContainer),
                  const Spacer(),
                  _statusBadge(match.status, theme),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(match.homeDisplay,
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: match.winnerTeamId == match.homeTeamId
                                ? FontWeight.bold
                                : FontWeight.normal)),
                  ),
                  if (match.isFinished)
                    Text('${match.homeScore}  –  ${match.awayScore}',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))
                  else
                    Text('vs', style: theme.textTheme.bodyMedium),
                  Expanded(
                    child: Text(match.awayDisplay,
                        textAlign: TextAlign.end,
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: match.winnerTeamId == match.awayTeamId
                                ? FontWeight.bold
                                : FontWeight.normal)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('$dateStr · $timeStr${match.venue != null ? ' · ${match.venue}' : ''}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurface.withAlpha(140))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String text, Color bg, Color fg) => Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
        child: Text(text, style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w600)),
      );

  Widget _statusBadge(String status, ThemeData theme) {
    final (color, label) = switch (status) {
      'Finished' => (Colors.green, 'FT'),
      'InProgress' => (Colors.orange, 'LIVE'),
      'Postponed' => (Colors.grey, 'PP'),
      _ => (theme.colorScheme.outline, ''),
    };
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withAlpha(100))),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
    );
  }

  String _stageLabel(String stage) {
    return switch (stage) {
      'GroupStage' => 'Group Stage',
      'RoundOf32' => 'R32',
      'RoundOf16' => 'R16',
      'QuarterFinal' => 'QF',
      'SemiFinal' => 'SF',
      'ThirdPlacePlayoff' => '3rd Place',
      'Final' => 'Final',
      _ => stage,
    };
  }
}
