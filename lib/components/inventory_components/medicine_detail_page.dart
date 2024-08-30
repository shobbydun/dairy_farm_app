import 'package:dairy_harbor/services_functions/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicineDetailPage extends StatefulWidget {
  final String medicineId;

  const MedicineDetailPage({super.key, required this.medicineId});

  @override
  _MedicineDetailPageState createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends State<MedicineDetailPage> {
  late FirestoreServices _firestoreServices;
  Map<String, dynamic>? _medicine;

  @override
  void initState() {
    super.initState();
    _firestoreServices = FirestoreServices(FirebaseAuth.instance.currentUser!.uid);
    _fetchMedicineDetails();
  }

  Future<void> _fetchMedicineDetails() async {
    try {
      final medicines = await _firestoreServices.getMedicines();
      final medicine = medicines.firstWhere((med) => med['id'] == widget.medicineId);
      setState(() {
        _medicine = medicine;
      });
    } catch (e) {
      print('Error fetching medicine details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_medicine == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Medicine Details'),
          backgroundColor: Colors.blueAccent,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name = _medicine!['name'];
    final quantity = _medicine!['quantity'];
    final expiryDate = _medicine!['expiryDate'];
    final supplier = _medicine!['supplier'];

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
                    _buildDetailRow(Icons.confirmation_number, 'Quantity:', quantity),
                    _buildDetailRow(Icons.calendar_today, 'Expiry Date:', expiryDate),
                    _buildDetailRow(Icons.store, 'Supplier:', supplier),
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
