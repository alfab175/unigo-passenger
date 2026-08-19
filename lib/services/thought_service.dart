import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/thought.dart';

/// Shared thoughts feed.
///
/// Bug fixes vs the previous build:
/// - Sharing a thought APPENDS a new document; it never replaces or removes
///   other users' thoughts (the old build wrote to a single doc, so only the
///   author's own thought survived).
/// - Liking is a transaction keyed by uid inside `likedBy`, so one person can
///   like a thought at most once; tapping again un-likes (toggle).
class ThoughtService {
  final FirebaseFirestore db;
  final FirebaseAuth auth;
  ThoughtService({FirebaseFirestore? db, FirebaseAuth? auth})
      : db = db ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _col => db.collection('thoughts');

  Stream<List<Thought>> watchThoughts({int limit = 100}) => _col
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map((d) => Thought.fromMap(d.id, d.data())).toList());

  Future<void> share(String text) async {
    final user = auth.currentUser;
    if (user == null) throw StateError('Oturum bulunamadı.');
    final trimmed = text.trim();
    if (trimmed.isEmpty) throw StateError('Boş düşünce paylaşılamaz.');
    if (trimmed.length > 500) throw StateError('Düşünce 500 karakteri geçemez.');
    await _col.add({
      'userId': user.uid,
      'authorName': user.displayName ?? 'UNIGO Kullanıcısı',
      'authorPhotoUrl': user.photoURL,
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
      'likeCount': 0,
      'likedBy': <String>[],
      'edited': false,
    });
  }

  /// One like per user. Runs in a transaction so rapid double-taps or two
  /// devices cannot inflate the count.
  Future<void> toggleLike(Thought t) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw StateError('Oturum bulunamadı.');
    final ref = _col.doc(t.id);
    await db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final liked = ((snap.data()?['likedBy'] as List?) ?? const []).map((e) => e.toString()).toSet();
      final count = (snap.data()?['likeCount'] as num?)?.toInt() ?? 0;
      if (liked.contains(uid)) {
        tx.update(ref, {'likedBy': FieldValue.arrayRemove([uid]), 'likeCount': count > 0 ? count - 1 : 0});
      } else {
        tx.update(ref, {'likedBy': FieldValue.arrayUnion([uid]), 'likeCount': count + 1});
      }
    });
  }

  Future<void> delete(Thought t) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw StateError('Oturum bulunamadı.');
    if (t.userId != uid) throw StateError('Sadece kendi düşünceni silebilirsin.');
    await _col.doc(t.id).delete();
  }

  Future<void> report(Thought t, String reason) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw StateError('Oturum bulunamadı.');
    await db.collection('thought_reports').add({
      'thoughtId': t.id,
      'thoughtUserId': t.userId,
      'reason': reason,
      'reportedBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
