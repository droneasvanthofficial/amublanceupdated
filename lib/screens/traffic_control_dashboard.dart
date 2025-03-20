import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ambulance_emergency_system/providers/traffic_provider.dart';
import 'package:ambulance_emergency_system/models/traffic_signal.dart';
import 'package:ambulance_emergency_system/models/roadblock.dart';

class TrafficControlDashboard extends StatefulWidget {
  const TrafficControlDashboard({super.key});

  @override
  State<TrafficControlDashboard> createState() => _TrafficControlDashboardState();
}

class _TrafficControlDashboardState extends State<TrafficControlDashboard> with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TrafficProvider>(context, listen: false);
      provider.startSimulation();
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _updateMapData() {
    final provider = Provider.of<TrafficProvider>(context, listen: false);
    
    // Update markers
    _markers.clear();
    
    // Ambulance markers
    for (var ambulance in provider.ambulances) {
      _markers.add(
        Marker(
          markerId: MarkerId(ambulance.id),
          position: ambulance.currentLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Ambulance ${ambulance.id}',
            snippet: 'Speed: ${ambulance.speed} km/h',
          ),
        ),
      );
    }
    
    // Traffic signal markers
    for (var signal in provider.trafficSignals) {
      _markers.add(
        Marker(
          markerId: MarkerId(signal.id),
          position: signal.location,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            signal.status == SignalStatus.green
                ? BitmapDescriptor.hueGreen
                : signal.status == SignalStatus.yellow
                    ? BitmapDescriptor.hueYellow
                    : BitmapDescriptor.hueRed,
          ),
          infoWindow: InfoWindow(
            title: 'Signal ${signal.id}',
            snippet: '${signal.status.toString().split('.').last} - ${signal.countdown}s',
          ),
        ),
      );
    }
    
    // Roadblock circles
    _circles.clear();
    for (var roadblock in provider.roadblocks) {
      _circles.add(
        Circle(
          circleId: CircleId(roadblock.id),
          center: roadblock.location,
          radius: 300,
          fillColor: Colors.red.withOpacity(0.3),
          strokeColor: Colors.red,
          strokeWidth: 2,
        ),
      );
    }
  }

  void _showSignalControlDialog(TrafficSignal signal) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Control Signal ${signal.id}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.green),
                title: const Text('Set to Green'),
                onTap: () {
                  Provider.of<TrafficProvider>(context, listen: false)
                      .overrideSignal(signal.id, SignalStatus.green);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.yellow),
                title: const Text('Set to Yellow'),
                onTap: () {
                  Provider.of<TrafficProvider>(context, listen: false)
                      .overrideSignal(signal.id, SignalStatus.yellow);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.red),
                title: const Text('Set to Red'),
                onTap: () {
                  Provider.of<TrafficProvider>(context, listen: false)
                      .overrideSignal(signal.id, SignalStatus.red);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showAddRoadblockDialog() {
    RoadblockType selectedType = RoadblockType.accident;
    RoadblockSeverity selectedSeverity = RoadblockSeverity.medium;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Roadblock'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Tap on the map to place a roadblock'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<RoadblockType>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Roadblock Type',
                    ),
                    items: RoadblockType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<RoadblockSeverity>(
                    value: selectedSeverity,
                    decoration: const InputDecoration(
                      labelText: 'Severity',
                    ),
                    items: RoadblockSeverity.values.map((severity) {
                      return DropdownMenuItem(
                        value: severity,
                        child: Text(severity.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedSeverity = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'type': selectedType,
                      'severity': selectedSeverity,
                    });
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    ).then((value) {
      if (value != null) {
        // Enable map tap to place roadblock
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tap on the map to place the roadblock'),
            duration: Duration(seconds: 5),
          ),
        );
        
        // We would normally set a listener for map taps here
        // For demo purposes, we'll just add a roadblock at a fixed position
        final provider = Provider.of<TrafficProvider>(context, listen: false);
        provider.addRoadblock(
          const LatLng(37.432, -122.086),
          value['type'],
          value['severity'],
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traffic Control Center'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Map View'),
            Tab(text: 'Signal Control'),
            Tab(text: 'System Logs'),
          ],
        ),
      ),
      body: Consumer<TrafficProvider>(
        builder: (context, provider, child) {
          _updateMapData();
          
          return TabBarView(
            controller: _tabController,
            children: [
              // Map View Tab
              Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(37.43, -122.08),
                      zoom: 13,
                    ),
                    markers: _markers,
                    circles: _circles,
                    mapType: MapType.normal,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'add_roadblock',
                          onPressed: _showAddRoadblockDialog,
                          backgroundColor: Colors.red,
                          child: const Icon(Icons.warning),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton(
                          heroTag: 'refresh_map',
                          onPressed: () {
                            setState(() {});
                          },
                          backgroundColor: Colors.blue,
                          child: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Signal Control Tab
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Traffic Signal Control Panel',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: provider.trafficSignals.length,
                        itemBuilder: (context, index) {
                          final signal = provider.trafficSignals[index];
                          return Card(
                            elevation: 3,
                            child: InkWell(
                              onTap: () => _showSignalControlDialog(signal),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.traffic,
                                          color: signal.status == SignalStatus.green
                                              ? Colors.green
                                              : signal.status == SignalStatus.yellow
                                                  ? Colors.amber
                                                  : Colors.red,
                                          size: 40,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          signal.id,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Status: ${signal.status.toString().split('.').last.toUpperCase()}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: signal.status == SignalStatus.green
                                            ? Colors.green
                                            : signal.status == SignalStatus.yellow
                                                ? Colors.amber
                                                : Colors.red,
                                      ),
                                    ),
                                    Text('Countdown: ${signal.countdown}s'),
                                    const SizedBox(height: 8),
                                    OutlinedButton(
                                      onPressed: () => _showSignalControlDialog(signal),
                                      child: const Text('Manual Override'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // System Logs Tab
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'System Logs',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: provider.systemLogs.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(Icons.info_outline),
                              title: Text(provider.systemLogs[index]),
                              subtitle: Text('${DateTime.now().hour}:${DateTime.now().minute}'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

