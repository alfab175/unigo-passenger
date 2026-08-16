import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/driver.dart';

class DriverService {
  final FirebaseFirestore db;
  DriverService({FirebaseFirestore? db}) : db = db ?? FirebaseFirestore.instance;

  Stream<List<Driver>> watchDrivers() => db.collection('drivers').where('active', isEqualTo: true).snapshots().map(
    (s) => s.docs.map((d) => Driver.fromMap(d.id, d.data())).toList(),
  );
}
