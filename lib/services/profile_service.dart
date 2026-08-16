import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseFirestore db;
  final FirebaseAuth auth;
  ProfileService({FirebaseFirestore? db, FirebaseAuth? auth}) : db = db ?? FirebaseFirestore.instance, auth = auth ?? FirebaseAuth.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchProfile() {
    final uid = auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return db.collection('users').doc(uid).snapshots();
  }

  Future<void> updateProfile({String? name, String? city, String? country}) async {
    final user = auth.currentUser;
    if (user == null) throw StateError('Oturum bulunamadı.');
    if (name != null) await user.updateDisplayName(name.trim());
    final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};
    if (name != null) data['name'] = name.trim();
    if (city != null) data['city'] = city.trim();
    if (country != null) data['country'] = country.trim();
    await db.collection('users').doc(user.uid).set(data, SetOptions(merge: true));
  }
}
