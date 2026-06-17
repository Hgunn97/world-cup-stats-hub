import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/matches_screen.dart';
import 'screens/match_detail_screen.dart';
import 'screens/group_tables_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/wall_chart_screen.dart';
import 'screens/team_detail_screen.dart';

final _shellKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  routes: [
    ShellRoute(
      navigatorKey: _shellKey,
      builder: (context, state, child) => _Shell(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/stats', builder: (context, state) => const StatsScreen()),
        GoRoute(path: '/groups', builder: (context, state) => const GroupTablesScreen()),
        GoRoute(path: '/matches', builder: (context, state) => const MatchesScreen()),
        GoRoute(path: '/wall-chart', builder: (context, state) => const WallChartScreen()),
      ],
    ),
    GoRoute(
      path: '/matches/:id',
      builder: (context, state) =>
          MatchDetailScreen(matchId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/teams/:teamId',
      builder: (context, state) => TeamDetailScreen(
        teamId: int.parse(state.pathParameters['teamId']!),
        teamName: state.uri.queryParameters['name'] ?? '',
        groupCode: state.uri.queryParameters['group'] ?? '',
      ),
    ),
  ],
);

class _Shell extends StatelessWidget {
  final Widget child;
  const _Shell({required this.child});

  static const _destinations = [
    (icon: Icons.home_outlined, label: 'Home', path: '/'),
    (icon: Icons.bar_chart, label: 'Stats', path: '/stats'),
    (icon: Icons.table_chart_outlined, label: 'Groups', path: '/groups'),
    (icon: Icons.sports_soccer, label: 'Matches', path: '/matches'),
    (icon: Icons.account_tree_outlined, label: 'Wall Chart', path: '/wall-chart'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _destinations.indexWhere((d) => d.path == location).clamp(0, 4);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => context.go(_destinations[i].path),
        destinations: [
          for (final d in _destinations)
            NavigationDestination(icon: Icon(d.icon), label: d.label),
        ],
      ),
    );
  }
}
