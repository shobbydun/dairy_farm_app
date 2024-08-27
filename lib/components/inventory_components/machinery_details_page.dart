import 'package:flutter/material.dart';

class MachineryDetailsPage extends StatelessWidget {
  final String machineryName;
  final String machineryType;
  final String machineryCondition;
  final String dateAcquired;

  const MachineryDetailsPage({
    super.key,
    required this.machineryName,
    required this.machineryType,
    required this.machineryCondition,
    required this.dateAcquired,
  });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Machinery Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card for Machinery Details
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(Icons.settings, 'Name:', machineryName),
                    _buildDetailRow(Icons.category, 'Type:', machineryType),
                    _buildDetailRow(Icons.health_and_safety, 'Condition:', machineryCondition),
                    _buildDetailRow(Icons.date_range, 'Date Acquired:', dateAcquired),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Back Button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Back',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          SizedBox(width: 10),
          Text(
            '$label $value',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
