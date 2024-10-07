import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MedicineDetailPage extends StatefulWidget {
  final String medicineId;
  final Future<String?> adminEmailFuture;

  const MedicineDetailPage({
    super.key,
    required this.medicineId,
    required this.adminEmailFuture,
  });

  @override
  _MedicineDetailPageState createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends State<MedicineDetailPage> {
  Map<String, dynamic>? _medicine;
  String? _adminEmail;

  @override
  void initState() {
    super.initState();
    _fetchAdminEmail();
    _fetchMedicineDetails();
  }

  Future<void> _fetchAdminEmail() async {
    _adminEmail = await widget.adminEmailFuture;
    setState(() {
      _fetchMedicineDetails(); // Move this call inside setState to ensure it's called after email fetch
    });
  }

  Future<void> _fetchMedicineDetails() async {
    if (_adminEmail != null) {
      print("Admin Email: $_adminEmail");
      try {
        final medicineDoc = await FirebaseFirestore.instance
            .collection('medicines')
            .doc(_adminEmail)
            .collection('entries')
            .doc(widget.medicineId)
            .get();

        if (medicineDoc.exists) {
          print("Medicine found: ${medicineDoc.data()}");
          setState(() {
            _medicine = medicineDoc.data();
          });
        } else {
          print('Medicine not found');
        }
      } catch (e) {
        print('Error fetching medicine details: $e');
      }
    } else {
      print("Admin email is null");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_medicine == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Medicine Details'),
          backgroundColor: Colors.blueAccent,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Check if medicine data is empty
    if (_medicine!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Medicine Details'),
          backgroundColor: Colors.blueAccent,
        ),
        body: Center(child: Text('No details available for this medicine.')),
      );
    }

    // Data available, proceed to display
    final name = _medicine!['name'] ?? 'N/A';
    final quantity = _medicine!['quantity']?.toString() ?? 'N/A';
    final expiryDate = _medicine!['expiryDate'] ?? 'N/A';
    final supplier = _medicine!['supplier'] ?? 'N/A';
    final cost = _medicine!['cost']?.toStringAsFixed(2) ?? '0.00';

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
                    _buildDetailRow(
                        Icons.confirmation_number, 'Quantity:', quantity),
                    _buildDetailRow(
                        Icons.calendar_today, 'Expiry Date:', expiryDate),
                    _buildDetailRow(Icons.store, 'Supplier:', supplier),
                    _buildDetailRow(Icons.money, 'Cost:', '\Kshs $cost'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
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

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          SizedBox(width: 10),
          Text(
            '$label ${value ?? 'N/A'}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
