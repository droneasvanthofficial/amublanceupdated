import 'package:google_maps_flutter/google_maps_flutter.dart';

enum SignalStatus {
  red,
  yellow,
  green,
}

class TrafficSignal {
  final String id;
  final LatLng location;
  SignalStatus status;
  int countdown; // seconds

  TrafficSignal({
    required this.id,
    required this.location,
    required this.status,
    required this.countdown,
  });
}

