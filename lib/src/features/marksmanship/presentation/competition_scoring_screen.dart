import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../application/relay_controller.dart';

class CompetitionScoringScreen extends StatefulWidget {
  final String? competitorName;
  final String? relayId;
  final int? laneNumber;

  const CompetitionScoringScreen({
    super.key, 
    this.competitorName,
    this.relayId,
    this.laneNumber,
  });

  @override
  State<CompetitionScoringScreen> createState() => _CompetitionScoringScreenState();
}

class _CompetitionScoringScreenState extends State<CompetitionScoringScreen> {
  final List<TextEditingController> _controllers = List.generate(10, (_) => TextEditingController());
  final List<bool> _innerTens = List.generate(10, (_) => false);

  int get _totalScore {
    return _controllers.fold(0, (sum, ctrl) {
      final val = int.tryParse(ctrl.text) ?? 0;
      return sum + (val > 10 ? 10 : val);
    });
  }

  int get _totalInnerTens => _innerTens.where((it) => it).length;

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('COMPETITION SCORING'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.competitorName != null) ...[
                  Text(
                    widget.competitorName!.toUpperCase(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TOTAL SCORE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54)),
                          Text('$_totalScore / 100', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('INNER TENS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54)),
                        Text('$_totalInnerTens', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFFACC15))),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 10,
              itemBuilder: (ctx, i) => _ShotInputRow(
                index: i + 1,
                controller: _controllers[i],
                isInnerTen: _innerTens[i],
                onScoreChanged: (v) => setState(() {}),
                onInnerTenChanged: (v) => setState(() => _innerTens[i] = v),
              ),
            ),
          ),
          if (widget.relayId != null && widget.laneNumber != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Consumer(
                builder: (context, ref, child) => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(relayProvider.notifier).saveCompetitionScore(
                        widget.relayId!,
                        widget.laneNumber!,
                        _totalScore,
                        _totalInnerTens,
                      );
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(LucideIcons.save),
                    label: const Text('SAVE TO RELAY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ShotInputRow extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final bool isInnerTen;
  final ValueChanged<String> onScoreChanged;
  final ValueChanged<bool> onInnerTenChanged;

  const _ShotInputRow({
    required this.index,
    required this.controller,
    required this.isInnerTen,
    required this.onScoreChanged,
    required this.onInnerTenChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.white10,
            child: Text('$index', style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ),
          const SizedBox(width: 16),
          const Text('SCORE:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54)),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: '-',
                border: InputBorder.none,
              ),
              onChanged: onScoreChanged,
            ),
          ),
          const Spacer(),
          const Text('INNER TEN?', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38)),
          Switch(
            value: isInnerTen,
            onChanged: onInnerTenChanged,
            activeColor: const Color(0xFFFACC15),
          ),
        ],
      ),
    );
  }
}
