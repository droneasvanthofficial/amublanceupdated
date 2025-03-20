import 'package:google_maps_flutter/google_maps_flutter.dart';

enum RoadblockType {
  accident,
  construction,
  congestion,
  event,
}

enum RoadblockSeverity {
  low,
  medium,
  high,
}

class Roadblock {
  final String id;
  final LatLng location;
  final RoadblockType type;
  final RoadblockSeverity severity;

  Roadblock({
    required this.id,
    required this.location,
    required this.type,
    required this.severity,
  });
}

