import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../providers/emergency_provider.dart';
import '../widgets/map_view.dart';
import '../widgets/route_info.dart';
import '../theme/app_theme.dart';

class AmbulanceDashboard extends StatefulWidget {
  const AmbulanceDashboard({super.key});

  @override
  State<AmbulanceDashboard> createState() => _AmbulanceDashboardState();
}

class _AmbulanceDashboardState extends State<AmbulanceDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  bool _isPanelExpanded = false;
  bool _isEmergencyMode = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Start location tracking when dashboard loads
    Future.microtask(() {
      Provider.of<LocationProvider>(context, listen: false).startTracking();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _togglePanel() {
    setState(() {
      _isPanelExpanded = !_isPanelExpanded;
      if (_isPanelExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }
  
  void _toggleEmergencyMode() {
    setState(() {
      _isEmergencyMode = !_isEmergencyMode;
    });
    
    if (_isEmergencyMode) {
      _showEmergencyOptions();
    }
  }
  
  void _showEmergencyOptions() {
    final emergencyProvider = Provider.of<EmergencyProvider>(context, listen: false);
    
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
            const Text(
              'Send Emergency Alert',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildAlertOption(
              context,
              'Critical Patient',
              'Patient requires immediate attention',
              AppTheme.primaryColor,
              () {
                emergencyProvider.sendEmergencyAlert('critical');
                Navigator.pop(context);
                _showAlertSentDialog(context, 'Critical alert sent to hospital');
              },
            ),
            const SizedBox(height: 12),
            _buildAlertOption(
              context,
              'Equipment Needed',
              'Special equipment required on arrival',
              Colors.orange,
              () {
                emergencyProvider.sendEmergencyAlert('equipment');
                Navigator.pop(context);
                _showAlertSentDialog(context, 'Equipment request sent to hospital');
              },
            ),
            const SizedBox(height: 12),
            _buildAlertOption(
              context,
              'Traffic Blocked',
              'Need alternative route assistance',
              AppTheme.secondaryColor,
              () {
                emergencyProvider.sendEmergencyAlert('traffic');
                Navigator.pop(context);
                _showAlertSentDialog(context, 'Traffic alert sent to hospital');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAlertOption(
    BuildContext context,
    String title,
    String subtitle,
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
              child: Icon(Icons.warning_amber_rounded, color: color),
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
  
  void _showAlertSentDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.accentColor),
            const SizedBox(width: 8),
            const Text('Alert Sent'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showCommunicationDialog(BuildContext context) {
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
            const Text(
              'Contact Hospital',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildCommunicationOption(
              context,
              'Voice Call',
              'Direct voice communication with hospital',
              Icons.phone,
              AppTheme.secondaryColor,
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
              Colors.purple,
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
              'Send Message',
              'Text communication with hospital',
              Icons.message,
              AppTheme.accentColor,
              () {
                Navigator.pop(context);
                _showSendMessageDialog(context);
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
  
  void _showSendMessageDialog(BuildContext context) {
    final textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Message to Hospital'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Type your message here...',
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
                // Send message
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message sent to hospital')),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    ).then((_) => textController.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambulance Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Show notifications
            },
          ),
        ],
      ),
      body: Consumer<EmergencyProvider>(
        builder: (context, emergencyProvider, _) {
          return Stack(
            children: [
              // Main content
              Column(
                children: [
                  // Map view takes most of the screen
                  const Expanded(
                    flex: 6,
                    child: MapView(userType: 'ambulance'),
                  ),
                  
                  // Route information panel
                  const Expanded(
                    flex: 2,
                    child: RouteInfo(),
                  ),
                ],
              ),
              
              // Bottom action panel (slides up when expanded)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, (1 - _slideAnimation.value) * 180),
                      child: child,
                    );
                  },
                  child: Container(
                    height: 240,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Handle for dragging
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        
                        // Status
                        Text(
                          'Status: ${emergencyProvider.currentStatus}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Action buttons
                        Row(
                          children: [
                            // Emergency alert button
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.warning_amber_rounded,
                                label: 'EMERGENCY ALERT',
                                color: _isEmergencyMode
                                    ? Colors.red.shade800
                                    : AppTheme.primaryColor,
                                onTap: _toggleEmergencyMode,
                                isActive: _isEmergencyMode,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Communication panel
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.call,
                                label: 'CONTACT HOSPITAL',
                                color: AppTheme.secondaryColor,
                                onTap: () => _showCommunicationDialog(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Additional actions
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // Toggle tracking
                                  final locationProvider = Provider.of<LocationProvider>(
                                    context,
                                    listen: false,
                                  );
                                  if (locationProvider.isTracking) {
                                    locationProvider.stopTracking();
                                  } else {
                                    locationProvider.startTracking();
                                  }
                                },
                                icon: Consumer<LocationProvider>(
                                  builder: (context, provider, _) {
                                    return Icon(
                                      provider.isTracking
                                          ? Icons.gps_fixed
                                          : Icons.gps_off,
                                    );
                                  },
                                ),
                                label: Consumer<LocationProvider>(
                                  builder: (context, provider, _) {
                                    return Text(
                                      provider.isTracking
                                          ? 'Stop Tracking'
                                          : 'Start Tracking',
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // Clear route
                                  Provider.of<LocationProvider>(
                                    context,
                                    listen: false,
                                  ).clearRoute();
                                },
                                icon: const Icon(Icons.clear_all),
                                label: const Text('Clear Route'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Toggle button for panel
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _togglePanel,
                  child: Container(
                    height: 24,
                    color: Colors.transparent,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? color : color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

