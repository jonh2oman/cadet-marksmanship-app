enum HelpCategory {
  general,
  marksmanship,
  biathlon,
  scoring,
  teams,
  rules,
}

class HelpArticle {
  final String id;
  final String title;
  final String description;
  final HelpCategory category;
  final List<String> steps;

  const HelpArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.steps,
  });
}
