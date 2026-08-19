import 'package:flutter/material.dart';
import '../../core/config.dart';
import '../../models/driver.dart';
import '../../utils/format.dart';
import '../../widgets/apple_segmented_control.dart';
import '../news/news_feed.dart';
import '../thoughts/thoughts_feed.dart';

/// Bottom feed on the home screen with three tabs: nearby drivers (the
/// original list, unchanged), news, and shared thoughts.
class FeedSheet extends StatelessWidget {
  const FeedSheet({
    super.key,
    required this.drivers,
    required this.sort,
    required this.onSort,
    required this.onCall,
    required this.onFavorite,
    required this.favorites,
    required this.tab,
    required this.onTab,
  });

  final List<Driver> drivers;
  final String sort;
  final ValueChanged<String> onSort;
  final void Function(Driver) onCall;
  final void Function(Driver) onFavorite;
  final Set<String> favorites;
  final int tab;
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    final maxH = tab == 0 ? 300.0 : MediaQuery.of(context).size.height * 0.66;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      constraints: BoxConstraints(maxHeight: maxH),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 30)],
      ),
      child: Column(children: [
        AppleSegmentedControl(labels: const ['Araçlar', 'Haberler', 'Düşünceler'], selected: tab, onChanged: onTab),
        const SizedBox(height: 10),
        Expanded(child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: switch (tab) {
            1 => const NewsFeed(key: ValueKey('news')),
            2 => const ThoughtsFeed(key: ValueKey('thoughts')),
            _ => _DriversTab(key: const ValueKey('drivers'), drivers: drivers, sort: sort, onSort: onSort, onCall: onCall, onFavorite: onFavorite, favorites: favorites),
          },
        )),
      ]),
    );
  }
}

class _DriversTab extends StatelessWidget {
  const _DriversTab({super.key, required this.drivers, required this.sort, required this.onSort, required this.onCall, required this.onFavorite, required this.favorites});
  final List<Driver> drivers;
  final String sort;
  final ValueChanged<String> onSort;
  final void Function(Driver) onCall;
  final void Function(Driver) onFavorite;
  final Set<String> favorites;

  @override
  Widget build(BuildContext context) {
    final within = drivers.where((d) => d.distanceKm <= AppConfig.defaultProximityKm).toList();
    final list = within.isEmpty ? drivers.take(5).toList() : within;
    return Column(children: [
      Row(children: [
        const Expanded(child: Text('Yakındaki seçenekler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
        PopupMenuButton<String>(
          onSelected: onSort,
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'distance', child: Text('Yakından uzağa')),
            PopupMenuItem(value: 'price', child: Text('En ucuzdan pahalıya')),
            PopupMenuItem(value: 'rating', child: Text('Puanı yüksekten düşüğe')),
          ],
          child: const Icon(Icons.tune_rounded),
        ),
      ]),
      const SizedBox(height: 4),
      Expanded(child: list.isEmpty
        ? const Center(child: Text('Şu anda yakında uygun araç bulunamadı.'))
        : ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: list.length,
            itemBuilder: (_, i) {
              final d = list[i];
              final fav = favorites.contains(d.id);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_rounded),
                title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${d.provider} • ${formatDistance(d.distanceKm)} • ★ ${d.rating.toStringAsFixed(1)}'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(icon: Icon(fav ? Icons.star_rounded : Icons.star_border_rounded, color: fav ? Colors.amber : null), onPressed: () => onFavorite(d)),
                  Text('₺${d.estimatedFare.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800)),
                ]),
                onTap: () => onCall(d),
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
          )),
    ]);
  }
}
