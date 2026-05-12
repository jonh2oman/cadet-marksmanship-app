import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/glass_container.dart';

class ScoringHubScreen extends StatelessWidget {
  const ScoringHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SCORING HUB'),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _ScoringTile(
              title: 'GROUPING TARGET',
              subtitle: 'Calculate size in millimetres (mm)',
              icon: LucideIcons.target,
              color: const Color(0xFFFACC15),
              onTap: () => context.push('/marksmanship/run-a-range/scoring/grouping'),
            ),
            const SizedBox(height: 20),
            _ScoringTile(
              title: 'COMPETITION TARGET',
              subtitle: 'Calculate total points (1-10)',
              icon: LucideIcons.target,
              color: const Color(0xFF38BDF8),
              onTap: () => context.push('/marksmanship/run-a-range/scoring/competition'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoringTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ScoringTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      opacity: 0.05,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title, 
                      style: TextStyle(
                        color: color, 
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle, 
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight),
            ],
          ),
        ),
      ),
    );
  }
}
