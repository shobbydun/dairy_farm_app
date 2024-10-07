import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NaturalInseminationPage extends StatefulWidget {
  final Future<String?> adminEmailFuture;

  NaturalInseminationPage({required this.adminEmailFuture});

  @override
  _NaturalInseminationPageState createState() =>
      _NaturalInseminationPageState();
}

class _NaturalInseminationPageState extends State<NaturalInseminationPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  String? _selectedCattleName;
  String? _selectedBreed;
  List<String> _cattleList = [];
  String? _adminEmail;
  CollectionReference? _inseminationCollection;

  @override
  void initState() {
    super.initState();
    _fetchAdminEmail();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_adminEmail != null) {
      _initializeCollection();
      _fetchCattleNames();
    }
  }

  void _initializeCollection() {
    if (_adminEmail != null) {
      _inseminationCollection = FirebaseFirestore.instance
          .collection('natural_insemination')
          .doc(_adminEmail)
          .collection('entries');
      print('Initialized Collection for Admin: $_adminEmail');
      setState(() {}); // Refresh UI after initialization
    }
  }

  Future<void> _fetchAdminEmail() async {
    _adminEmail = await widget.adminEmailFuture;
    print("Admin Email: $_adminEmail"); // Debug print
    if (_adminEmail != null) {
      setState(() {
        _initializeCollection(); // Initialize the collection here
        _fetchCattleNames(); // Fetch cattle names
      });
    }
  }

  Future<void> _fetchCattleNames() async {
    if (_adminEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Admin email not set.')),
      );
      return;
    }

    try {
      print("Fetching cattle names for admin: $_adminEmail");
      final snapshot = await FirebaseFirestore.instance
          .collection('cattle')
          .doc(_adminEmail)
          .collection('entries')
          .get();

      print("Cattle Snapshot Count: ${snapshot.docs.length}"); // Debug print

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _cattleList =
              snapshot.docs.map((doc) => doc['name'] as String).toList();
          print("Cattle List: $_cattleList"); // Debug print
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No cattle found for this admin.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load cattle names: $e')),
      );
      print("Error fetching cattle names: $e"); // Debug print
    }
  }

  Future<void> _updateRecord(String docId) async {
    if (_inseminationCollection != null) {
      // Check for null
      try {
        await _inseminationCollection!.doc(docId).update({
          // Use non-null assertion
          'date': _dateController.text,
          'cattle_name': _selectedCattleName,
          'father_breed': _selectedBreed,
          'notes': _notesController.text,
          'cost': double.tryParse(_costController.text) ?? 0.0,
          'admin_email': _adminEmail,
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
    }
  }

  void _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _submitRecord() async {
    print("Attempting to submit record...");
    if (_selectedCattleName == null ||
        _selectedBreed == null ||
        _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    if (_inseminationCollection != null) {
      try {
        String currentUserEmail =
            FirebaseAuth.instance.currentUser?.email ?? '';
        print("Submitting record...");
        await _inseminationCollection!.add({
          'date': _dateController.text,
          'cattle_name': _selectedCattleName,
          'father_breed': _selectedBreed,
          'notes': _notesController.text,
          'cost': double.tryParse(_costController.text) ?? 0.0,
          'admin_email': _adminEmail,
          'filled_in_by': currentUserEmail
        });
        print("Record added successfully!");

        _resetFields();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Record added successfully!')),
        );
      } catch (e) {
        print("Failed to add record: $e"); // Print the error for debugging
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add record: $e')),
        );
      }
    } else {
      print("Insemination collection is null.");
    }
  }

  void _resetFields() {
    _dateController.clear();
    _notesController.clear();
    _costController.clear();
    setState(() {
      _selectedCattleName = null; // Reseting selected cattle
      _selectedBreed = null;
    });
  }

  void _showAddInseminationDialog(BuildContext context) {
    _resetFields();

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
                // Cattle Selection Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Select Cattle'),
                  value: _selectedCattleName,
                  items: _cattleList.isNotEmpty
                      ? _cattleList.map((cattleName) {
                          return DropdownMenuItem(
                            value: cattleName,
                            child: Text(cattleName),
                          );
                        }).toList()
                      : [
                          DropdownMenuItem(
                              value: null, child: Text('No cattle available'))
                        ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCattleName = value;
                    });
                  },
                  validator: (value) => value == null ? 'Field required' : null,
                ),

                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Father's Breed"),
                  value: _selectedBreed,
                  items: [
                    'Holstein Friesian',
                    'Jersey',
                    'Guernsey',
                    'Brown Swiss',
                    'Ayrshire'
                  ]
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
                await _submitRecord();
                Navigator.of(context)
                    .pop(); // Only close the dialog after submission.
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showEditInseminationDialog(
      BuildContext context, String docId, Map<String, dynamic> data) {
    _dateController.text = data['date'];
    _selectedCattleName = data['cattle_name'];
    _notesController.text = data['notes'];
    _costController.text =
        data['cost'] is double ? data['cost'].toString() : '';
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
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Select Cattle'),
                  value: _selectedCattleName,
                  items: _cattleList.map((cattleName) {
                    return DropdownMenuItem(
                      value: cattleName,
                      child: Text(cattleName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCattleName = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Father's Breed"),
                  value: _selectedBreed,
                  items: [
                    'Holstein Friesian',
                    'Jersey',
                    'Guernsey',
                    'Brown Swiss',
                    'Ayrshire'
                  ]
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
                if (_inseminationCollection != null) {
                  // Check if initialized
                  try {
                    String currentUserEmail =
                        FirebaseAuth.instance.currentUser?.email ?? '';
                    await _inseminationCollection!.doc(docId).update({
                      'date': _dateController.text,
                      'cattle_name': _selectedCattleName,
                      'father_breed': _selectedBreed,
                      'notes': _notesController.text,
                      'cost': double.tryParse(_costController.text) ??
                          0.0, // Ensure cost is a double
                      'admin_email': _adminEmail,
                      'filled_in_by': currentUserEmail
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Record updated successfully!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update record: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Insemination collection is not initialized.')),
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
      if (_inseminationCollection != null) {
        // Check for null
        try {
          await _inseminationCollection!
              .doc(docId)
              .delete(); // Use non-null assertion
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
              _buildOverviewCard('Natural Insemination', 'Track and Manage',
                  'Details of natural insemination events'),

              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _showAddInseminationDialog(context),
                child: const Text('Add New Insemination Record'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16.0),
              Text('Viewing Records:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16.0),

              // Check if the collection is initialized
              if (_inseminationCollection == null)
                Center(child: CircularProgressIndicator()) // Show loading
              else
                _buildInseminationList(), // Show records when initialized
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
            Text(title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(subtitle,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Text(description, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildInseminationList() {
    if (_inseminationCollection == null) {
      return Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _inseminationCollection!.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
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
                    _buildRecordDetail('Cattle Name:', data['cattle_name']),
                    _buildRecordDetail('Father Breed:', data['father_breed']),
                    _buildRecordDetail('Notes:', data['notes']),
                    _buildRecordDetail(
                        'Cost:',
                        data['cost'] is double
                            ? data['cost'].toString()
                            : 'N/A'),
                    _buildRecordDetail('Filled_in_by:', data['filled_in_by']),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditInseminationDialog(
                              context, doc.id, data),
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
