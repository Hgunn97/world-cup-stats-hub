import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tournament_summary_model.dart';
import '../models/match_model.dart';
import '../models/group_table_model.dart';
import '../models/team_stats_model.dart';
import '../models/wall_chart_model.dart';

class ApiService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5050',
  ) + '/api';

  final http.Client _client;
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<T> _get<T>(String path, T Function(dynamic) fromJson) async {
    final response = await _client.get(Uri.parse('$_baseUrl$path'));
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    return fromJson(jsonDecode(response.body));
  }

  Future<TournamentSummary> getTournamentSummary() =>
      _get('/tournament/summary', (j) => TournamentSummary.fromJson(j as Map<String, dynamic>));

  Future<List<Match>> getMatches({String? stage, String? groupCode, String? date}) {
    final params = <String, String>{};
    if (stage != null) params['stage'] = stage;
    if (groupCode != null) params['groupCode'] = groupCode;
    if (date != null) params['date'] = date;
    final query = params.isEmpty ? '' : '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    return _get('/matches$query', (j) => (j as List).map((e) => Match.fromJson(e as Map<String, dynamic>)).toList());
  }

  Future<Match> getMatch(int matchId) =>
      _get('/matches/$matchId', (j) => Match.fromJson(j as Map<String, dynamic>));

  Future<List<GroupTable>> getAllGroupTables() =>
      _get('/groups', (j) => (j as List).map((e) => GroupTable.fromJson(e as Map<String, dynamic>)).toList());

  Future<GroupTable> getGroupTable(String groupCode) =>
      _get('/groups/$groupCode/table', (j) => GroupTable.fromJson(j as Map<String, dynamic>));

  Future<List<TeamStats>> getTopScoringTeams({int limit = 10}) =>
      _get('/stats/teams/top-scoring?limit=$limit',
          (j) => ((j as Map<String, dynamic>)['items'] as List)
              .map((e) => TeamStats.fromJson(e as Map<String, dynamic>))
              .toList());

  Future<List<TeamStats>> getMostConcededTeams({int limit = 10}) =>
      _get('/stats/teams/most-conceded?limit=$limit',
          (j) => ((j as Map<String, dynamic>)['items'] as List)
              .map((e) => TeamStats.fromJson(e as Map<String, dynamic>))
              .toList());

  Future<List<TeamStats>> getBestGoalDifferenceTeams({int limit = 10}) =>
      _get('/stats/teams/best-goal-difference?limit=$limit',
          (j) => ((j as Map<String, dynamic>)['items'] as List)
              .map((e) => TeamStats.fromJson(e as Map<String, dynamic>))
              .toList());

  Future<List<TeamStats>> getCleanSheetTeams({int limit = 10}) =>
      _get('/stats/teams/clean-sheets?limit=$limit',
          (j) => ((j as Map<String, dynamic>)['items'] as List)
              .map((e) => TeamStats.fromJson(e as Map<String, dynamic>))
              .toList());

  Future<List<HighScoringMatch>> getHighestScoringMatches({int limit = 10}) =>
      _get('/stats/matches/highest-scoring?limit=$limit',
          (j) => ((j as Map<String, dynamic>)['items'] as List)
              .map((e) => HighScoringMatch.fromJson(e as Map<String, dynamic>))
              .toList());

  Future<WallChart> getWallChart() =>
      _get('/wall-chart', (j) => WallChart.fromJson(j as Map<String, dynamic>));

  Future<Match> updateMatchResult(int matchId, int homeScore, int awayScore, {int? winnerTeamId}) async {
    final body = jsonEncode({
      'homeScore': homeScore,
      'awayScore': awayScore,
      'status': 'Finished',
      'winnerTeamId': winnerTeamId,
    });
    final response = await _client.put(
      Uri.parse('$_baseUrl/matches/$matchId/result'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    return Match.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String body;
  ApiException(this.statusCode, this.body);

  @override
  String toString() => 'ApiException($statusCode): $body';
}
