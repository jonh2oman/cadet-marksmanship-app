import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/discipline/presentation/discipline_dashboard.dart';
import '../features/biathlon/presentation/biathlon_hub_screen.dart';
import '../features/biathlon/coach/presentation/biathlon_coach_screen.dart';
import '../features/marksmanship/presentation/marksmanship_hub_screen.dart';
import '../features/marksmanship/presentation/run_a_range_hub_screen.dart';
import '../features/marksmanship/presentation/range_commands_screen.dart';
import '../features/marksmanship/presentation/scoring_hub_screen.dart';
import '../features/marksmanship/presentation/grouping_scoring_screen.dart';
import '../features/marksmanship/presentation/competition_scoring_screen.dart';
import '../features/marksmanship/presentation/relay_list_screen.dart';
import '../features/marksmanship/presentation/relay_detail_screen.dart';
import '../features/marksmanship/presentation/competition_leaderboard_screen.dart';
import '../features/marksmanship/presentation/range_type_selection_screen.dart';
import '../features/marksmanship/presentation/team_registry_screen.dart';
import '../features/marksmanship/presentation/team_editor_screen.dart';
import '../features/rulebook/presentation/rulebook_screen.dart';
import '../features/help/presentation/help_hub_screen.dart';
import '../features/help/presentation/help_article_screen.dart';
import '../shared/widgets/help_button.dart';
import '../data/biathlon_rules.dart';
import '../data/marksmanship_rules.dart';
import '../theme/app_theme.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // ShellRoute to display GlobalHelpButton on every screen
      ShellRoute(
        builder: (context, state, child) {
          return Stack(
            children: [
              child,
              const GlobalHelpButton(),
            ],
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/marksmanship',
            builder: (context, state) => const MarksmanshipHubScreen(),
            routes: [
              GoRoute(
                path: 'rules',
                builder: (context, state) => const RulebookScreen(
                  title: 'Marksmanship Rules',
                  rules: marksmanshipRules,
                ),
              ),
              GoRoute(
                path: 'run-a-range',
                builder: (context, state) => const RunARangeHubScreen(),
                routes: [
                  GoRoute(
                    path: 'commands',
                    builder: (context, state) => const RangeCommandsScreen(),
                  ),
                  GoRoute(
                    path: 'teams',
                    builder: (context, state) => const TeamRegistryScreen(),
                    routes: [
                      GoRoute(
                        path: ':teamId',
                        builder: (context, state) => TeamEditorScreen(
                          teamId: state.pathParameters['teamId']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'competition',
                    builder: (context, state) => const RangeTypeSelectionScreen(),
                    routes: [
                      GoRoute(
                        path: 'relays',
                        builder: (context, state) => const RelayListScreen(),
                        routes: [
                          GoRoute(
                            path: 'relay/:id',
                            builder: (context, state) => RelayDetailScreen(
                              relayId: state.pathParameters['id']!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'scoring',
                    builder: (context, state) => const ScoringHubScreen(),
                    routes: [
                      GoRoute(
                        path: 'grouping',
                        builder: (context, state) => GroupingScoringScreen(
                          competitorName: state.uri.queryParameters['name'],
                          relayId: state.uri.queryParameters['relayId'],
                          laneNumber: int.tryParse(state.uri.queryParameters['lane'] ?? ''),
                        ),
                      ),
                      GoRoute(
                        path: 'competition',
                        builder: (context, state) => CompetitionScoringScreen(
                          competitorName: state.uri.queryParameters['name'],
                          relayId: state.uri.queryParameters['relayId'],
                          laneNumber: int.tryParse(state.uri.queryParameters['lane'] ?? ''),
                        ),
                      ),
                      GoRoute(
                        path: 'results',
                        builder: (context, state) => const CompetitionLeaderboardScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/biathlon',
            builder: (context, state) => const BiathlonHubScreen(),
            routes: [
              GoRoute(
                path: 'rules',
                builder: (context, state) => const RulebookScreen(
                  title: 'Biathlon Rules',
                  rules: biathlonRules,
                ),
              ),
              GoRoute(
                path: 'coach',
                builder: (context, state) => const BiathlonCoachScreen(),
              ),
            ],
          ),
        ],
      ),
      // Help routes are outside the shell because they don't need a help button
      // (or we can include them if we want help for the help center)
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpHubScreen(),
        routes: [
          GoRoute(
            path: ':articleId',
            builder: (context, state) => HelpArticleScreen(
              articleId: state.pathParameters['articleId']!,
            ),
          ),
        ],
      ),
    ],
  );
});
