import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VaccinationPage extends StatefulWidget {
  @override
  _VaccinationPageState createState() => _VaccinationPageState();
}

class _VaccinationPageState extends State<VaccinationPage> {
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _vaccineNameController = TextEditingController();
  final TextEditingController _diseaseController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _doctorNameController.dispose();
    _vaccineNameController.dispose();
    _diseaseController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccination'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              _buildVaccinationForm(),
              const SizedBox(height: 16.0),
              _buildVaccinationList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVaccinationForm() {
    return Card(
      color: Colors.white,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Vaccination',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlueAccent,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildTextField('Veterinary Doctor\'s Name', _doctorNameController),
            const SizedBox(height: 10.0),
            _buildTextField('Vaccine Name', _vaccineNameController),
            const SizedBox(height: 10.0),
            _buildTextField('Disease', _diseaseController),
            const SizedBox(height: 10.0),
            _buildTextField('Cost', _costController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 10.0),
            _buildTextField('Notes', _notesController, maxLines: 3),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _submitVaccinationData();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to submit data: $e')),
                  );
                }
              },
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  Widget _buildVaccinationList() {
    return Card(
      color: Colors.white,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vaccination List',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlueAccent,
              ),
            ),
            const SizedBox(height: 16.0),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('vaccinations')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No Vaccination Records Found'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return ListTile(
                      title: Text(data['vaccine_name'] ?? 'No Name'),
                      subtitle: Text(
                          'Doctor: ${data['doctor_name'] ?? 'N/A'}\nDisease: ${data['disease'] ?? 'N/A'}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            _showEditDialog(doc.id, data);
                          } else if (value == 'delete') {
                            final shouldDelete =
                                await _showConfirmationDialog(context);
                            if (shouldDelete) {
                              try {
                                await FirebaseFirestore.instance
                                    .collection('vaccinations')
                                    .doc(doc.id)
                                    .delete();
                              } catch (e) {
                                // Handle delete failure if needed
                                Future.microtask(() {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Failed to delete record: $e'),
                                      ),
                                    );
                                  }
                                });
                              }
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(String docId, Map<String, dynamic> data) {
    final TextEditingController _doctorNameController =
        TextEditingController(text: data['doctor_name']);
    final TextEditingController _vaccineNameController =
        TextEditingController(text: data['vaccine_name']);
    final TextEditingController _diseaseController =
        TextEditingController(text: data['disease']);
    final TextEditingController _costController =
        TextEditingController(text: data['cost']);
    final TextEditingController _notesController =
        TextEditingController(text: data['notes']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Vaccination Record'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                    'Veterinary Doctor\'s Name', _doctorNameController),
                const SizedBox(height: 10.0),
                _buildTextField('Vaccine Name', _vaccineNameController),
                const SizedBox(height: 10.0),
                _buildTextField('Disease', _diseaseController),
                const SizedBox(height: 10.0),
                _buildTextField('Cost', _costController,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 10.0),
                _buildTextField('Notes', _notesController, maxLines: 3),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('vaccinations')
                      .doc(docId)
                      .update({
                    'doctor_name': _doctorNameController.text.trim(),
                    'vaccine_name': _vaccineNameController.text.trim(),
                    'disease': _diseaseController.text.trim(),
                    'cost': _costController.text.trim(),
                    'notes': _notesController.text.trim(),
                  });
                  Navigator.of(context).pop(); // Close the dialog
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Vaccination record updated')),
                    );
                  }
                } catch (e) {
                  Navigator.of(context).pop(); // Close the dialog
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update record: $e')),
                    );
                  }
                }
              },
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitVaccinationData() async {
    final doctorName = _doctorNameController.text.trim();
    final vaccineName = _vaccineNameController.text.trim();
    final disease = _diseaseController.text.trim();
    final cost = _costController.text.trim();
    final notes = _notesController.text.trim();

    if (doctorName.isNotEmpty && vaccineName.isNotEmpty && disease.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('vaccinations').add({
          'doctor_name': doctorName,
          'vaccine_name': vaccineName,
          'disease': disease,
          'cost': cost,
          'notes': notes,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Clear fields after submission
        _doctorNameController.clear();
        _vaccineNameController.clear();
        _diseaseController.clear();
        _costController.clear();
        _notesController.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Vaccination record added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add record: $e')),
          );
        }
      }
    } else {
      // Show an error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill in all required fields')),
        );
      }
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this record?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}
