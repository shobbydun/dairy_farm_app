import 'package:flutter/material.dart';

class MedicineDetailPage extends StatelessWidget {
  final String medicineId; // ID or some identifier to fetch medicine details

  const MedicineDetailPage({super.key, required this.medicineId});

  @override
  Widget build(BuildContext context) {
    // medicine details using medicineId
   
    final String name = 'Sample Medicine';
    final String quantity = '10 tablets';
    final String expiryDate = '2025-12-01';
    final String supplier = 'Sample Supplier';

    return Scaffold(

      appBar: AppBar(
        title: Text('Medicine Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card for Medicine Details
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
                    _buildDetailRow(Icons.medical_services, 'Name:', name),
                    _buildDetailRow(Icons.confirmation_number, 'Quantity:', quantity),
                    _buildDetailRow(Icons.calendar_today, 'Expiry Date:', expiryDate),
                    _buildDetailRow(Icons.store, 'Supplier:', supplier),
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
                'Back to List',
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
