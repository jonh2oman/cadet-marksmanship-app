import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../application/relay_controller.dart';
import '../application/team_controller.dart';
import '../domain/relay_state.dart';

class RelayDetailScreen extends ConsumerWidget {
  final String relayId;
  const RelayDetailScreen({super.key, required this.relayId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relays = ref.watch(relayProvider);
    final relay = relays.firstWhere((r) => r.id == relayId, orElse: () => Relay(id: '', number: 0, firingPoints: []));

    if (relay.id.isEmpty) {
      return const Scaffold(body: Center(child: Text('Relay not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('RELAY ${relay.number}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(LucideIcons.power, color: relay.isActive ? const Color(0xFF10B981) : Colors.white38),
            onPressed: () => ref.read(relayProvider.notifier).toggleRelayActive(relay.id),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2, color: Color(0xFFEF4444)),
            onPressed: () {
              ref.read(relayProvider.notifier).removeRelay(relay.id);
              context.pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (relay.relayType == 'team') _TeamSelectionHeader(relay: relay),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: relay.firingPoints.length,
              itemBuilder: (ctx, i) => _FiringPointCard(
                point: relay.firingPoints[i],
                relayId: relayId,
                teamId: relay.teamId,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamSelectionHeader extends ConsumerWidget {
  final Relay relay;
  const _TeamSelectionHeader({required this.relay});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teams = ref.watch(teamProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DropdownButtonFormField<String>(
        value: relay.teamId,
        decoration: const InputDecoration(labelText: 'Assign Team', border: OutlineInputBorder()),
        items: teams.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
        onChanged: (id) {
          if (id != null) ref.read(relayProvider.notifier).updateRelay(relay.copyWith(teamId: id));
        },
      ),
    );
  }
}

class _FiringPointCard extends ConsumerWidget {
  final FiringPoint point;
  final String relayId;
  final String? teamId;

  const _FiringPointCard({
    required this.point,
    required this.relayId,
    this.teamId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: point.competitorName != null ? const Color(0xFF38BDF8).withOpacity(0.3) : Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: point.competitorName != null ? const Color(0xFF38BDF8) : Colors.white10,
          child: Text('${point.laneNumber}', style: TextStyle(color: point.competitorName != null ? Colors.black : Colors.white38, fontWeight: FontWeight.bold)),
        ),
        title: Text(
          '${point.competitorName ?? 'EMPTY LANE'}${point.teamName != null ? ' (${point.teamName})' : ''}',
          style: TextStyle(
            color: point.competitorName != null ? Colors.white : Colors.white24,
            fontWeight: point.competitorName != null ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              point.targetType == TargetType.grouping ? 'GROUPING' : 'COMPETITION',
              style: const TextStyle(fontSize: 10, letterSpacing: 1),
            ),
            if (point.score != null || point.groupingMm != null) ...[
              const SizedBox(height: 4),
              if (point.targetType == TargetType.competition)
                Text(
                  'RESULT: ${point.score}/100 (${point.innerTens} IT)',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                )
              else
                Text(
                  'RESULT: ${_getGroupingClassification(point.groupingMm!)}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getGroupingColor(point.groupingMm!)),
                ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (point.competitorName != null)
              TextButton(
                onPressed: () {
                  final type = point.targetType == TargetType.grouping ? 'grouping' : 'competition';
                  final query = 'name=${Uri.encodeComponent(point.competitorName!)}&relayId=${relayId}&lane=${point.laneNumber}';
                  context.push('/marksmanship/run-a-range/scoring/$type?$query');
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF10B981),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                child: const Text('SCORE'),
              ),
            const SizedBox(width: 8),
            const Icon(LucideIcons.edit3, size: 18, color: Colors.white24),
          ],
        ),
        onTap: () => _showEditLaneDialog(context, ref),
      ),
    );
  }

  String _getGroupingClassification(double cm) {
    if (cm <= 1.5) return 'DISTINGUISHED';
    if (cm <= 2.0) return 'EXPERT';
    if (cm <= 2.5) return 'FIRST CLASS';
    if (cm <= 3.0) return 'MARKSMAN';
    return 'BELOW CLASSIFICATION';
  }

  Color _getGroupingColor(double cm) {
    final classification = _getGroupingClassification(cm);
    switch (classification) {
      case 'DISTINGUISHED': return const Color(0xFFFACC15);
      case 'EXPERT':        return const Color(0xFFE2E8F0);
      case 'FIRST CLASS':   return const Color(0xFFFB923C);
      case 'MARKSMAN':      return const Color(0xFF38BDF8);
      default:              return Colors.white24;
    }
  }

  void _showEditLaneDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController(text: point.competitorName);
    final teamController = TextEditingController(text: point.teamName);
    TargetType targetType = point.targetType;

    // Get team members if teamId is present
    final teams = ref.read(teamProvider);
    final team = teamId != null ? teams.cast<Team?>().firstWhere((t) => t?.id == teamId, orElse: () => null) : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: Text('Lane ${point.laneNumber} Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (team != null) ...[
                const Text('Pick Team Member', style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 8),
                DropdownButtonFormField<Competitor>(
                  value: team.members.any((m) => m.name == point.competitorName) 
                      ? team.members.firstWhere((m) => m.name == point.competitorName) 
                      : null,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: team.members.map((m) => DropdownMenuItem(value: m, child: Text('${m.rank} ${m.name}'))).toList(),
                  onChanged: (m) {
                    if (m != null) {
                      nameController.text = m.name;
                      teamController.text = team.name;
                    }
                  },
                ),
              ] else ...[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Competitor Name'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: teamController,
                  decoration: const InputDecoration(labelText: 'Team / Unit Name'),
                  textCapitalization: TextCapitalization.characters,
                ),
              ],
              const SizedBox(height: 20),
              const Text('Target Type', style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 8),
              SegmentedButton<TargetType>(
                segments: const [
                  ButtonSegment(value: TargetType.grouping, label: Text('GROUPING')),
                  ButtonSegment(value: TargetType.competition, label: Text('COMP')),
                ],
                selected: {targetType},
                onSelectionChanged: (set) => setState(() => targetType = set.first),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                ref.read(relayProvider.notifier).updateFiringPoint(
                  relayId,
                  point.laneNumber,
                  point.copyWith(
                    competitorName: nameController.text.isEmpty ? null : nameController.text,
                    teamName: teamController.text.isEmpty ? null : teamController.text,
                    targetType: targetType,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }
}
