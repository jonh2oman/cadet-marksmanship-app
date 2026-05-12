import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/help_content.dart';

class HelpArticleScreen extends StatelessWidget {
  final String articleId;

  const HelpArticleScreen({
    super.key,
    required this.articleId,
  });

  @override
  Widget build(BuildContext context) {
    final article = helpArticles.firstWhere(
      (a) => a.id == articleId,
      orElse: () => throw Exception('Article not found'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructions'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                article.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[400],
                    ),
              ),
              const Divider(height: 48),
              Text(
                'Step-by-Step Guide',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              ...article.steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          step,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 40),
              _buildProTip(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProTip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.lightbulb, color: Colors.blue),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Pro Tip: Keep this tab open as a reference while you navigate the app in your other window!',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
