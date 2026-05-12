import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../application/team_controller.dart';

class TeamEditorScreen extends ConsumerStatefulWidget {
  final String teamId;
  const TeamEditorScreen({super.key, required this.teamId});

  @override
  ConsumerState<TeamEditorScreen> createState() => _TeamEditorScreenState();
}

class _TeamEditorScreenState extends ConsumerState<TeamEditorScreen> {
  final _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    final teams = ref.watch(teamProvider);
    final team = teams.cast<Team?>().firstWhere((t) => t?.id == widget.teamId, orElse: () => null);

    if (team == null) {
      return const Scaffold(body: Center(child: Text('Team not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(team.name),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _ValidationHeader(team: team),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: team.members.length,
              itemBuilder: (ctx, i) => _MemberCard(
                member: team.members[i],
                onDelete: () => _removeMember(team, i),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: team.members.length < 5
          ? FloatingActionButton.extended(
              onPressed: () => _showAddMemberDialog(context, team),
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.black,
              icon: const Icon(LucideIcons.userPlus),
              label: const Text('ADD MEMBER'),
            )
          : null,
    );
  }

  void _removeMember(Team team, int index) {
    final updatedMembers = List<Competitor>.from(team.members)..removeAt(index);
    ref.read(teamProvider.notifier).updateTeam(team.copyWith(members: updatedMembers));
  }

  void _showAddMemberDialog(BuildContext context, Team team) {
    final nameController = TextEditingController();
    final rankController = TextEditingController();
    DateTime? selectedDob;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Add Team Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: rankController,
                decoration: const InputDecoration(labelText: 'Rank'),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date of Birth', style: TextStyle(fontSize: 12, color: Colors.white54)),
                subtitle: Text(
                  selectedDob == null ? 'Not Selected' : DateFormat('MMM dd, yyyy').format(selectedDob!),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                trailing: const Icon(LucideIcons.calendar),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(const Duration(days: 365 * 12)),
                    firstDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => selectedDob = date);
                },
              ),
              if (selectedDob != null) ...[
                const SizedBox(height: 8),
                _AgePreview(dob: selectedDob!),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: selectedDob == null || nameController.text.isEmpty
                  ? null
                  : () {
                      final member = Competitor(
                        id: _uuid.v4(),
                        name: nameController.text,
                        rank: rankController.text,
                        dob: selectedDob!,
                      );
                      final updatedMembers = [...team.members, member];
                      ref.read(teamProvider.notifier).updateTeam(team.copyWith(members: updatedMembers));
                      Navigator.pop(context);
                    },
              child: const Text('ADD'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgePreview extends StatelessWidget {
  final DateTime dob;
  const _AgePreview({required this.dob});

  @override
  Widget build(BuildContext context) {
    // Temporary competitor to calculate age/level
    final temp = Competitor(id: '', name: '', rank: '', dob: dob);
    final isJunior = temp.level == CompetitorLevel.junior;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isJunior ? Colors.blue.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(isJunior ? LucideIcons.baby : LucideIcons.user, size: 16, color: isJunior ? Colors.blue : Colors.orange),
          const SizedBox(width: 12),
          Text(
            'Age: ${temp.age} • ${isJunior ? 'JUNIOR' : 'SENIOR'}',
            style: TextStyle(fontWeight: FontWeight.bold, color: isJunior ? Colors.blue : Colors.orange, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ValidationHeader extends StatelessWidget {
  final Team team;
  const _ValidationHeader({required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: team.isValid ? const Color(0xFF10B981).withOpacity(0.1) : Colors.red.withOpacity(0.1),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                team.isValid ? LucideIcons.checkCircle2 : LucideIcons.alertTriangle,
                color: team.isValid ? const Color(0xFF10B981) : Colors.redAccent,
              ),
              const SizedBox(width: 12),
              Text(
                team.isValid ? 'TEAM VALID PER RULEBOOK' : 'TEAM INVALID',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: team.isValid ? const Color(0xFF10B981) : Colors.redAccent,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Requirement: 5 Members & Min. 2 Juniors\nCurrent: ${team.members.length}/5 Members, ${team.juniorCount} Juniors',
            style: TextStyle(fontSize: 11, color: team.isValid ? Colors.white70 : Colors.redAccent.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final Competitor member;
  final VoidCallback onDelete;

  const _MemberCard({required this.member, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isJunior = member.level == CompetitorLevel.junior;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(member.rank, style: const TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
              Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isJunior ? Colors.blue.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isJunior ? 'JUNIOR' : 'SENIOR',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isJunior ? Colors.blue : Colors.orange),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.white10),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
