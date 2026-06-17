class GroupTableRow {
  final int position;
  final int teamId;
  final String teamName;
  final String groupCode;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;
  final int points;

  GroupTableRow(
      {required this.position,
      required this.teamId,
      required this.teamName,
      required this.groupCode,
      required this.played,
      required this.won,
      required this.drawn,
      required this.lost,
      required this.goalsFor,
      required this.goalsAgainst,
      required this.goalDifference,
      required this.points});

  factory GroupTableRow.fromJson(Map<String, dynamic> json) => GroupTableRow(
        position: json['position'] as int,
        teamId: json['teamId'] as int,
        teamName: json['teamName'] as String,
        groupCode: json['groupCode'] as String,
        played: json['played'] as int,
        won: json['won'] as int,
        drawn: json['drawn'] as int,
        lost: json['lost'] as int,
        goalsFor: json['goalsFor'] as int,
        goalsAgainst: json['goalsAgainst'] as int,
        goalDifference: json['goalDifference'] as int,
        points: json['points'] as int,
      );
}

class GroupTable {
  final String groupCode;
  final List<GroupTableRow> teams;

  GroupTable({required this.groupCode, required this.teams});

  factory GroupTable.fromJson(Map<String, dynamic> json) => GroupTable(
        groupCode: json['groupCode'] as String,
        teams: (json['teams'] as List<dynamic>)
            .map((e) => GroupTableRow.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
