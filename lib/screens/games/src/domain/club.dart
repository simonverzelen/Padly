class ClubPlace {
  final String placeId;
  final String name;
  final String address;
  final String city;
  final double lat;
  final double lng;

  ClubPlace({
    required this.placeId,
    required this.name,
    required this.address,
    required this.city,
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toJson() => {
        'placeId': placeId,
        'name': name,
        'address': address,
        'city': city,
        'lat': lat,
        'lng': lng,
      };

  factory ClubPlace.fromJson(Map<String, dynamic> json) {
    return ClubPlace(
      placeId: json['placeId'],
      name: json['name'],
      address: json['address'],
      city: json['city'],
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}
