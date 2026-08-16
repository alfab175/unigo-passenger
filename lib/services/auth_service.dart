import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth auth;
  final FirebaseFirestore db;
  AuthService({FirebaseAuth? auth, FirebaseFirestore? db}) : auth = auth ?? FirebaseAuth.instance, db = db ?? FirebaseFirestore.instance;

  Future<UserCredential> signIn(String email, String password) => auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<UserCredential> register(String email, String password, String name, {String? city}) async {
    final cred = await auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    await cred.user!.updateDisplayName(name.trim());
    await db.collection('users').doc(cred.user!.uid).set({
      'email': email.trim(), 'name': name.trim(), 'city': city, 'role': 'passenger', 'premium': false,
      'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
    });
    return cred;
  }

  Future<UserCredential> google() async {
    final account = await GoogleSignIn().signIn();
    if (account == null) throw FirebaseAuthException(code: 'cancelled', message: 'Google girişi iptal edildi.');
    final tokens = await account.authentication;
    final credential = GoogleAuthProvider.credential(accessToken: tokens.accessToken, idToken: tokens.idToken);
    final result = await auth.signInWithCredential(credential);
    final u = result.user!;
    await db.collection('users').doc(u.uid).set({
      'email': u.email, 'name': u.displayName ?? 'UNIGO Kullanıcısı', 'photoUrl': u.photoURL,
      'role': 'passenger', 'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return result;
  }

  Future<void> signOut() => auth.signOut();
}
