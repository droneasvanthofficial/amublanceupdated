import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HospitalResourcesPanel extends StatelessWidget {
  const HospitalResourcesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hospital Resources',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          // ER Beds Status
          _buildResourceSection(
            context,
            'Emergency Room Beds',
            [
              _ResourceItem(
                name: 'Total Beds',
                value: '20',
                icon: Icons.bed,
                color: AppTheme.secondaryColor,
              ),
              _ResourceItem(
                name: 'Available',
                value: '8',
                icon: Icons.check_circle,
                color: AppTheme.accentColor,
              ),
              _ResourceItem(
                name: 'Occupied',
                value: '12',
                icon: Icons.person,
                color: Colors.orange,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Staff Status
          _buildResourceSection(
            context,
            'Staff On Duty',
            [
              _ResourceItem(
                name: 'Doctors',
                value: '5',
                icon: Icons.medical_services,
                color: Colors.purple,
              ),
              _ResourceItem(
                name: 'Nurses',
                value: '12',
                icon: Icons.health_and_safety,
                color: Colors.teal,
              ),
              _ResourceItem(
                name: 'Technicians',
                value: '4',
                icon: Icons.biotech,
                color: Colors.indigo,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Equipment Status
          _buildResourceSection(
            context,
            'Critical Equipment',
            [
              _ResourceItem(
                name: 'Ventilators',
                value: '6/10',
                icon: Icons.air,
                color: AppTheme.secondaryColor,
              ),
              _ResourceItem(
                name: 'Defibrillators',
                value: '8/8',
                icon: Icons.electric_bolt,
                color: Colors.amber,
              ),
              _ResourceItem(
                name: 'Monitors',
                value: '15/20',
                icon: Icons.monitor_heart,
                color: AppTheme.primaryColor,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Operating Rooms
          _buildResourceSection(
            context,
            'Operating Rooms',
            [
              _ResourceItem(
                name: 'Total',
                value: '5',
                icon: Icons.meeting_room,
                color: AppTheme.secondaryColor,
              ),
              _ResourceItem(
                name: 'Available',
                value: '2',
                icon: Icons.check_circle,
                color: AppTheme.accentColor,
              ),
              _ResourceItem(
                name: 'In Use',
                value: '3',
                icon: Icons.do_not_disturb_on,
                color: AppTheme.primaryColor,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Resource Management Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Show resource allocation dialog
                    _showResourceAllocationDialog(context);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Manage Resources'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResourceSection(
    BuildContext context,
    String title,
    List<_ResourceItem> items,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: items.map((item) {
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: item.color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          item.icon,
                          color: item.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        item.value,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: item.color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showResourceAllocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resource Allocation'),
        content: const Text(
          'Adjust resource allocation for incoming emergency?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Resources allocated for incoming emergency')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Allocate'),
          ),
        ],
      ),
    );
  }
}

class _ResourceItem {
  final String name;
  final String value;
  final IconData icon;
  final Color color;

  _ResourceItem({
    required this.name,
    required this.value,
    required this.icon,
    required this.color,
  });
}

