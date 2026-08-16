import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:unigo_passenger/services/route_service.dart';
import 'package:unigo_passenger/utils/format.dart';

void main() {
  group('RouteService.distanceKm', () {
    test('zero distance for same point', () {
      const p = LatLng(41.0, 29.0);
      expect(RouteService.distanceKm(p, p), closeTo(0, 1e-6));
    });

    test('approx distance between two Istanbul points', () {
      const a = LatLng(41.0082, 28.9784); // Sultanahmet
      const b = LatLng(41.0422, 29.0094); // Taksim (~4.5 km)
      final d = RouteService.distanceKm(a, b);
      expect(d, greaterThan(3.5));
      expect(d, lessThan(5.5));
    });
  });

  group('RouteService.resolve', () {
    test('parses a "lat, lng" pair without an API key', () async {
      final svc = RouteService();
      final p = await svc.resolve('41.0082, 28.9784');
      expect(p, isNotNull);
      expect(p!.latitude, closeTo(41.0082, 1e-6));
      expect(p.longitude, closeTo(28.9784, 1e-6));
    });

    test('parses a "lat lng" with comma decimals', () async {
      final svc = RouteService();
      final p = await svc.resolve('41,0082 28,9784');
      expect(p, isNotNull);
      expect(p!.latitude, closeTo(41.0082, 1e-6));
    });

    test('returns null for empty input', () async {
      final svc = RouteService();
      expect(await svc.resolve(''), isNull);
    });
  });

  group('formatDistance', () {
    test('metres under 1 km', () {
      expect(formatDistance(0.82), '820 m');
    });
    test('km at or above 1', () {
      expect(formatDistance(3.246), '3,2 km');
    });
  });
}
