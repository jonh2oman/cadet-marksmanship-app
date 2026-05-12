import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ScoringScreen extends StatefulWidget {
  final String title;

  const ScoringScreen({super.key, required this.title});

  @override
  State<ScoringScreen> createState() => _ScoringScreenState();
}

class _ScoringScreenState extends State<ScoringScreen> {
  final TextEditingController _grouping1Controller = TextEditingController();
  final TextEditingController _grouping2Controller = TextEditingController();
  String _classification1 = '';
  String _classification2 = '';
  String _awardedClassification = '';

  // Returns an integer rank: higher = better level
  int _rankOf(String level) {
    switch (level) {
      case 'Distinguished Marksman':
        return 3;
      case 'First Class':
        return 2;
      case 'Marksman':
        return 1;
      default:
        return 0;
    }
  }

  String _classifyGrouping(double grouping) {
    if (grouping <= 1.5) return 'Distinguished Marksman';
    if (grouping <= 2.5) return 'First Class';
    if (grouping <= 4.0) return 'Marksman';
    return 'Unclassified';
  }

  void _calculateClassification() {
    final double? g1 = double.tryParse(_grouping1Controller.text);
    final double? g2 = double.tryParse(_grouping2Controller.text);

    if (g1 == null || g2 == null) {
      setState(() {
        _classification1 = '';
        _classification2 = '';
        _awardedClassification = 'Please enter valid values for both diagrams.';
      });
      return;
    }

    final c1 = _classifyGrouping(g1);
    final c2 = _classifyGrouping(g2);
    // The lower of the two is awarded
    final awarded = _rankOf(c1) <= _rankOf(c2) ? c1 : c2;

    setState(() {
      _classification1 = c1;
      _classification2 = c2;
      _awardedClassification = awarded;
    });
  }

  @override
  void dispose() {
    _grouping1Controller.dispose();
    _grouping2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Manual Entry', style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Enter grouping sizes for both diagrams. The lower level of the two will be awarded.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Diagram 1
                      _buildGroupingField(
                        context,
                        controller: _grouping1Controller,
                        label: 'Diagram 1 — Grouping Size (cm)',
                        result: _classification1,
                      ),
                      const SizedBox(height: 16),
                      // Diagram 2
                      _buildGroupingField(
                        context,
                        controller: _grouping2Controller,
                        label: 'Diagram 2 — Grouping Size (cm)',
                        result: _classification2,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _calculateClassification,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Calculate Level'),
                        ),
                      ),
                      if (_awardedClassification.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          'Awarded Level',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _awardedClassification,
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '(Lowest of the two diagrams)',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text('Camera Analysis (Coming Soon)', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              Card(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        LucideIcons.camera,
                        size: 48,
                        color: theme.colorScheme.secondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Snap a photo of the target to automatically score it.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupingField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String result,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(LucideIcons.ruler),
          ),
        ),
        if (result.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 4),
              Icon(LucideIcons.medal, size: 16, color: Theme.of(context).colorScheme.secondary),
              const SizedBox(width: 6),
              Text(
                result,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
