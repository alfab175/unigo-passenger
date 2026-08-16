import 'package:flutter/material.dart';
import '../core/theme.dart';

/// A clean, Apple-style rotating ad card. Non-intrusive: a single rounded card
/// that cross-fades between creatives; the user can scroll past it. Revenues
/// come from in-app placements like this (vision: revenue #1).
class AdCarousel extends StatefulWidget {
  const AdCarousel({super.key, this.creatives = const [], this.height = 76});
  final List<AdCreative> creatives;
  final double height;

  @override
  State<AdCarousel> createState() => _AdCarouselState();
}

class _AdCarouselState extends State<AdCarousel> {
  int _i = 0;
  @override
  void initState() {
    super.initState();
    if (widget.creatives.length > 1) {
      Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 4));
        if (!mounted) return false;
        setState(() => _i = (_i + 1) % widget.creatives.length);
        return true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.creatives.isEmpty) return const SizedBox.shrink();
    final c = widget.creatives[_i];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: Container(
        key: ValueKey(_i),
        height: widget.height,
        margin: const EdgeInsets.symmetric(horizontal: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.08)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: UnigoTheme.purple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(c.icon, color: UnigoTheme.purple, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(c.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(c.subtitle, style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Text('Reklam', style: TextStyle(fontSize: 9, color: Theme.of(context).hintColor)),
        ]),
      ),
    );
  }
}

class AdCreative {
  final String title;
  final String subtitle;
  final IconData icon;
  const AdCreative({required this.title, required this.subtitle, required this.icon});
}
