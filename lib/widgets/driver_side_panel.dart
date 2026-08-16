import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/driver.dart';
import '../utils/format.dart';
import '../widgets/driver_avatar.dart';

/// A slim driver list panel pinned to the side of the map.
///
/// Left side hosts taxis ("Taksi"); right side hosts private-hire/app drivers
/// ("Diğer"). Each panel:
///  - slides in from its side once a route is drawn,
///  - shows 3 drivers with the 4th peeking (scroll for more),
///  - pins favourites to the top when they're within range,
///  - sorts the rest by distance ascending,
///  - collapses to a small central round chip.
class DriverSidePanel extends StatelessWidget {
  const DriverSidePanel({
    super.key,
    required this.side,
    required this.title,
    required this.drivers,
    required this.favorites,
    required this.collapsed,
    required this.onToggle,
    required this.onCall,
    required this.onSearch,
    this.showStationSearch = false,
  });

  final PanelSide side;
  final String title;
  final List<Driver> drivers;
  final Set<String> favorites;
  final bool collapsed;
  final VoidCallback onToggle;
  final void Function(Driver) onCall;
  final VoidCallback onSearch;
  final bool showStationSearch;

  @override
  Widget build(BuildContext context) {
    final ordered = _ordered(drivers, favorites);

    if (collapsed) {
      return _CollapseChip(side: side, title: title, onTap: onToggle);
    }

    final align = side == PanelSide.left
        ? Alignment.centerLeft
        : Alignment.centerRight;

    return Align(
      alignment: align,
      child: AnimatedSlide(
        offset: Offset.zero,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.42,
          constraints: const BoxConstraints(maxWidth: 200, maxHeight: 360),
          margin: EdgeInsets.only(
            left: side == PanelSide.left ? 12 : 0,
            right: side == PanelSide.right ? 12 : 0,
            top: 70,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.97),
            borderRadius: BorderRadius.only(
              topLeft: side == PanelSide.right ? const Radius.circular(26) : Radius.zero,
              bottomLeft: side == PanelSide.right ? const Radius.circular(26) : Radius.zero,
              topRight: side == PanelSide.left ? const Radius.circular(26) : Radius.zero,
              bottomRight: side == PanelSide.left ? const Radius.circular(26) : Radius.zero,
            ),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 28, offset: const Offset(0, 6))],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _Header(title: title, side: side, onCollapse: onToggle),
            if (showStationSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                child: _DomeSearch(onTap: onSearch, side: side),
              ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 12),
                itemCount: ordered.length,
                separatorBuilder: (_, __) => Divider(height: 6, color: Theme.of(context).dividerColor.withValues(alpha: 0.08)),
                itemBuilder: (_, i) {
                  final d = ordered[i];
                  final fav = favorites.contains(d.id);
                  // Only the 4th card peeks; we keep it slightly clipped.
                  final peek = i == 3;
                  return Opacity(opacity: peek ? 0.5 : 1, child: _DriverCard(driver: d, favorite: fav, onCall: onCall));
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }

  /// Favourites (within range) pinned first, then closest-first.
  List<Driver> _ordered(List<Driver> list, Set<String> favs) {
    const cap = 5.0; // km — matches AppConfig.defaultProximityKm
    final within = list.where((d) => d.distanceKm <= cap).toList();
    final fav = within.where((d) => favs.contains(d.id)).toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    final rest = within.where((d) => !favs.contains(d.id)).toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    // Fallback: if nothing is within range, still show closest-first.
    if (within.isEmpty) {
      final all = [...list]..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      return all;
    }
    return [...fav, ...rest];
  }
}

enum PanelSide { left, right }

class _CollapseChip extends StatelessWidget {
  const _CollapseChip({required this.side, required this.title, required this.onTap});
  final PanelSide side;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: side == PanelSide.left ? Alignment.centerLeft : Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(
          left: side == PanelSide.left ? 12 : 0,
          right: side == PanelSide.right ? 12 : 0,
          top: 78,
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.97),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 16)],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(side == PanelSide.left ? Icons.chevron_right_rounded : Icons.chevron_left_rounded, size: 18),
              const SizedBox(width: 4),
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.side, required this.onCollapse});
  final String title;
  final PanelSide side;
  final VoidCallback onCollapse;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 8, 0),
        child: Row(children: [
          Icon(side == PanelSide.left ? Icons.local_taxi_rounded : Icons.directions_car_rounded, size: 16, color: UnigoTheme.purple),
          const SizedBox(width: 6),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
          GestureDetector(onTap: onCollapse, child: Icon(side == PanelSide.left ? Icons.chevron_left_rounded : Icons.chevron_right_rounded, size: 18)),
        ]),
      );
}

class _DomeSearch extends StatelessWidget {
  const _DomeSearch({required this.onTap, required this.side});
  final VoidCallback onTap;
  final PanelSide side;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(19),
          ),
          child: const Row(children: [
            Icon(Icons.search_rounded, size: 16),
            SizedBox(width: 6),
            Expanded(child: Text('Şoför / durak ara', style: TextStyle(fontSize: 11))),
          ]),
        ),
      );
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.driver, required this.favorite, required this.onCall});
  final Driver driver;
  final bool favorite;
  final void Function(Driver) onCall;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      DriverAvatar(photoUrl: driver.photoUrl, male: driver.male ?? true, radius: 20),
      const SizedBox(width: 8),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Flexible(child: Text(driver.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
            if (favorite) ...[const SizedBox(width: 4), const Icon(Icons.star_rounded, size: 12, color: Colors.amber)],
          ]),
          const SizedBox(height: 2),
          Text(formatDistance(driver.distanceKm), style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor)),
        ]),
      ),
      const SizedBox(width: 6),
      GestureDetector(
        onTap: () => onCall(driver),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: UnigoTheme.purple, borderRadius: BorderRadius.circular(12)),
          child: const Text('Çağır', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
        ),
      ),
    ]);
  }
}
