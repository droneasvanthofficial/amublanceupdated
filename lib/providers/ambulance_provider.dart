import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ambulance_emergency_system/models/traffic_signal.dart';
import 'package:ambulance_emergency_system/models/ambulance.dart';

class AmbulanceProvider extends ChangeNotifier {
  // Mock ambulance data
  final Ambulance ambulance = Ambulance(
    id: 'AMB-001',
    driverId: 'DRV-001',
    currentLocation: const LatLng(37.42796133580664, -122.085749655962),
    destination: const LatLng(37.43796133580664, -122.095749655962),
    status: AmbulanceStatus.active,
    speed: 60,
  );

  // Mock route polyline
  final List<LatLng> routePoints = [
    const LatLng(37.42796133580664, -122.085749655962),
    const LatLng(37.428, -122.087),
    const LatLng(37.429, -122.089),
    const LatLng(37.431, -122.091),
    const LatLng(37.433, -122.093),
    const LatLng(37.435, -122.094),
    const LatLng(37.43796133580664, -122.095749655962),
  ];

  // Mock traffic signals
  final List<TrafficSignal> trafficSignals = [
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
  ];

  // ETA in minutes
  int estimatedTimeOfArrival = 8;
  
  // Distance in kilometers
  double distanceToDestination = 2.5;
  
  // Mock voice alerts
  List<String> recentAlerts = [];

  // Simulate ambulance movement
  int currentRouteIndex = 0;
  Timer? _timer;

  void startSimulation() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (currentRouteIndex < routePoints.length - 1) {
        currentRouteIndex++;
        ambulance.currentLocation = routePoints[currentRouteIndex];
        
        // Update ETA and distance
        estimatedTimeOfArrival = 8 - ((currentRouteIndex / (routePoints.length - 1)) * 8).round();
        distanceToDestination = 2.5 - ((currentRouteIndex / (routePoints.length - 1)) * 2.5);
        
        // Update traffic signals
        for (var signal in trafficSignals) {
          signal.countdown = signal.countdown > 0 ? signal.countdown - 2 : 30;
          if (signal.countdown <= 0) {
            signal.status = signal.status == SignalStatus.green 
                ? SignalStatus.red 
                : SignalStatus.green;
          }
        }
        
        notifyListeners();
      } else {
        _timer?.cancel();
      }
    });
  }

  void sendVoiceAlert(String message) {
    recentAlerts.add(message);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

