import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'ad_carousel.dart';

/// In-house ad inventory (revenue: in-app placements, per founder vision).
const defaultAdCreatives = [
  AdCreative(title: 'Yeni kullanıcıya ₺20 kredi', subtitle: 'İlk yolculuğunda geçerli', icon: Icons.card_giftcard_rounded),
  AdCreative(title: 'Premium ile reklamsız deneyim', subtitle: 'Aylık ₺250', icon: Icons.auto_awesome_rounded),
  AdCreative(title: 'Arkadaşını davet et', subtitle: 'Her ikinize kredi', icon: Icons.group_rounded),
];

/// Single static ad card in the same Apple style as the home carousel.
class AdCard extends StatelessWidget {
  const AdCard({super.key, required this.creative, this.onTap});
  final AdCreative creative;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: UnigoTheme.purple.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: UnigoTheme.purple.withValues(alpha: 0.12)),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: UnigoTheme.purple.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(creative.icon, color: UnigoTheme.purple, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(creative.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(creative.subtitle, style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Text('Reklam', style: TextStyle(fontSize: 9, color: Theme.of(context).hintColor)),
        ]),
      ),
    );
  }
}
