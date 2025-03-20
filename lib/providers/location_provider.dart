import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationProvider extends ChangeNotifier {
  double _latitude = 37.7749;
  double _longitude = -122.4194;
  bool _isTracking = false;
  StreamSubscription<Position>? _positionStream;
  
  // For storing route
  List<LatLng> _routePoints = [];
  
  // For map control
  double _zoom = 15.0;
  bool _followUser = true;

  double get latitude => _latitude;
  double get longitude => _longitude;
  bool get isTracking => _isTracking;
  List<LatLng> get routePoints => _routePoints;
  LatLng get currentLocation => LatLng(_latitude, _longitude);
  double get zoom => _zoom;
  bool get followUser => _followUser;
  
  void setZoom(double zoom) {
    _zoom = zoom;
    notifyListeners();
  }
  
  void setFollowUser(bool follow) {
    _followUser = follow;
    notifyListeners();
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      return false;
    }
    
    // Permissions are granted
    return true;
  }

  Future<void> startTracking() async {
    if (!await _handleLocationPermission()) {
      return;
    }
    
    _isTracking = true;
    
    // Get current position first
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      _updatePosition(position);
      
      // Start listening to location updates
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).listen(_updatePosition);
      
      notifyListeners();
    } catch (e) {
      _isTracking = false;
      print("Error getting location: $e");
    }
  }

  void _updatePosition(Position position) {
    _latitude = position.latitude;
    _longitude = position.longitude;
    
    // Add point to route
    _routePoints.add(LatLng(_latitude, _longitude));
    
    // If we have too many points, remove older ones
    if (_routePoints.length > 100) {
      _routePoints.removeAt(0);
    }
    
    notifyListeners();
  }

  void stopTracking() {
    _isTracking = false;
    _positionStream?.cancel();
    notifyListeners();
  }

  void updateLocation(double latitude, double longitude) {
    _latitude = latitude;
    _longitude = longitude;
    notifyListeners();
  }
  
  void clearRoute() {
    _routePoints.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}

