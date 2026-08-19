import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_article.dart';

/// News feed for the "Haberler" tab. Articles are admin-curated in Firestore;
/// saving is kept locally per device, reports go to Firestore for review.
class NewsService {
  final FirebaseFirestore db;
  final FirebaseAuth auth;
  NewsService({FirebaseFirestore? db, FirebaseAuth? auth})
      : db = db ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  static const _savedKey = 'saved_news_ids';

  Stream<List<NewsArticle>> watchNews({int limit = 50}) => db
      .collection('news')
      .orderBy('publishedAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map((d) => NewsArticle.fromMap(d.id, d.data())).toList());

  Future<Set<String>> loadSavedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_savedKey) ?? const []).toSet();
  }

  Future<Set<String>> toggleSaved(String articleId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList(_savedKey) ?? const []).toSet();
    ids.contains(articleId) ? ids.remove(articleId) : ids.add(articleId);
    await prefs.setStringList(_savedKey, ids.toList());
    return ids;
  }

  Future<void> report(NewsArticle a, String reason) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw StateError('Oturum bulunamadı.');
    await db.collection('news_reports').add({
      'articleId': a.id,
      'articleTitle': a.title,
      'reason': reason,
      'reportedBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Local fallback feed so the tab is never empty while Firestore has no
  /// curated articles yet.
  static List<NewsArticle> fallback() {
    final now = DateTime.now();
    return [
      NewsArticle(id: 'local-1', title: 'UNIGO’ya hoş geldin', summary: 'Tüm yolculuk uygulamaları tek yerde.', body: 'UNIGO; taksi ve özel araç seçeneklerini tek haritada toplar. Yakındaki sürücüleri gör, mesafeye göre ücreti önceden bil, yolculuğunu gönül rahatlığıyla planla.', publishedAt: now),
      NewsArticle(id: 'local-2', title: 'Gece yolculuklarında dikkat edilmesi gerekenler', summary: 'Güvenli bir gece yolculuğu için birkaç küçük adım.', body: 'Gece seyahatlerinde aracın plakasını kontrol et, rotanı bir yakınınla paylaş ve yolculuk boyunca canlı takibi açık tut. UNIGO, tahmini ücreti önceden göstererek sürprizleri önler.', publishedAt: now.subtract(const Duration(hours: 5))),
    ];
  }
}
