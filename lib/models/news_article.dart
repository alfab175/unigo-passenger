import 'package:cloud_firestore/cloud_firestore.dart';

/// A news article shown in the home feed's "Haberler" tab.
class NewsArticle {
  final String id;
  final String title;
  final String summary;
  final String body;
  final String? imageUrl;
  final String source;
  final DateTime? publishedAt;

  const NewsArticle({
    required this.id,
    required this.title,
    this.summary = '',
    this.body = '',
    this.imageUrl,
    this.source = 'UNIGO',
    this.publishedAt,
  });

  factory NewsArticle.fromMap(String id, Map<String, dynamic> m) => NewsArticle(
        id: id,
        title: m['title'] ?? '',
        summary: m['summary'] ?? '',
        body: m['body'] ?? '',
        imageUrl: m['imageUrl'],
        source: m['source'] ?? 'UNIGO',
        publishedAt: (m['publishedAt'] as Timestamp?)?.toDate(),
      );
}
