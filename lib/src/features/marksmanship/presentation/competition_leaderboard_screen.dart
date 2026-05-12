import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../application/relay_controller.dart';
import '../domain/relay_state.dart';

class CompetitionLeaderboardScreen extends StatelessWidget {
  const CompetitionLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('COMPETITION RESULTS'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.pop(),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'INDIVIDUAL'),
              Tab(text: 'TEAM / UNIT'),
            ],
            indicatorColor: Color(0xFF10B981),
            labelColor: Color(0xFF10B981),
            unselectedLabelColor: Colors.white38,
          ),
        ),
        body: const TabBarView(
          children: [
            _IndividualLeaderboard(),
            _TeamLeaderboard(),
          ],
        ),
      ),
    );
  }
}

class _IndividualLeaderboard extends ConsumerWidget {
  const _IndividualLeaderboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relays = ref.watch(relayProvider);
    final allScores = <FiringPoint>[];
    
    for (var relay in relays) {
      for (var point in relay.firingPoints) {
        if (point.competitorName != null && point.score != null) {
          allScores.add(point);
        }
      }
    }

    // Sort by score (desc), then inner tens (desc)
    allScores.sort((a, b) {
      if (b.score! != a.score!) return b.score!.compareTo(a.score!);
      return (b.innerTens ?? 0).compareTo(a.innerTens ?? 0);
    });

    if (allScores.isEmpty) return const _EmptyLeaderboard(text: 'No competition scores recorded yet.');

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: allScores.length,
      itemBuilder: (ctx, i) => _RankCard(
        rank: i + 1,
        name: allScores[i].competitorName!,
        team: allScores[i].teamName,
        score: allScores[i].score!,
        it: allScores[i].innerTens ?? 0,
      ),
    );
  }
}

class _TeamLeaderboard extends ConsumerWidget {
  const _TeamLeaderboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relays = ref.watch(relayProvider);
    final teamData = <String, List<FiringPoint>>{};
    
    for (var relay in relays) {
      for (var point in relay.firingPoints) {
        if (point.teamName != null && point.score != null) {
          teamData.putIfAbsent(point.teamName!, () => []).add(point);
        }
      }
    }

    final teamResults = teamData.entries.map((e) {
      final scores = e.value.map((p) => p.score!).toList();
      scores.sort((a, b) => b.compareTo(a));
      // Standard rule: Top 4 scores count
      final top4 = scores.take(4).toList();
      final total = top4.fold(0, (sum, s) => sum + s);
      final it = e.value.fold(0, (sum, p) => sum + (p.innerTens ?? 0));
      return _TeamResult(
        name: e.key,
        total: total,
        it: it,
        memberCount: e.value.length,
      );
    }).toList();

    teamResults.sort((a, b) {
      if (b.total != a.total) return b.total.compareTo(a.total);
      return b.it.compareTo(a.it);
    });

    if (teamResults.isEmpty) return const _EmptyLeaderboard(text: 'No team scores recorded yet.');

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: teamResults.length,
      itemBuilder: (ctx, i) => _TeamRankCard(
        rank: i + 1,
        team: teamResults[i],
      ),
    );
  }
}

class _TeamResult {
  final String name;
  final int total;
  final int it;
  final int memberCount;
  _TeamResult({required this.name, required this.total, required this.it, required this.memberCount});
}

class _RankCard extends StatelessWidget {
  final int rank;
  final String name;
  final String? team;
  final int score;
  final int it;

  const _RankCard({required this.rank, required this.name, this.team, required this.score, required this.it});

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    final color = rank == 1 ? const Color(0xFFFACC15) : (rank == 2 ? const Color(0xFFE2E8F0) : (rank == 3 ? const Color(0xFFFB923C) : Colors.white24));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isTop3 ? color.withOpacity(0.3) : Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Text('$rank', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isTop3 ? color : Colors.white38)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (team != null) Text(team!, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$score', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isTop3 ? color : const Color(0xFF10B981))),
              Text('$it IT', style: const TextStyle(fontSize: 10, color: Colors.white38)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeamRankCard extends StatelessWidget {
  final int rank;
  final _TeamResult team;

  const _TeamRankCard({required this.rank, required this.team});

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    final color = rank == 1 ? const Color(0xFFFACC15) : (rank == 2 ? const Color(0xFFE2E8F0) : (rank == 3 ? const Color(0xFFFB923C) : Colors.white24));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isTop3 ? color.withOpacity(0.3) : Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Text('$rank', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isTop3 ? color : Colors.white38)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(team.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${team.memberCount} Members (Top 4 Count)', style: const TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${team.total}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isTop3 ? color : const Color(0xFF10B981))),
              Text('${team.it} Total IT', style: const TextStyle(fontSize: 10, color: Colors.white38)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyLeaderboard extends StatelessWidget {
  final String text;
  const _EmptyLeaderboard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.trophy, size: 48, color: Colors.white10),
          const SizedBox(height: 16),
          Text(text, style: const TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }
}
