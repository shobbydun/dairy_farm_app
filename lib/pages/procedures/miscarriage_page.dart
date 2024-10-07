import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MiscarriagePage extends StatefulWidget {
  final Future<String?> adminEmailFuture;

  MiscarriagePage({required this.adminEmailFuture});

  @override
  _MiscarriagePageState createState() => _MiscarriagePageState();
}

class _MiscarriagePageState extends State<MiscarriagePage> {
  final _dateController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isFormVisible = false;
  String? _editingRecordId;
  String? _selectedCattleId;
  List<String> _cattleList = [];
  String? _adminEmail;
  CollectionReference<Map<String, dynamic>>? _miscarriageCollection;

  @override
  void initState() {
    super.initState();
    _fetchAdminEmail();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_adminEmail != null) {
      _initializeCollection(); // Ensure collection is initialized after admin email is set
      _fetchCattleNames();
    }
  }

  Future<void> _fetchAdminEmail() async {
    _adminEmail = await widget.adminEmailFuture;
    print('Admin Email: $_adminEmail'); // Debugging
    if (_adminEmail != null) {
      _initializeCollection();
      _fetchCattleNames(); // Ensure this is called after the admin email is set
    } else {
      print('Failed to fetch admin email.'); // Debugging
    }
  }

  void _initializeCollection() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
      return;
    }

    _miscarriageCollection = FirebaseFirestore.instance
        .collection('miscarriage_records')
        .doc(_adminEmail)
        .collection('entries');

    _fetchCattleNames(); // Ensure this is called after initialization
  }

  Future<void> _fetchCattleNames() async {
    if (_adminEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Admin email not set.')),
      );
      return;
    }

    print('Fetching cattle names for admin email: $_adminEmail'); // Debugging

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('cattle')
          .doc(_adminEmail)
          .collection('entries')
          .get();

      print(
          'Fetched Cattle Names Snapshot: ${snapshot.docs.length}'); // Debugging

      setState(() {
        _cattleList =
            snapshot.docs.map((doc) => doc['name'] as String).toList();
      });

      print('Fetched Cattle Names: $_cattleList'); // Debugging
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load cattle names: $e')),
      );
      print('Error fetching cattle names: $e'); // Debugging
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Miscarriage Records'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Miscarriage Card
                    Card(
                      color: Colors.white,
                      elevation: 4.0,
                      margin: const EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Miscarriage Details',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.lightBlueAccent,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            _isFormVisible
                                ? _buildMiscarriageForm()
                                : SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                    // Miscarriage List
                    Card(
                      color: Colors.white,
                      elevation: 4.0,
                      margin: const EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Miscarriage List',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.lightBlueAccent,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            _buildMiscarriageList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isFormVisible = !_isFormVisible;
            if (_isFormVisible) {
              _clearForm();
              _editingRecordId = null;
            }
          });
        },
        child: Icon(_isFormVisible ? Icons.close : Icons.add),
        backgroundColor: Colors.lightBlueAccent,
      ),
    );
  }

  Widget _buildMiscarriageForm() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _selectedCattleId,
          hint: Text('Select Cattle'),
          onChanged: (newValue) {
            setState(() {
              _selectedCattleId = newValue;
            });
          },
          items: _cattleList.map((cattleName) {
            return DropdownMenuItem<String>(
              value: cattleName,
              child: Text(cattleName),
            );
          }).toList(),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16.0),

        // Date of Miscarriage
        GestureDetector(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(), // Set lastDate to now
            );
            if (pickedDate != null) {
              String formattedDate =
                  '${pickedDate.year.toString().padLeft(4, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
              setState(() {
                _dateController.text = formattedDate;
              });
            }
          },
          child: AbsorbPointer(
            // Prevent interaction with the TextFormField
            child: TextFormField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Date Of Miscarriage',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true, // Makes the field read-only
            ),
          ),
        ),

        const SizedBox(height: 16.0),

        // Notes
        TextFormField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: 'Notes',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16.0),

        ElevatedButton(
          onPressed: () {
            _isFormVisible ? _submitForm() : null;
          },
          child: Text(_editingRecordId == null ? 'Submit' : 'Update'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiscarriageList() {
    if (_miscarriageCollection == null) {
      return Center(
          child:
              CircularProgressIndicator()); // Show loading until collection is initialized
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _miscarriageCollection!.snapshots(),
      builder: (context, snapshot) {
        print(
            'Snapshot Connection State: ${snapshot.connectionState}'); // Debugging

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

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Cattle Name')),
              DataColumn(label: Text('Miscarriage Date')),
              DataColumn(label: Text('Actions')),
            ],
            rows: records.map((doc) {
              final data = doc.data();
              return DataRow(
                cells: [
                  DataCell(Text(data['cattleId'] ?? 'N/A')),
                  DataCell(Text(data['date'] ?? 'N/A')),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _showEditForm(doc.id, data);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _confirmDeleteRecord(doc.id);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _submitForm() async {
    final cattleId = _selectedCattleId;
    final date = _dateController.text;
    final notes = _notesController.text;

    if (cattleId == null || date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      if (_editingRecordId == null) {
        // Adding a new record
        await _miscarriageCollection!.add({
          'cattleId': cattleId,
          'date': date,
          'notes': notes,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Record saved successfully')),
        );
      } else {
        // Updating an existing record
        await _miscarriageCollection!.doc(_editingRecordId).update({
          'cattleId': cattleId,
          'date': date,
          'notes': notes,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Record updated successfully')),
        );
      }

      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save record: $e')),
      );
    }
  }

  void _clearForm() {
    _selectedCattleId = null; // Clear selected cattle
    _dateController.clear();
    _notesController.clear();
  }

  void _confirmDeleteRecord(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _deleteRecord(id);
    }
  }

  void _deleteRecord(String id) async {
    try {
      await _miscarriageCollection!.doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Record deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete record: $e')),
      );
    }
  }

  void _showEditForm(String id, Map<String, dynamic> data) {
    setState(() {
      _selectedCattleId = data['cattleId'] ?? ''; // Populate selected cattle
      _dateController.text = data['date'] ?? '';
      _notesController.text = data['notes'] ?? '';
      _editingRecordId = id;
      _isFormVisible = true;
    });
  }
}
