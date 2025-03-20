import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key, required String userType}) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late final MapController _mapController;
  static const LatLng _defaultLocation = LatLng(37.7749, -122.4194); // Default to San Francisco

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  void _zoomIn() {
    final newZoom = _mapController.zoom + 1.0;
    _mapController.move(_mapController.center, newZoom);
  }

  void _zoomOut() {
    final newZoom = _mapController.zoom - 1.0;
    _mapController.move(_mapController.center, newZoom);
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final LatLng currentLocation = locationProvider.currentLocation ?? _defaultLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Map View"),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: currentLocation,
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.ambulance.emergency',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: currentLocation,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _zoomIn,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _zoomOut,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
