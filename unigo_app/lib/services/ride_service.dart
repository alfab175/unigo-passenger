import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RideService {
  final FirebaseFirestore db;
  final FirebaseAuth auth;
  RideService({FirebaseFirestore? db, FirebaseAuth? auth}) : db = db ?? FirebaseFirestore.instance, auth = auth ?? FirebaseAuth.instance;

  Future<String> requestRide({required String driverId, required String provider, required String originLabel, required String destinationLabel, required double distanceKm, required double estimatedFare, required double serviceFee}) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw StateError('Oturum bulunamadı.');
    final ref = db.collection('rides').doc();
    await ref.set({
      'userId': uid, 'driverId': driverId, 'provider': provider,
      'originLabel': originLabel, 'destinationLabel': destinationLabel,
      'distanceKm': distanceKm, 'estimatedFare': estimatedFare, 'serviceFee': serviceFee,
      'status': 'requested', 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchRide(String rideId) => db.collection('rides').doc(rideId).snapshots();

  Future<void> cancelRide(String rideId, String reason) => db.collection('rides').doc(rideId).update({'status': 'cancelled', 'cancelReason': reason, 'updatedAt': FieldValue.serverTimestamp()});
}
