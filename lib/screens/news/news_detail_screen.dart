import 'package:flutter/material.dart';
import '../../models/news_article.dart';
import '../../utils/format.dart';

/// Full article view, Apple News style: large title, source line, body.
class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key, required this.article});
  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(article.source), centerTitle: true),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 32), children: [
        Text(article.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, height: 1.25)),
        const SizedBox(height: 8),
        Text('${article.source} • ${formatTimeAgo(article.publishedAt)}', style: TextStyle(fontSize: 12, color: theme.hintColor)),
        if (article.imageUrl != null) ...[
          const SizedBox(height: 16),
          ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(article.imageUrl!, fit: BoxFit.cover)),
        ],
        const SizedBox(height: 16),
        Text(article.body.isEmpty ? article.summary : article.body, style: const TextStyle(fontSize: 16, height: 1.55)),
      ]),
    );
  }
}
