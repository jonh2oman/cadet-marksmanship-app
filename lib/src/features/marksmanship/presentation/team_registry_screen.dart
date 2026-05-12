import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../application/team_controller.dart';

class TeamRegistryScreen extends ConsumerWidget {
  const TeamRegistryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teams = ref.watch(teamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TEAM REGISTRY'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: teams.isEmpty
          ? _EmptyTeams(onAdd: () => _showAddTeamDialog(context, ref))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: teams.length,
              itemBuilder: (ctx, i) => _TeamCard(team: teams[i]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTeamDialog(context, ref),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.black,
        icon: const Icon(LucideIcons.plus),
        label: const Text('NEW TEAM'),
      ),
    );
  }

  void _showAddTeamDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Register New Team'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Team / Unit Name'),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(teamProvider.notifier).addTeam(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('CREATE'),
          ),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final Team team;
  const _TeamCard({required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: team.isValid ? const Color(0xFF10B981).withOpacity(0.3) : Colors.white10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTeamEditor(context),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _StatusBadge(isValid: team.isValid),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(team.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        '${team.members.length}/5 Members • ${team.juniorCount} Juniors',
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(LucideIcons.chevronRight, color: Colors.white10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTeamEditor(BuildContext context) {
    // Navigate to team editor (to be implemented)
    context.push('/marksmanship/run-a-range/teams/${team.id}');
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isValid;
  const _StatusBadge({required this.isValid});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isValid ? const Color(0xFF10B981).withOpacity(0.1) : Colors.red.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isValid ? LucideIcons.checkCircle2 : LucideIcons.alertCircle,
        color: isValid ? const Color(0xFF10B981) : Colors.redAccent,
        size: 24,
      ),
    );
  }
}

class _EmptyTeams extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyTeams({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.users, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          const Text('No teams registered yet', style: TextStyle(color: Colors.white38)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('REGISTER FIRST TEAM'),
          ),
        ],
      ),
    );
  }
}
