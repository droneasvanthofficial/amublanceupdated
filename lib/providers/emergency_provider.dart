import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Emergency {
  final String id;
  final String ambulanceId;
  final String patientCondition;
  final String eta;
  final String distance;
  final LatLng location;
  final String patientName;
  final String patientAge;
  final String patientGender;
  final Map<String, dynamic> vitalSigns;

  Emergency({
    required this.id,
    required this.ambulanceId,
    required this.patientCondition,
    required this.eta,
    required this.distance,
    required this.location,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.vitalSigns,
  });
}

class EmergencyProvider extends ChangeNotifier {
  final List<Emergency> _activeEmergencies = [];
  Emergency? _selectedEmergency;
  String _currentStatus = 'On Duty';
  Timer? _updateTimer;

  List<Emergency> get activeEmergencies => _activeEmergencies;
  Emergency? get selectedEmergency => _selectedEmergency;
  String get currentStatus => _currentStatus;

  EmergencyProvider() {
    // Start a timer to periodically update emergency data (simulating real-time updates)
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updateEmergencyData();
    });
  }

  void fetchActiveEmergencies() {
    // In a real app, this would fetch data from an API
    // For this demo, we'll add some mock data
    _activeEmergencies.clear();
    _activeEmergencies.addAll([
      Emergency(
        id: '1',
        ambulanceId: 'A-101',
        patientCondition: 'Critical',
        eta: '5 min',
        distance: '2.3 km',
        location: LatLng(37.7749 + 0.01, -122.4194 - 0.01),
        patientName: 'John Doe',
        patientAge: '45',
        patientGender: 'Male',
        vitalSigns: {
          'heartRate': '95',
          'bloodPressure': '140/90',
          'oxygenSaturation': '94',
          'temperature': '38.2',
        },
      ),
      Emergency(
        id: '2',
        ambulanceId: 'A-102',
        patientCondition: 'Stable',
        eta: '12 min',
        distance: '5.8 km',
        location: LatLng(37.7749 - 0.02, -122.4194 + 0.02),
        patientName: 'Jane Smith',
        patientAge: '32',
        patientGender: 'Female',
        vitalSigns: {
          'heartRate': '78',
          'bloodPressure': '120/80',
          'oxygenSaturation': '98',
          'temperature': '36.8',
        },
      ),
      Emergency(
        id: '3',
        ambulanceId: 'A-103',
        patientCondition: 'Serious',
        eta: '8 min',
        distance: '3.5 km',
        location: LatLng(37.7749 + 0.015, -122.4194 + 0.015),
        patientName: 'Robert Johnson',
        patientAge: '67',
        patientGender: 'Male',
        vitalSigns: {
          'heartRate': '88',
          'bloodPressure': '150/95',
          'oxygenSaturation': '92',
          'temperature': '37.5',
        },
      ),
    ]);
    notifyListeners();
  }

  void _updateEmergencyData() {
    // Simulate changes in ETA and distance
    for (var i = 0; i < _activeEmergencies.length; i++) {
      final emergency = _activeEmergencies[i];
      
      // Parse current ETA and reduce it
      final etaParts = emergency.eta.split(' ');
      if (etaParts.length == 2 && etaParts[1] == 'min') {
        final etaMinutes = int.tryParse(etaParts[0]);
        if (etaMinutes != null && etaMinutes > 1) {
          final newEta = '${etaMinutes - 1} min';
          
          // Parse current distance and reduce it
          final distanceParts = emergency.distance.split(' ');
          if (distanceParts.length == 2 && distanceParts[1] == 'km') {
            final distanceKm = double.tryParse(distanceParts[0]);
            if (distanceKm != null && distanceKm > 0.5) {
              final newDistance = '${(distanceKm - 0.5).toStringAsFixed(1)} km';
              
              // Create updated emergency
              final updatedEmergency = Emergency(
                id: emergency.id,
                ambulanceId: emergency.ambulanceId,
                patientCondition: emergency.patientCondition,
                eta: newEta,
                distance: newDistance,
                location: emergency.location,
                patientName: emergency.patientName,
                patientAge: emergency.patientAge,
                patientGender: emergency.patientGender,
                vitalSigns: emergency.vitalSigns,
              );
              
              // Replace the emergency in the list
              _activeEmergencies[i] = updatedEmergency;
              
              // Update selected emergency if needed
              if (_selectedEmergency?.id == emergency.id) {
                _selectedEmergency = updatedEmergency;
              }
            }
          }
        }
      }
    }
    
    notifyListeners();
  }

  void selectEmergency(String id) {
    _selectedEmergency = _activeEmergencies.firstWhere(
      (emergency) => emergency.id == id,
      orElse: () => _activeEmergencies.first,
    );
    notifyListeners();
  }

  void sendEmergencyAlert(String type) {
    // In a real app, this would send an alert to the server
    // For this demo, we'll just update the status
    switch (type) {
      case 'critical':
        _currentStatus = 'Critical Patient Alert Sent';
        break;
      case 'equipment':
        _currentStatus = 'Equipment Request Sent';
        break;
      case 'traffic':
        _currentStatus = 'Traffic Alert Sent';
        break;
      default:
        _currentStatus = 'Alert Sent';
    }
    notifyListeners();
  }

  void updateEmergencyStatus(String id, String newStatus) {
    final index = _activeEmergencies.indexWhere((e) => e.id == id);
    if (index != -1) {
      // In a real app, we would update the emergency object
      // For this demo, we'll just notify listeners
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}

