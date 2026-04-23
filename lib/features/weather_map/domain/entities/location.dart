import 'package:latlong2/latlong.dart';

/// Represents a geographic location with optional name/address
class Location {
  final LatLng coordinates;
  final String? name;
  final String? address;

  const Location({required this.coordinates, this.name, this.address});

  Location copyWith({LatLng? coordinates, String? name, String? address}) {
    return Location(
      coordinates: coordinates ?? this.coordinates,
      name: name ?? this.name,
      address: address ?? this.address,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location &&
          runtimeType == other.runtimeType &&
          coordinates == other.coordinates;

  @override
  int get hashCode => coordinates.hashCode;
}
