import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/config.dart';
import '../../models/driver.dart';
import '../../services/driver_service.dart';
import '../../services/favorite_service.dart';
import '../../services/route_service.dart';
import '../../utils/format.dart';
import '../../widgets/ad_carousel.dart';
import '../../widgets/driver_side_panel.dart';
import '../../widgets/unigo_logo.dart';

/// UNIGO home: live map, smart destination search, green route, and two
/// driver panels (left = taxis, right = private hire).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _map;
  final CameraPosition _cam = const CameraPosition(target: LatLng(41.0082, 28.9784), zoom: 13);
  Position? position;
  LatLng? origin;
  LatLng? pending; // black pin before confirmation
  LatLng? destination; // confirmed destination marker
  List<LatLng> _routePoints = const [];
  final _poly = <Polyline>{};
  final _markers = <Marker>{};

  bool locating = false, searching = false, panelsOpen = false;
  bool leftCollapsed = false, rightCollapsed = false;
  String sort = 'distance';

  final _drivers = DriverService();
  final _favorites = FavoriteService();
  final _route = RouteService();

  List<Driver> all = const [];
  Set<String> favs = {};

  @override
  void initState() {
    super.initState();
    _favorites.watch().listen((s) => setState(() => favs = s));
    _drivers.watchDrivers().listen((list) {
      final pos = position;
      final enriched = list.map((d) {
        double dist = d.distanceKm;
        if (pos != null && d.lat != null && d.lng != null) {
          dist = RouteService.distanceKm(LatLng(pos.latitude, pos.longitude), LatLng(d.lat!, d.lng!));
        }
        return Driver(
          id: d.id, name: d.name, provider: d.provider, photoUrl: d.photoUrl,
          vehiclePhotoUrl: d.vehiclePhotoUrl, vehicleType: d.vehicleType, stationName: d.stationName,
          description: d.description, rating: d.rating, followerCount: d.followerCount,
          distanceKm: dist, estimatedFare: d.estimatedFare, active: d.active,
          lat: d.lat, lng: d.lng, male: d.male,
        );
      }).toList();
      setState(() => all = enriched);
    });
    locate();
  }

  Future<void> locate() async {
    setState(() => locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) throw Exception('Konum hizmetleri kapalı.');
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
      if (p == LocationPermission.denied || p == LocationPermission.deniedForever) throw Exception('Konum izni verilmedi.');
      position = await Geolocator.getCurrentPosition();
      origin = LatLng(position!.latitude, position!.longitude);
      _map?.animateCamera(CameraUpdate.newLatLngZoom(origin!, 14));
      _refreshMarkers();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => locating = false);
    }
  }

  void _onMapTap(LatLng p) {
    setState(() {
      pending = p;
      destination = null;
      _routePoints = const [];
      _poly.clear();
      _refreshMarkers();
    });
  }

  Future<void> _confirmDestination() async {
    final p = pending;
    final o = origin;
    if (p == null || o == null) return;
    setState(() => searching = true);
    try {
      final pts = await _route.route(o, p);
      setState(() {
        destination = p;
        pending = null;
        _routePoints = pts;
        _poly.clear();
        _poly.add(Polyline(
          polylineId: const PolylineId('route'),
          points: pts,
          color: const Color(0xFF22B85C),
          width: 6,
          patterns: const [],
        ));
        panelsOpen = true;
        _refreshMarkers();
        _fitRoute();
      });
    } finally {
      if (mounted) setState(() => searching = false);
    }
  }

  Future<void> _resolveSearch(String text) async {
    setState(() => searching = true);
    try {
      final p = await _route.resolve(text);
      if (p == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yer bulunamadı. Haritaya dokunarak işaretleyebilirsin.')));
        return;
      }
      setState(() => pending = p);
      _map?.animateCamera(CameraUpdate.newLatLngZoom(p, 15));
      _refreshMarkers();
    } finally {
      if (mounted) setState(() => searching = false);
    }
  }

  void _fitRoute() {
    final pts = [..._routePoints];
    if (pts.isEmpty) return;
    final bounds = LatLngBounds(
      southwest: LatLng(pts.map((e) => e.latitude).reduce((a, b) => a < b ? a : b), pts.map((e) => e.longitude).reduce((a, b) => a < b ? a : b)),
      northeast: LatLng(pts.map((e) => e.latitude).reduce((a, b) => a > b ? a : b), pts.map((e) => e.longitude).reduce((a, b) => a > b ? a : b)),
    );
    _map?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  void _refreshMarkers() {
    _markers.clear();
    if (origin != null) {
      _markers.add(Marker(markerId: const MarkerId('me'), position: origin!, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)));
    }
    if (pending != null) {
      _markers.add(Marker(
        markerId: const MarkerId('pending'),
        position: pending!,
        onTap: _confirmDestination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
    }
    if (destination != null) {
      _markers.add(Marker(markerId: const MarkerId('dest'), position: destination!, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)));
    }
  }

  void _call(Driver d) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(d.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          Text('${d.provider} • ${formatDistance(d.distanceKm)} • ★ ${d.rating.toStringAsFixed(1)}'),
          const SizedBox(height: 8),
          Text(d.description ?? 'Şoför açıklaması bulunmuyor.'),
          const SizedBox(height: 16),
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Çağır')),
        ]),
      ),
    );
  }

  void _openStationSearch() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => const Padding(padding: EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(decoration: InputDecoration(labelText: 'Şoför veya durak adı')),
        SizedBox(height: 12),
        Text('Yakındaki taksi durakları ve şoförler burada listelenir.'),
      ])),
    );
  }

  List<Driver> _taxiDrivers() => all.where((d) => d.isTaxi).toList();
  List<Driver> _otherDrivers() => all.where((d) => !d.isTaxi).toList();

  @override
  Widget build(BuildContext context) {
    final adsHidden = panelsOpen;
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          // Real map.
          GoogleMap(
            initialCameraPosition: _cam,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            polylines: _poly,
            markers: _markers,
            onTap: _onMapTap,
            onMapCreated: (c) { _map = c; if (origin != null) c.moveCamera(CameraUpdate.newLatLngZoom(origin!, 14)); },
          ),

          // Logo + locate button.
          Positioned(top: 12, left: 12, child: const UnigoLogo(size: 44)),
          Positioned(
            top: 12,
            right: 12,
            child: IconButton.filledTonal(
              onPressed: locating ? null : locate,
              icon: Icon(locating ? Icons.hourglass_top_rounded : Icons.my_location_rounded),
            ),
          ),

          // Smart search bar — pastes WhatsApp addresses, parses coords, geocodes.
          Positioned(
            top: 12,
            left: 64,
            right: 64,
            child: _SearchBar(
              onSubmitted: _resolveSearch,
              onClear: () => setState(() { pending = null; destination = null; _routePoints = const []; _poly.clear(); panelsOpen = false; _refreshMarkers(); }),
              busy: searching,
            ),
          ),

          // Confirm pin hint: black pin with white "Konum işaretle" label.
          if (pending != null)
            Positioned(bottom: panelsOpen ? 0 : 140, left: 0, right: 0, child: Center(child: _ConfirmPin(onTap: _confirmDestination))),

          // Driver side panels after route is drawn.
          if (panelsOpen) ...[
            DriverSidePanel(
              side: PanelSide.left,
              title: 'Taksi',
              drivers: _taxiDrivers(),
              favorites: favs,
              collapsed: leftCollapsed,
              onToggle: () => setState(() => leftCollapsed = !leftCollapsed),
              onCall: _call,
              onSearch: _openStationSearch,
              showStationSearch: true,
            ),
            DriverSidePanel(
              side: PanelSide.right,
              title: 'Diğer',
              drivers: _otherDrivers(),
              favorites: favs,
              collapsed: rightCollapsed,
              onToggle: () => setState(() => rightCollapsed = !rightCollapsed),
              onCall: _call,
              onSearch: () {},
              showStationSearch: false,
            ),
          ] else ...[
            // Nearby list (pre-route state) at bottom.
            Positioned(left: 16, right: 16, bottom: 16, child: _NearbySheet(
              drivers: _sorted(all),
              sort: sort,
              onSort: (v) => setState(() => sort = v),
              onCall: _call,
              onFavorite: (d) => _favorites.toggle(d.id),
              favorites: favs,
            )),
          ],

          // Ad carousel — Apple-style, hidden when panels are open.
          if (!adsHidden)
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Center(
                child: AdCarousel(
                  height: 60,
                  creatives: const [
                    AdCreative(title: 'Yeni kullanıcıya ₺20 kredi', subtitle: 'İlk yolculuğunda geçerli', icon: Icons.card_giftcard_rounded),
                    AdCreative(title: 'Premium ile reklamsız deneyim', subtitle: 'Aylık ₺250', icon: Icons.auto_awesome_rounded),
                    AdCreative(title: 'Arkadaşını davet et', subtitle: 'Her ikinize kredi', icon: Icons.group_rounded),
                  ],
                ),
              ),
            ),
        ]),
      ),
    );
  }

  List<Driver> _sorted(List<Driver> d) {
    final x = [...d];
    if (sort == 'rating') {
      x.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (sort == 'price') {
      x.sort((a, b) => a.estimatedFare.compareTo(b.estimatedFare));
    } else {
      x.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    }
    return x;
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onSubmitted, required this.onClear, required this.busy});
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final bool busy;
  @override
  Widget build(BuildContext context) {
    final c = TextEditingController();
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 16)],
      ),
      child: Row(children: [
        Icon(busy ? Icons.hourglass_top_rounded : Icons.search_rounded, size: 20),
        const SizedBox(width: 8),
        Expanded(child: TextField(
          controller: c,
          textInputAction: TextInputAction.search,
          onSubmitted: onSubmitted,
          decoration: const InputDecoration(hintText: 'Gideceğin yeri ara veya adres yapıştır', border: InputBorder.none, isDense: true),
        )),
        GestureDetector(onTap: () { c.clear(); onClear(); }, child: const Icon(Icons.close_rounded, size: 18)),
      ]),
    );
  }
}

class _ConfirmPin extends StatelessWidget {
  const _ConfirmPin({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 12)],
          ),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.place_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Konum işaretle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ]),
        ),
      );
}

class _NearbySheet extends StatelessWidget {
  const _NearbySheet({required this.drivers, required this.sort, required this.onSort, required this.onCall, required this.onFavorite, required this.favorites});
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
    return Container(
      constraints: const BoxConstraints(maxHeight: 280),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 30)],
      ),
      child: Column(children: [
        Row(children: [
          const Expanded(child: Text('Yakındaki seçenekler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
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
        const SizedBox(height: 6),
        Expanded(child: list.isEmpty
          ? const Center(child: Text('Şu anda yakında uygun araç bulunamadı.'))
          : ListView.separated(
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
      ]),
    );
  }
}