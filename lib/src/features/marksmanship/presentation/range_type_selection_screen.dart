import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

class RangeTypeSelectionScreen extends StatelessWidget {
  const RangeTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RUN A RANGE'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SELECT RANGE TYPE',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 2),
            ),
            const SizedBox(height: 24),
            _SelectionCard(
              title: 'INDIVIDUAL RANGE',
              description: 'Assign individual cadets to lanes and track scores independently.',
              icon: LucideIcons.user,
              color: const Color(0xFF38BDF8),
              onTap: () => context.push('/marksmanship/run-a-range/competition/relays?type=individual'),
            ),
            const SizedBox(height: 20),
            _SelectionCard(
              title: 'TEAM COMPETITION',
              description: 'Manage unit teams (5 members, min. 2 juniors) and assign them to relays.',
              icon: LucideIcons.users,
              color: const Color(0xFF10B981),
              onTap: () => context.push('/marksmanship/run-a-range/competition/relays?type=team'),
            ),
            const Spacer(),
            const Divider(color: Colors.white10),
            const SizedBox(height: 16),
            ListTile(
              onTap: () => context.push('/marksmanship/run-a-range/teams'),
              leading: const Icon(LucideIcons.database, color: Colors.white38),
              title: const Text('TEAM REGISTRY'),
              subtitle: const Text('Manage your roster of units and competitors'),
              trailing: const Icon(LucideIcons.chevronRight, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1E293B),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(description, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
