import 'package:cloud_firestore/cloud_firestore.dart';

/// A passenger's shared thought (short public post in the feed).
class Thought {
  final String id;
  final String userId;
  final String authorName;
  final String? authorPhotoUrl;
  final String text;
  final DateTime? createdAt;
  final int likeCount;
  final Set<String> likedBy;
  final bool edited;

  const Thought({
    required this.id,
    required this.userId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.text,
    this.createdAt,
    this.likeCount = 0,
    this.likedBy = const {},
    this.edited = false,
  });

  bool likedByUser(String? uid) => uid != null && likedBy.contains(uid);

  factory Thought.fromMap(String id, Map<String, dynamic> m) => Thought(
        id: id,
        userId: m['userId'] ?? '',
        authorName: m['authorName'] ?? 'UNIGO Kullanıcısı',
        authorPhotoUrl: m['authorPhotoUrl'],
        text: m['text'] ?? '',
        createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
        likeCount: (m['likeCount'] as num?)?.toInt() ?? 0,
        likedBy: ((m['likedBy'] as List?) ?? const []).map((e) => e.toString()).toSet(),
        edited: m['edited'] == true,
      );
}
