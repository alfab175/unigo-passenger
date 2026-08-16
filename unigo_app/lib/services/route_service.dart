import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

/// Smart destination parser + road-aware polyline helper.
///
/// Users can paste an address copied from WhatsApp or type free text and the
/// app resolves it to a point, then draws a green route over roads. Resilient:
/// if the Google API key is unavailable or the network fails, callers degrade
/// gracefully (straight-line fallback, or "no result").
class RouteService {
  RouteService({String? apiKey, http.Client? client})
      : _apiKey = apiKey,
        _client = client ?? http.Client();

  final String? _apiKey;
  final http.Client _client;

  /// Parse pasted/typed text into a candidate [LatLng].
  /// 1. "lat, lng" numeric pair. 2. Google Geocoding API. Returns null if none.
  Future<LatLng?> resolve(String input) async {
    final text = input.trim();
    if (text.isEmpty) return null;

    final pair = RegExp(r'(-?\d{1,3}(?:[.,]\d+)?)\s*[,\s]\s*(-?\d{1,3}(?:[.,]\d+)?)')
        .firstMatch(text);
    if (pair != null) {
      final lat = double.tryParse(pair.group(1)!.replaceAll(',', '.'));
      final lng = double.tryParse(pair.group(2)!.replaceAll(',', '.'));
      if (lat != null && lng != null && _valid(lat, lng)) return LatLng(lat, lng);
    }

    if (_apiKey == null || _apiKey.isEmpty) return null;
    try {
      final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json',
          {'address': text, 'language': 'tr', 'key': _apiKey});
      final res = await _client.get(uri, headers: {'Accept': 'application/json'});
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final results = (data['results'] as List?) ?? const [];
      if (results.isEmpty) return null;
      final loc = (results.first['geometry'] as Map)['location'] as Map;
      final lat = (loc['lat'] as num).toDouble();
      final lng = (loc['lng'] as num).toDouble();
      return _valid(lat, lng) ? LatLng(lat, lng) : null;
    } catch (_) {
      return null;
    }
  }

  /// Road-aware polyline between [origin] and [destination]; falls back to a
  /// straight line when the Directions API is unavailable.
  Future<List<LatLng>> route(LatLng origin, LatLng destination) async {
    if (_apiKey == null || _apiKey.isEmpty) return [origin, destination];
    try {
      final uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'mode': 'driving',
        'language': 'tr',
        'key': _apiKey,
      });
      final res = await _client.get(uri, headers: {'Accept': 'application/json'});
      if (res.statusCode != 200) return [origin, destination];
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final routes = (data['routes'] as List?) ?? const [];
      if (routes.isEmpty) return [origin, destination];
      final points = (routes.first['overview_polyline'] as Map)['points'] as String;
      return _decodePolyline(points);
    } catch (_) {
      return [origin, destination];
    }
  }

  /// Haversine distance in km — used for fare bands and proximity filtering.
  static double distanceKm(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = _rad(b.latitude - a.latitude);
    final dLng = _rad(b.longitude - a.longitude);
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(a.latitude)) * math.cos(_rad(b.latitude)) *
            math.sin(dLng / 2) * math.sin(dLng / 2);
    return 2 * r * math.asin(math.sqrt(h.clamp(0.0, 1.0)));
  }

  static bool _valid(double lat, double lng) =>
      lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  static double _rad(double d) => d * math.pi / 180.0;

  static List<LatLng> _decodePolyline(String encoded) {
    final out = <LatLng>[];
    int index = 0, lat = 0, lng = 0;
    while (index < encoded.length) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;
      out.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return out;
  }
}
