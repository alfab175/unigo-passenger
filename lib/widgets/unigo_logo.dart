import 'package:flutter/material.dart';
import '../core/theme.dart';

class UnigoLogo extends StatelessWidget {
  final double size;
  const UnigoLogo({super.key, this.size = 42});
  @override Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(color: UnigoTheme.purple, borderRadius: BorderRadius.circular(size * .30), boxShadow: [BoxShadow(color: UnigoTheme.purple.withValues(alpha: .18), blurRadius: 18, offset: const Offset(0, 8))]), child: Center(child: Icon(Icons.navigation_rounded, color: Colors.white, size: size * .52)));
}
