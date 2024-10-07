import 'package:dairy_harbor/main.dart';
import 'package:dairy_harbor/services_functions/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MachineryDetailsPage extends StatefulWidget {
  final String machineryId;
  final String machineryName;
  final String machineryType;
  final String machineryCondition;
  final String dateAcquired;
  final double buyCost;
  final double maintenanceCost;

  const MachineryDetailsPage({
    super.key,
    required this.machineryId,
    required this.machineryName,
    required this.machineryType,
    required this.machineryCondition,
    required this.dateAcquired,
    required this.buyCost,
    required this.maintenanceCost,
  });

  @override
  _MachineryDetailsPageState createState() => _MachineryDetailsPageState();
}

class _MachineryDetailsPageState extends State<MachineryDetailsPage> {
  late FirestoreServices _firestoreServices;

  @override
  void initState() {
    super.initState();
    _initializeFirestoreServices();
  }

  Future<void> _initializeFirestoreServices() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    final adminEmailFuture = getAdminEmailFromFirestore();

    _firestoreServices = FirestoreServices(userId, adminEmailFuture);
  }

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
                    _buildDetailRow(
                        Icons.settings, 'Name:', widget.machineryName),
                    _buildDetailRow(
                        Icons.category, 'Type:', widget.machineryType),
                    _buildDetailRow(Icons.health_and_safety, 'Condition:',
                        widget.machineryCondition),
                    _buildDetailRow(Icons.date_range, 'Date Acquired:',
                        widget.dateAcquired),
                    _buildDetailRow(Icons.monetization_on, 'Purchase Cost:',
                        'Kshs ${widget.buyCost.toStringAsFixed(2)}'),
                    _buildDetailRow(Icons.monetization_on, 'Maintenance Cost:',
                        'Kshs ${widget.maintenanceCost.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showDeleteConfirmationDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Delete',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
          Expanded(
            child: Text(
              '$label $value',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content:
              Text('Are you sure you want to delete this machinery record?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close the dialog

                try {
                  await _firestoreServices.deleteMachinery(widget.machineryId);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Machinery record deleted')),
                    );
                    Navigator.of(context).pop(); // Go back to the previous page
                  }
                } catch (e) {
                  print('Error deleting machinery: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting machinery')),
                    );
                  }
                }
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
