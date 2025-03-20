import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ambulance_emergency_system/models/traffic_signal.dart';
import 'package:ambulance_emergency_system/models/ambulance.dart';
import 'package:ambulance_emergency_system/models/roadblock.dart';

class TrafficProvider extends ChangeNotifier {
  // Mock ambulances
  List<Ambulance> ambulances = [
    Ambulance(
      id: 'AMB-001',
      driverId: 'DRV-001',
      currentLocation: const LatLng(37.42796133580664, -122.085749655962),
      destination: const LatLng(37.43796133580664, -122.095749655962),
      status: AmbulanceStatus.active,
      speed: 60,
    ),
    Ambulance(
      id: 'AMB-002',
      driverId: 'DRV-002',
      currentLocation: const LatLng(37.44796133580664, -122.075749655962),
      destination: const LatLng(37.41796133580664, -122.065749655962),
      status: AmbulanceStatus.active,
      speed: 55,
    ),
  ];

  // Mock traffic signals
  List<TrafficSignal> trafficSignals = [
    TrafficSignal(
      id: 'TS-001',
      location: const LatLng(37.429, -122.089),
      status: SignalStatus.green,
      countdown: 30,
    ),
    TrafficSignal(
      id: 'TS-002',
      location: const LatLng(37.433, -122.093),
      status: SignalStatus.red,
      countdown: 15,
    ),
    TrafficSignal(
      id: 'TS-003',
      location: const LatLng(37.425, -122.082),
      status: SignalStatus.yellow,
      countdown: 5,
    ),
    TrafficSignal(
      id: 'TS-004',
      location: const LatLng(37.438, -122.078),
      status: SignalStatus.red,
      countdown: 20,
    ),
  ];

  // Mock roadblocks
  List<Roadblock> roadblocks = [
    Roadblock(
      id: 'RB-001',
      location: const LatLng(37.435, -122.088),
      type: RoadblockType.accident,
      severity: RoadblockSeverity.high,
    ),
  ];

  // System logs
  List<String> systemLogs = [
    'System initialized at 10:00 AM',
    'Ambulance AMB-001 dispatched to Memorial Hospital',
    'Traffic signal TS-001 set to green corridor mode',
  ];

  Timer? _timer;
  final Random _random = Random();

  void startSimulation() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // Update ambulance positions
      for (var ambulance in ambulances) {
        if (ambulance.status == AmbulanceStatus.active) {
          // Simulate movement
          final lat = ambulance.currentLocation.latitude + (_random.nextDouble() * 0.002 - 0.001);
          final lng = ambulance.currentLocation.longitude + (_random.nextDouble() * 0.002 - 0.001);
          ambulance.currentLocation = LatLng(lat, lng);
        }
      }

      // Update traffic signals
      for (var signal in trafficSignals) {
        signal.countdown = signal.countdown > 0 ? signal.countdown - 3 : 30;
        if (signal.countdown <= 0) {
          if (signal.status == SignalStatus.green) {
            signal.status = SignalStatus.yellow;
            signal.countdown = 5;
          } else if (signal.status == SignalStatus.yellow) {
            signal.status = SignalStatus.red;
            signal.countdown = 30;
          } else {
            signal.status = SignalStatus.green;
            signal.countdown = 30;
          }
        }
      }

      // Add random system log
      if (_random.nextInt(3) == 0) {
        final logMessages = [
          'Traffic congestion detected on Main Street',
          'Ambulance AMB-002 approaching Hospital Zone',
          'Signal TS-003 manually overridden',
          'New roadblock reported at Downtown intersection',
        ];
        systemLogs.insert(0, logMessages[_random.nextInt(logMessages.length)]);
      }

      notifyListeners();
    });
  }

  void overrideSignal(String signalId, SignalStatus newStatus) {
    final signal = trafficSignals.firstWhere((s) => s.id == signalId);
    signal.status = newStatus;
    signal.countdown = 30;
    
    systemLogs.insert(0, 'Signal $signalId manually set to ${newStatus.toString().split('.').last}');
    notifyListeners();
  }

  void addRoadblock(LatLng location, RoadblockType type, RoadblockSeverity severity) {
    final id = 'RB-${roadblocks.length + 1}';
    roadblocks.add(Roadblock(
      id: id,
      location: location,
      type: type,
      severity: severity,
    ));
    
    systemLogs.insert(0, 'New ${severity.toString().split('.').last} severity roadblock added');
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

