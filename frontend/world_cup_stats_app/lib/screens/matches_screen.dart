import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/match_model.dart';
import '../services/api_service.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import '../widgets/match_card.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final _api = ApiService();
  late Future<List<Match>> _future;
  String _filter = 'All';

  static const _filters = ['All', 'Group Stage', 'Knockout'];
  static const _groups = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    String? stage;
    if (_filter == 'Group Stage') stage = 'GroupStage';
    setState(() { _future = _api.getMatches(stage: stage); });
  }

  List<Match> _applyFilter(List<Match> all) {
    if (_filter == 'Knockout') {
      return all.where((m) => m.stage != 'GroupStage').toList();
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                for (final f in _filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(f),
                      selected: _filter == f,
                      onSelected: (_) {
                        _filter = f;
                        _load();
                      },
                    ),
                  ),
                for (final g in _groups)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text('Grp $g'),
                      selected: _filter == 'Grp $g',
                      onSelected: (_) {
                        _filter = 'Grp $g';
                        setState(() { _future = _api.getMatches(groupCode: g); });
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Match>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const LoadingView();
          if (snapshot.hasError) {
            return ErrorView(message: 'Could not load matches.', onRetry: _load);
          }
          final matches = _applyFilter(snapshot.data!);
          if (matches.isEmpty) {
            return const Center(child: Text('No matches found.'));
          }
          return RefreshIndicator(
            onRefresh: () async => _load(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: matches.length,
              itemBuilder: (context, i) => MatchCard(
                match: matches[i],
                onTap: () => context.push('/matches/${matches[i].id}'),
              ),
            ),
          );
        },
      ),
    );
  }
}
