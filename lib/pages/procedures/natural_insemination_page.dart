import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NaturalInseminationPage extends StatefulWidget {
  @override
  _NaturalInseminationPageState createState() => _NaturalInseminationPageState();
}

class _NaturalInseminationPageState extends State<NaturalInseminationPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _cattleIdController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  String? _selectedBreed;

  void _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _submitRecord() async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('natural_insemination').add({
        'date': _dateController.text,
        'cattle_id': _cattleIdController.text,
        'father_breed': _selectedBreed,
        'notes': _notesController.text,
        'cost': _costController.text,
      });

      _resetFields();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Record added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add record: $e')),
      );
    }
  }

  void _resetFields() {
    _dateController.clear();
    _cattleIdController.clear();
    _notesController.clear();
    _costController.clear();
    setState(() {
      _selectedBreed = null;
    });
  }

  void _showAddInseminationDialog(BuildContext context) {
    _resetFields(); // Ensure fields are empty when opening dialog

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Insemination Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Date of Insemination',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  keyboardType: TextInputType.datetime,
                  readOnly: true,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _cattleIdController,
                  decoration: InputDecoration(labelText: 'Cattle ID'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Father's Breed"),
                  value: _selectedBreed,
                  items: ['Holstein Friesian', 'Jersey', 'Guernsey', 'Brown Swiss', 'Ayrshire']
                      .map((breed) => DropdownMenuItem(
                            value: breed,
                            child: Text(breed),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBreed = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(labelText: 'Notes'),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _costController,
                  decoration: InputDecoration(labelText: 'Cost'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _submitRecord();
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showEditInseminationDialog(BuildContext context, String docId, Map<String, dynamic> data) {
    _dateController.text = data['date'];
    _cattleIdController.text = data['cattle_id'];
    _notesController.text = data['notes'];
    _costController.text = data['cost'];
    _selectedBreed = data['father_breed'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Insemination Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Date of Insemination',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  keyboardType: TextInputType.datetime,
                  readOnly: true,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _cattleIdController,
                  decoration: InputDecoration(labelText: 'Cattle ID'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Father's Breed"),
                  value: _selectedBreed,
                  items: ['Holstein Friesian', 'Jersey', 'Guernsey', 'Brown Swiss', 'Ayrshire']
                      .map((breed) => DropdownMenuItem(
                            value: breed,
                            child: Text(breed),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBreed = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(labelText: 'Notes'),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _costController,
                  decoration: InputDecoration(labelText: 'Cost'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('natural_insemination').doc(docId).update({
                    'date': _dateController.text,
                    'cattle_id': _cattleIdController.text,
                    'father_breed': _selectedBreed,
                    'notes': _notesController.text,
                    'cost': _costController.text,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Record updated successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update record: $e')),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(String docId) async {
    final bool? confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this record?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('natural_insemination').doc(docId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Record deleted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete record: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Natural Insemination'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildOverviewCard('Natural Insemination', 'Track and Manage', 'Details of natural insemination events'),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _showAddInseminationDialog(context),
                child: const Text('Add New Insemination Record'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16.0),
              Text('Viewing Records:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16.0),
              _buildInseminationList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(String title, String subtitle, String description) {
    return Card(
      color: Colors.white,
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Text(description, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildInseminationList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('natural_insemination').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No records found.'));
        }

        final records = snapshot.data!.docs;

        return Column(
          children: records.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              color: Colors.white,
              elevation: 4.0,
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRecordDetail('Date:', data['date']),
                    _buildRecordDetail('Cattle ID:', data['cattle_id']),
                    _buildRecordDetail('Father Breed:', data['father_breed']),
                    _buildRecordDetail('Notes:', data['notes']),
                    _buildRecordDetail('Cost:', data['cost']),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditInseminationDialog(context, doc.id, data),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(doc.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRecordDetail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
