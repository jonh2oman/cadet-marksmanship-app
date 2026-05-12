import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

class RunARangeHubScreen extends StatelessWidget {
  const RunARangeHubScreen({super.key});

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
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _SubHubTile(
              title: 'RANGE COMMANDS',
              subtitle: 'Official verbal command reference',
              icon: LucideIcons.megaphone,
              color: const Color(0xFFFACC15),
              onTap: () => context.push('/marksmanship/run-a-range/commands'),
            ),
            const SizedBox(height: 16),
            _SubHubTile(
              title: 'RUN A COMPETITION',
              subtitle: 'Track relays, targets & athletes',
              icon: LucideIcons.clipboardList,
              color: const Color(0xFF10B981),
              onTap: () => context.push('/marksmanship/run-a-range/competition'),
            ),
            const SizedBox(height: 16),
            _SubHubTile(
              title: 'SCORING',
              subtitle: 'Grouping & Competition targets',
              icon: LucideIcons.target,
              color: const Color(0xFF38BDF8),
              onTap: () => context.push('/marksmanship/run-a-range/scoring'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubHubTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SubHubTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1E293B),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white30, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, color: Colors.white10, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
