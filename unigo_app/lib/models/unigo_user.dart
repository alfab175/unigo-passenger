class UnigoUser {
  final String id;
  final String email;
  final String name;
  final String? city;
  final String? photoUrl;
  final bool premium;

  const UnigoUser({required this.id, required this.email, required this.name, this.city, this.photoUrl, this.premium = false});

  factory UnigoUser.fromMap(String id, Map<String, dynamic> m) => UnigoUser(
    id: id,
    email: m['email'] ?? '',
    name: m['name'] ?? 'UNIGO Kullanıcısı',
    city: m['city'],
    photoUrl: m['photoUrl'],
    premium: m['premium'] == true,
  );
}
