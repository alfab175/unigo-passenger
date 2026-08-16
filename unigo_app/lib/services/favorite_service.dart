import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Tracks the passenger's followed/favourite drivers (stored on the user doc).
class FavoriteService {
  FavoriteService({FirebaseFirestore? db, FirebaseAuth? auth})
      : db = db ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore db;
  final FirebaseAuth auth;

  Set<String> _cache = {};
  bool _loaded = false;

  Stream<Set<String>> watch() {
    final uid = auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return db.collection('users').doc(uid).snapshots().map((d) {
      final list = (d.data()?['favorites'] as List?) ?? const [];
      _cache = list.map((e) => e.toString()).toSet();
      _loaded = true;
      return _cache;
    });
  }

  bool isFavorite(String driverId) => _cache.contains(driverId);

  Future<void> toggle(String driverId) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw StateError('Oturum bulunamadı.');
    final ref = db.collection('users').doc(uid);
    if (!_loaded) _cache = (await ref.get()).data()?['favorites']?.map((e) => e.toString()).toSet() ?? <String>{};
    if (_cache.contains(driverId)) {
      _cache = _cache..remove(driverId);
      await ref.update({'favorites': FieldValue.arrayRemove([driverId])});
    } else {
      _cache = _cache..add(driverId);
      await ref.set({'favorites': FieldValue.arrayUnion([driverId])}, SetOptions(merge: true));
    }
  }
}
