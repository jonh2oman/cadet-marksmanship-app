import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/help_content.dart';
import '../domain/help_article.dart';

class HelpHubScreen extends StatefulWidget {
  const HelpHubScreen({super.key});

  @override
  State<HelpHubScreen> createState() => _HelpHubScreenState();
}

class _HelpHubScreenState extends State<HelpHubScreen> {
  final _searchController = TextEditingController();
  List<HelpArticle> _filteredArticles = helpArticles;

  void _onSearchChanged(String query) {
    setState(() {
      _filteredArticles = helpArticles.where((article) {
        final titleMatch = article.title.toLowerCase().contains(query.toLowerCase());
        final descMatch = article.description.toLowerCase().contains(query.toLowerCase());
        return titleMatch || descMatch;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Hub'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search for help topics...',
                prefixIcon: const Icon(LucideIcons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),
          Expanded(
            child: _filteredArticles.isEmpty
                ? const Center(
                    child: Text('No help topics found.'),
                  )
                : ListView.builder(
                    itemCount: _filteredArticles.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final article = _filteredArticles[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: _getCategoryIcon(article.category),
                          title: Text(article.title),
                          subtitle: Text(
                            article.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(LucideIcons.chevronRight),
                          onTap: () => context.push('/help/${article.id}'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _getCategoryIcon(HelpCategory category) {
    switch (category) {
      case HelpCategory.general:
        return const Icon(LucideIcons.info);
      case HelpCategory.marksmanship:
        return const Icon(LucideIcons.target);
      case HelpCategory.biathlon:
        return const Icon(LucideIcons.crosshair);
      case HelpCategory.scoring:
        return const Icon(LucideIcons.clipboardCheck);
      case HelpCategory.teams:
        return const Icon(LucideIcons.users);
      case HelpCategory.rules:
        return const Icon(LucideIcons.book);
    }
  }
}
