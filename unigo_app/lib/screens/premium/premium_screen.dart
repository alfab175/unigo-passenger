import 'package:flutter/material.dart';
import '../../core/config.dart';
import '../../core/theme.dart';
import '../../widgets/primary_button.dart';

class PremiumScreen extends StatelessWidget { const PremiumScreen({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Premium', style: TextStyle(fontWeight: FontWeight.w800))), body: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  Container(width: double.infinity, padding: const EdgeInsets.all(24), decoration: BoxDecoration(gradient: const LinearGradient(colors: [UnigoTheme.purple, Color(0xFF9B6DFF)]), borderRadius: BorderRadius.circular(28)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('UNIGO Premium', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800)), SizedBox(height: 8), Text('Reklamsız deneyim ve avantajlı hizmet ücretleri.', style: TextStyle(color: Colors.white70))])),
  const SizedBox(height: 28), const Text('Ayrıcalıkların', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)), const SizedBox(height: 12), const Text('• Uygulamada reklamsız deneyim\n• Uzun yolculuklarda avantajlı hizmet bedeli\n• Merkezi fiyatlandırma ve kampanyalardan yararlanma'), const Spacer(), Text('₺${AppConfig.defaultPremiumPrice.toStringAsFixed(0)} / ay', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 12), PrimaryButton(label: 'Premium’a geç', onPressed: () {})
]))); }
