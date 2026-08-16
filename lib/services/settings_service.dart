import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_settings.dart';

class SettingsService {
  final FirebaseFirestore db;
  SettingsService({FirebaseFirestore? db}) : db = db ?? FirebaseFirestore.instance;

  Stream<AppSettings> watch() => db.collection('app_config').doc('public').snapshots().map(
    (d) => AppSettings.fromMap(d.data() ?? const {}),
  );
}
