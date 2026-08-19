import 'package:flutter/material.dart';

/// iOS-style segmented control: gray rounded track, white sliding pill.
class AppleSegmentedControl extends StatelessWidget {
  const AppleSegmentedControl({super.key, required this.labels, required this.selected, required this.onChanged});
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 34,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF2C2C2E) : const Color(0xFFE9E9EB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(child: GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: i == selected ? (dark ? const Color(0xFF48484A) : Colors.white) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: i == selected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 4, offset: const Offset(0, 1))] : null,
              ),
              child: Text(labels[i], style: TextStyle(fontSize: 13, fontWeight: i == selected ? FontWeight.w700 : FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          )),
      ]),
    );
  }
}
