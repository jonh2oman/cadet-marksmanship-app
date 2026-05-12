import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChangeLogScreen extends StatelessWidget {
  const ChangeLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CHANGE LOG'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildRelease(
            version: 'v1.2.0',
            date: 'May 12, 2026',
            changes: [
              'Added "Scoring Only" quick-access mode to the home screen.',
              'Implemented mandatory Legal Disclaimer & Acknowledgement.',
              'Added detailed help articles for new features.',
              'Enhanced home screen branding and layout.',
            ],
            isLatest: true,
          ),
          const SizedBox(height: 32),
          _buildRelease(
            version: 'v1.1.0',
            date: 'May 12, 2026',
            changes: [
              'Complete UI overhaul with RCN-inspired Navy/Gold palette.',
              'Implemented Glassmorphism across all major components.',
              'Added dynamic Theme Switching (Light, Dark, and "SEA" modes).',
              'Integrated global Help Button accessible from every screen.',
            ],
          ),
          const SizedBox(height: 32),
          _buildRelease(
            version: 'v1.0.0',
            date: 'May 12, 2026',
            changes: [
              'Initial Web Deployment via GitHub Pages.',
              'Automated CI/CD pipeline using GitHub Actions.',
              'Searchable Help Hub implementation.',
              'Core Marksmanship and Biathlon features migration.',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRelease({
    required String version,
    required String date,
    required List<String> changes,
    bool isLatest = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              version,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 12),
            if (isLatest)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'LATEST',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const Spacer(),
            Text(
              date,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...changes.map((change) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.checkCircle2, size: 14, color: Colors.white38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      change,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
