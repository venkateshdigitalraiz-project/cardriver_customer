class LocationEntity {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final bool isCurrentLocation;

  const LocationEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.isCurrentLocation = false,
  });

  LocationEntity copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    bool? isCurrentLocation,
  }) {
    return LocationEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isCurrentLocation: isCurrentLocation ?? this.isCurrentLocation,
    );
  }
}
