/// Format a distance in km into a compact Turkish label:
/// "820 m" under 1 km, otherwise "3,2 km".
String formatDistance(double km) {
  if (km < 1) return '${(km * 1000).round()} m';
  return '${km.toStringAsFixed(1).replaceAll('.', ',')} km';
}
