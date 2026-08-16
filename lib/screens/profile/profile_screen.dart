import 'package:flutter/material.dart';
import '../premium/premium_screen.dart';

class ProfileScreen extends StatelessWidget { const ProfileScreen({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Profil', style: TextStyle(fontWeight: FontWeight.w800))), body: ListView(padding: const EdgeInsets.all(20), children: [
  Row(children: [const CircleAvatar(radius: 34, child: Icon(Icons.person_outline, size: 32)), const SizedBox(width: 14), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('UNIGO Kullanıcısı', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)), Text('Profilini düzenle', style: TextStyle(color: Colors.grey))])), IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined))]),
  const SizedBox(height: 24),
  _item(context, Icons.person_outline, 'Kişisel bilgiler', () {}), _item(context, Icons.credit_card_outlined, 'Kayıtlı kartlar', () {}), _item(context, Icons.workspace_premium_outlined, 'Premium abonelik', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()))),
  const Divider(height: 34),
  _item(context, Icons.settings_outlined, 'Ayarlar', () {}), _item(context, Icons.description_outlined, 'Kullanıcı sözleşmesi', () {}), _item(context, Icons.privacy_tip_outlined, 'KVKK', () {}), _item(context, Icons.history_rounded, 'Seyahatlerim', () {}), _item(context, Icons.pedal_bike_outlined, 'Kiralamalarım', () {}),
  const SizedBox(height: 20), OutlinedButton(onPressed: () {}, child: const Text('Şoför ol')),
]));
Widget _item(BuildContext c, IconData i, String t, VoidCallback f) => ListTile(onTap: f, leading: CircleAvatar(radius: 20, backgroundColor: Theme.of(c).colorScheme.surfaceContainerHighest, child: Icon(i)), title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)), trailing: const Icon(Icons.chevron_right_rounded)); }
