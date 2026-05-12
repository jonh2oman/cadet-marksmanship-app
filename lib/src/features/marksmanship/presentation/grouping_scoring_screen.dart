import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../application/relay_controller.dart';

class GroupingScoringScreen extends StatefulWidget {
  final String? competitorName;
  final String? relayId;
  final int? laneNumber;

  const GroupingScoringScreen({
    super.key, 
    this.competitorName,
    this.relayId,
    this.laneNumber,
  });

  @override
  State<GroupingScoringScreen> createState() => _GroupingScoringScreenState();
}

class _GroupingScoringScreenState extends State<GroupingScoringScreen> {
  final _diag1Controller = TextEditingController();
  final _diag2Controller = TextEditingController();
  double? _diag1;
  double? _diag2;

  String _getClassification(double cm) {
    if (cm <= 1.5) return 'DISTINGUISHED';
    if (cm <= 2.0) return 'EXPERT';
    if (cm <= 2.5) return 'FIRST CLASS';
    if (cm <= 3.0) return 'MARKSMAN';
    return 'BELOW CLASSIFICATION';
  }

  Color _getStatusColor(String classification) {
    switch (classification) {
      case 'DISTINGUISHED': return const Color(0xFFFACC15); // Gold
      case 'EXPERT':        return const Color(0xFFE2E8F0); // Silver/White
      case 'FIRST CLASS':   return const Color(0xFFFB923C); // Bronze/Orange
      case 'MARKSMAN':      return const Color(0xFF38BDF8); // Blue
      default:              return Colors.white24;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveCm = (_diag1 != null && _diag2 != null) 
        ? (_diag1! > _diag2! ? _diag1! : _diag2!) 
        : null;
    
    final classification = effectiveCm != null ? _getClassification(effectiveCm) : null;
    final statusColor = classification != null ? _getStatusColor(classification) : Colors.white10;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GROUPING CALCULATOR'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (widget.competitorName != null) ...[
              Text(
                widget.competitorName!.toUpperCase(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              const SizedBox(height: 4),
              const Text('RECORDING SCORES', style: TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 2)),
              const SizedBox(height: 32),
            ],
            Row(
              children: [
                Expanded(
                  child: _MeasurementInput(
                    label: 'DIAGRAM 1 (CM)',
                    controller: _diag1Controller,
                    onChanged: (v) => setState(() => _diag1 = double.tryParse(v)),
                    isActive: _diag1 != null && effectiveCm == _diag1,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _MeasurementInput(
                    label: 'DIAGRAM 2 (CM)',
                    controller: _diag2Controller,
                    onChanged: (v) => setState(() => _diag2 = double.tryParse(v)),
                    isActive: _diag2 != null && effectiveCm == _diag2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            if (classification != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'EFFECTIVE GROUPING',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor.withOpacity(0.5), letterSpacing: 2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${effectiveCm!.toStringAsFixed(2)} cm',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: statusColor.withOpacity(0.8), fontFamily: 'monospace'),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: Colors.white10),
                    ),
                    Text(
                      'CLASSIFICATION',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor.withOpacity(0.8), letterSpacing: 2),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      classification,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: statusColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const _RuleTip(
                text: 'Per CCOBCS rules, the classification is determined by the LARGER of the two groupings (the lower classification).',
              ),
              if (widget.relayId != null && widget.laneNumber != null) ...[
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: Consumer(
                    builder: (context, ref, child) => ElevatedButton.icon(
                      onPressed: () {
                        ref.read(relayProvider.notifier).saveGroupingScore(
                          widget.relayId!,
                          widget.laneNumber!,
                          effectiveCm!,
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
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _MeasurementInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isActive;

  const _MeasurementInput({
    required this.label,
    required this.controller,
    required this.onChanged,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isActive ? const Color(0xFFFACC15) : Colors.white38,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            color: isActive ? Colors.white : Colors.white30,
          ),
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: const TextStyle(color: Colors.white10),
            filled: true,
            fillColor: const Color(0xFF1E293B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: isActive ? const Color(0xFFFACC15).withOpacity(0.5) : Colors.transparent),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _RuleTip extends StatelessWidget {
  final String text;
  const _RuleTip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.info, size: 16, color: Color(0xFF38BDF8)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white54, fontSize: 11, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
