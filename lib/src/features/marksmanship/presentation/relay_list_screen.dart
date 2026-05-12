import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../application/relay_controller.dart';
import '../domain/relay_state.dart';

class RelayListScreen extends ConsumerWidget {
  const RelayListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = GoRouterState.of(context).uri.queryParameters['type'] ?? 'individual';
    final allRelays = ref.watch(relayProvider);
    final relays = allRelays.where((r) => r.relayType == type).toList();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${type.toUpperCase()} RELAYS'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trophy),
            tooltip: 'Leaderboard',
            onPressed: () => context.push('/marksmanship/run-a-range/scoring/results'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: relays.isEmpty
          ? _EmptyRelays(onAdd: () => _showAddRelayDialog(context, ref, type))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: relays.length,
              itemBuilder: (ctx, i) => _RelayCard(relay: relays[i]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRelayDialog(context, ref, type),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.black,
        icon: const Icon(LucideIcons.plus),
        label: const Text('NEW RELAY'),
      ),
    );
  }

  void _showAddRelayDialog(BuildContext context, WidgetRef ref, String type) {
    int lanes = 10;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Add New Relay'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How many firing points (lanes)?', style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: lanes > 1 ? () => setState(() => lanes--) : null,
                    icon: const Icon(LucideIcons.minusCircle, color: Color(0xFF38BDF8)),
                  ),
                  Text('$lanes', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: lanes < 20 ? () => setState(() => lanes++) : null,
                    icon: const Icon(LucideIcons.plusCircle, color: Color(0xFF38BDF8)),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                ref.read(relayProvider.notifier).addRelay(lanes, type);
                Navigator.pop(context);
              },
              child: const Text('CREATE'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RelayCard extends StatelessWidget {
  final Relay relay;
  const _RelayCard({required this.relay});

  @override
  Widget build(BuildContext context) {
    final filledLanes = relay.firingPoints.where((p) => p.competitorName != null).length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: relay.isActive ? const Color(0xFF10B981).withOpacity(0.5) : Colors.white10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/marksmanship/run-a-range/competition/relays/relay/${relay.id}'),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: relay.isActive ? const Color(0xFF10B981).withOpacity(0.1) : Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text('${relay.number}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: relay.isActive ? const Color(0xFF10B981) : Colors.white70)),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RELAY ${relay.number}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      const SizedBox(height: 4),
                      Text(
                        '$filledLanes / ${relay.firingPoints.length} Lanes Filled',
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (relay.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Text('ACTIVE', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                const SizedBox(width: 12),
                const Icon(LucideIcons.chevronRight, color: Colors.white10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyRelays extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyRelays({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.layers, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          const Text('No relays created yet', style: TextStyle(color: Colors.white38)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('CREATE FIRST RELAY'),
          ),
        ],
      ),
    );
  }
}
