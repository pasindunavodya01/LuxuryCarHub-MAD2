class DealerLocation {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? address;

  DealerLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
  });

  factory DealerLocation.fromJson(Map<String, dynamic> json) {
    return DealerLocation(
      id: json['id'].toString(),
      name: json['name'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      address: json['address'],
    );
  }
}
