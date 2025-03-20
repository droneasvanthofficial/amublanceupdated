import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emergency_provider.dart';

class EmergencyButton extends StatelessWidget {
  const EmergencyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EmergencyProvider>(
      builder: (context, provider, _) {
        return GestureDetector(
          onTap: () => _showEmergencyOptions(context, provider),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(height: 4),
                Text(
                  'EMERGENCY ALERT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEmergencyOptions(BuildContext context, EmergencyProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              Colors.red.shade700,
              () {
                provider.sendEmergencyAlert('critical');
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
                provider.sendEmergencyAlert('equipment');
                Navigator.pop(context);
                _showAlertSentDialog(context, 'Equipment request sent to hospital');
              },
            ),
            const SizedBox(height: 12),
            _buildAlertOption(
              context,
              'Traffic Blocked',
              'Need alternative route assistance',
              Colors.blue,
              () {
                provider.sendEmergencyAlert('traffic');
                Navigator.pop(context);
                _showAlertSentDialog(context, 'Traffic alert sent to hospital');
              },
            ),
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: color),
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
        title: const Text('Alert Sent'),
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
}

