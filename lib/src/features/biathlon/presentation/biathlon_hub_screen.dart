import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../coach/application/biathlon_coach_controller.dart';
import '../coach/domain/biathlon_coach_state.dart';

class BiathlonHubScreen extends ConsumerWidget {
  const BiathlonHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachState = ref.watch(biathlonCoachProvider);
    final notifier = ref.read(biathlonCoachProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BIATHLON HUB'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepHeader(number: '1', title: 'SELECT DISCIPLINE MODE'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<BiathlonMode>(
                segments: const [
                  ButtonSegment(value: BiathlonMode.ski, label: Text('SKIING'), icon: Icon(LucideIcons.snowflake)),
                  ButtonSegment(value: BiathlonMode.run, label: Text('RUNNING'), icon: Icon(LucideIcons.footprints)),
                ],
                selected: {coachState.mode},
                onSelectionChanged: (set) => notifier.setMode(set.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: coachState.mode == BiathlonMode.ski ? const Color(0xFF38BDF8) : const Color(0xFFFACC15),
                  selectedForegroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 40),
            _StepHeader(number: '2', title: 'START SESSION'),
            const SizedBox(height: 16),
            _HubTile(
              title: 'COACH A RACE!',
              subtitle: 'Precision Timer & Shooting Log',
              icon: LucideIcons.timer,
              color: const Color(0xFF10B981),
              onTap: () => context.push('/biathlon/coach'),
            ),
            const Spacer(),
            const Divider(color: Colors.white10),
            const SizedBox(height: 16),
            _HubTile(
              title: 'RULES & REFS',
              subtitle: 'Official CCOBCS Rulebook',
              icon: LucideIcons.bookOpen,
              color: Colors.white54,
              compact: true,
              onTap: () => context.push('/biathlon/rules'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final String number;
  final String title;
  const _StepHeader({required this.number, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(color: Color(0xFF38BDF8), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(number, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white70)),
      ],
    );
  }
}

class _HubTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool compact;

  const _HubTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1E293B),
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(compact ? 16 : 24),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(compact ? 12 : 16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: compact ? 24 : 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(color: color, fontSize: compact ? 16 : 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }
}
