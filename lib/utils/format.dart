/// Format a distance in km into a compact Turkish label:
/// "820 m" under 1 km, otherwise "3,2 km".
String formatDistance(double km) {
  if (km < 1) return '${(km * 1000).round()} m';
  return '${km.toStringAsFixed(1).replaceAll('.', ',')} km';
}

/// Relative time in Turkish: "şimdi", "5 dk", "3 sa", "2 g", or "12.03.2026".
String formatTimeAgo(DateTime? t) {
  if (t == null) return '';
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'şimdi';
  if (d.inHours < 1) return '${d.inMinutes} dk';
  if (d.inDays < 1) return '${d.inHours} sa';
  if (d.inDays < 7) return '${d.inDays} g';
  return '${t.day.toString().padLeft(2, '0')}.${t.month.toString().padLeft(2, '0')}.${t.year}';
}
