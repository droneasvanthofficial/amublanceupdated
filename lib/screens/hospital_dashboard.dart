import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emergency_provider.dart';
import '../widgets/map_view.dart';
import '../widgets/ambulance_status_card.dart';
import '../widgets/patient_info_panel.dart';
import '../widgets/hospital_resources_panel.dart';
import '../theme/app_theme.dart';

class HospitalDashboard extends StatefulWidget {
  const HospitalDashboard({super.key});

  @override
  State<HospitalDashboard> createState() => _HospitalDashboardState();
}

class _HospitalDashboardState extends State<HospitalDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize emergency data
    Future.microtask(() {
      Provider.of<EmergencyProvider>(context, listen: false).fetchActiveEmergencies();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Active Ambulances'),
            Tab(text: 'Patient Info'),
            Tab(text: 'Resources'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active Ambulances Tab
          _buildAmbulancesTab(),
          
          // Patient Info Tab
          const PatientInfoPanel(),
          
          // Resources Tab
          const HospitalResourcesPanel(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCommunicationOptions(context);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.call, color: Colors.white),
      ),
    );
  }

  Widget _buildAmbulancesTab() {
    return Column(
      children: [
        // Map showing all ambulances
        const Expanded(
          flex: 5,
          child: MapView(userType: 'hospital'),
        ),
        
        // List of active ambulances
        Expanded(
          flex: 5,
          child: Consumer<EmergencyProvider>(
            builder: (context, provider, _) {
              if (provider.activeEmergencies.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_shipping,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No active ambulances at the moment',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.activeEmergencies.length,
                itemBuilder: (context, index) {
                  final emergency = provider.activeEmergencies[index];
                  return AmbulanceStatusCard(
                    ambulanceId: emergency.ambulanceId,
                    patientCondition: emergency.patientCondition,
                    eta: emergency.eta,
                    distance: emergency.distance,
                    onTap: () {
                      provider.selectEmergency(emergency.id);
                      _tabController.animateTo(1); // Switch to patient info tab
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCommunicationOptions(BuildContext context) {
    final emergencyProvider = Provider.of<EmergencyProvider>(context, listen: false);
    
    if (emergencyProvider.selectedEmergency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an ambulance first')),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Contact Ambulance ${emergencyProvider.selectedEmergency!.ambulanceId}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildCommunicationOption(
              context,
              'Voice Call',
              'Direct voice communication with ambulance',
              Icons.phone,
              AppTheme.primaryColor,
              () {
                Navigator.pop(context);
                // Initiate voice call
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Initiating voice call...')),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildCommunicationOption(
              context,
              'Video Call',
              'Video communication for visual assistance',
              Icons.videocam,
              AppTheme.secondaryColor,
              () {
                Navigator.pop(context);
                // Initiate video call
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Initiating video call...')),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildCommunicationOption(
              context,
              'Send Instructions',
              'Send detailed instructions to ambulance team',
              Icons.message,
              AppTheme.accentColor,
              () {
                Navigator.pop(context);
                _showSendInstructionsDialog(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCommunicationOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  void _showSendInstructionsDialog(BuildContext context) {
    final textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Instructions'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Enter instructions for ambulance team',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                // Send instructions
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Instructions sent successfully')),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    ).then((_) => textController.dispose());
  }
}

