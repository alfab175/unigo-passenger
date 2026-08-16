class Driver {
  final String id;
  final String name;
  final String provider;
  final String? photoUrl;
  final String? vehiclePhotoUrl;
  final String vehicleType;
  final String? stationName;
  final String? description;
  final double rating;
  final int followerCount;
  final double distanceKm;
  final double estimatedFare;
  final bool active;
  final double? lat;
  final double? lng;
  final bool? male;

  const Driver({required this.id, required this.name, required this.provider, this.photoUrl, this.vehiclePhotoUrl, this.vehicleType = 'Bilinmiyor', this.stationName, this.description, this.rating = 0, this.followerCount = 0, this.distanceKm = 0, this.estimatedFare = 0, this.active = true, this.lat, this.lng, this.male});

  factory Driver.fromMap(String id, Map<String, dynamic> m) => Driver(
    id: id,
    name: m['name'] ?? 'Bilinmiyor',
    provider: m['provider'] ?? 'Taksi',
    photoUrl: m['photoUrl'], vehiclePhotoUrl: m['vehiclePhotoUrl'],
    vehicleType: m['vehicleType'] ?? 'Bilinmiyor', stationName: m['stationName'], description: m['description'],
    rating: (m['rating'] ?? 0).toDouble(), followerCount: (m['followerCount'] ?? 0) as int,
    distanceKm: (m['distanceKm'] ?? 0).toDouble(), estimatedFare: (m['estimatedFare'] ?? 0).toDouble(), active: m['active'] ?? true,
    lat: (m['lat'] ?? m['location']?.latitude) as double?, lng: (m['lng'] ?? m['location']?.longitude) as double?, male: m['male'] == true,
  );

  /// Whether this is a station/taxi driver ("Taksi") vs an app-based/private
  /// hire driver ("Diğer"). The founder wants the left panel for taxis and the
  /// right panel for everything else.
  bool get isTaxi => provider.toLowerCase() == 'taksi' || (stationName != null && stationName!.isNotEmpty);
}
