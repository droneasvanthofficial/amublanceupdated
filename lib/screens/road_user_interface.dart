import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ambulance_emergency_system/providers/ambulance_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';

class RoadUserInterface extends StatefulWidget {
  const RoadUserInterface({super.key});

  @override
  State<RoadUserInterface> createState() => _RoadUserInterfaceState();
}

class _RoadUserInterfaceState extends State<RoadUserInterface> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Set<Circle> _circles = {};
  final FlutterTts _flutterTts = FlutterTts();
  bool _ambulanceNearby = false;
  bool _showAlternateRoute = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AmbulanceProvider>(context, listen: false);
      provider.startSimulation();
      _initTts();
      
      // Simulate ambulance approaching after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          _ambulanceNearby = true;
        });
        _showAmbulanceAlert();
      });
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _updateMapData() {
    final provider = Provider.of<AmbulanceProvider>(context, listen: false);
    
    // Update markers
    _markers.clear();
    
    // User location (mock)
    _markers.add(
      Marker(
        markerId: MarkerId('user'),
        position: LatLng(37.428, -122.087),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(title: 'Your Location'),
      ),
    );
    
    // Ambulance marker
    _markers.add(
      Marker(
        markerId: const MarkerId('ambulance'),
        position: provider.ambulance.currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Ambulance'),
      ),
    );
    
    // Ambulance proximity circle
    _circles.clear();
    _circles.add(
      Circle(
        circleId: const CircleId('ambulance_range'),
        center: provider.ambulance.currentLocation,
        radius: 500,
        fillColor: Colors.red.withOpacity(0.1),
        strokeColor: Colors.red.withOpacity(0.5),
        strokeWidth: 2,
      ),
    );
    
    // Main route
    _polylines.clear();
    _polylines.add(
      const Polyline(
        polylineId: PolylineId('main_route'),
        points: [
          LatLng(37.428, -122.087),
          LatLng(37.429, -122.089),
          LatLng(37.431, -122.091),
          LatLng(37.433, -122.093),
        ],
        color: Colors.blue,
        width: 5,
      ),
    );
    
    // Alternate route (shown when ambulance is nearby)
    if (_showAlternateRoute) {
      _polylines.add(
        Polyline(
          polylineId: PolylineId('alternate_route'),
          points: [
            LatLng(37.428, -122.087),
            LatLng(37.427, -122.090),
            LatLng(37.429, -122.094),
            LatLng(37.433, -122.093),
          ],
          color: Colors.green,
          width: 5,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );
    }
  }

  void _showAmbulanceAlert() {
    // Show alert dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 8),
              const Text('EMERGENCY ALERT'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ambulance Approaching!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text('Please move to the side of the road to allow the ambulance to pass.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _showAlternateRoute = true;
                });
                _flutterTts.speak("Ambulance approaching. Please move to the side of the road. Alternative route suggested.");
              },
              child: const Text('Show Alternative Route'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _flutterTts.speak("Ambulance approaching. Please move to the side of the road.");
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Road User Interface'),
        backgroundColor: _ambulanceNearby ? Colors.red : null,
      ),
      body: Consumer<AmbulanceProvider>(
        builder: (context, provider, child) {
          _updateMapData();
          
          return Stack(
            children: [
              // Map
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(37.428, -122.087),
                  zoom: 15,
                ),
                markers: _markers,
                polylines: _polylines,
                circles: _circles,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                mapType: MapType.normal,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
              ),
              
              // Ambulance alert banner
              if (_ambulanceNearby)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.white),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Ambulance Approaching! Move to Side',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.volume_up, color: Colors.white),
                          onPressed: () {
                            _flutterTts.speak("Ambulance approaching. Please move to the side of the road.");
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Route info panel
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Your Route',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.circle, color: Colors.blue, size: 16),
                            const SizedBox(width: 8),
                            const Text('Current Route'),
                            const Spacer(),
                            const Text('ETA: 12 min'),
                          ],
                        ),
                        if (_showAlternateRoute) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.circle, color: Colors.green, size: 16),
                              const SizedBox(width: 8),
                              const Text('Alternative Route'),
                              const Spacer(),
                              const Text('ETA: 14 min'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Alternative route suggested to avoid emergency vehicle',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.red,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        if (_showAlternateRoute)
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _showAlternateRoute = false;
                                    });
                                  },
                                  child: const Text('Keep Current Route'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Alternative route selected'),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Use Alternative'),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

