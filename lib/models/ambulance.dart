import 'package:google_maps_flutter/google_maps_flutter.dart';

enum AmbulanceStatus {
  active,
  idle,
  maintenance,
}

class Ambulance {
  final String id;
  final String driverId;
  LatLng currentLocation;
  final LatLng destination;
  AmbulanceStatus status;
  int speed; // km/h

  Ambulance({
    required this.id,
    required this.driverId,
    required this.currentLocation,
    required this.destination,
    required this.status,
    required this.speed,
  });
}

