import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

class RangeCommandsScreen extends StatelessWidget {
  const RangeCommandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RANGE COMMANDS'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _CommandSection(
            title: 'FAMILIARIZATION & CLASSIFICATION',
            commands: [
              '“Cover off your firing point”',
              '“Competitors to the firing point”',
              '“Place your equipment down and stand back”',
              '“Adopt the prone position”',
              '“Post targets – you have two (2) minutes”',
              '“Distribute pellets”',
              '“Adopt the prone position – your three (3) minute preparation period starts now”',
              '“Load and commence firing – your thirty (30) minutes firing period begins now”',
            ],
          ),
          SizedBox(height: 24),
          _CommandSection(
            title: 'MARKSMANSHIP COMPETITION',
            commands: [
              '“Relay #__, ten (10) metres, five (5) rounds, Grouping, On Your Own Time”',
              '“Relay, load, commence firing”',
              '“Relay, cease fire” (as required)',
              '“Relay, resume fire” (as required)',
              '“Relay, unload and prepare for inspection”',
              '“Relay, Stand up”',
            ],
          ),
          SizedBox(height: 24),
          _CommandSection(
            title: 'BIATHLON COMMANDS',
            commands: [
              '“Range is open - for zeroing or competition”',
              '“Range is closed”',
              '“You have ten (10) minutes remaining”',
              '“You have five (5) minutes remaining”',
              '“You have one (1) minute remaining”',
              '“Cease fire – your time has expired. Unload and prepare for inspection”',
              '“Remove your equipment from the firing point”',
              '“Exit the range”',
            ],
          ),
        ],
      ),
    );
  }
}

class _CommandSection extends StatelessWidget {
  final String title;
  final List<String> commands;

  const _CommandSection({required this.title, required this.commands});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFACC15),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        ...commands.map((cmd) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Text(
            cmd,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
          ),
        )),
      ],
    );
  }
}
