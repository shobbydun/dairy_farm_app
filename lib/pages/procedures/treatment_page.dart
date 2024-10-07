import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TreatmentPage extends StatefulWidget {
  final Future<String?> adminEmailFuture;
  TreatmentPage({required this.adminEmailFuture});
  @override
  _TreatmentPageState createState() => _TreatmentPageState();
}

class _TreatmentPageState extends State<TreatmentPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();
  final TextEditingController _drugController = TextEditingController();
  final TextEditingController _diseaseController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _selectedDate;
  String? _adminEmail;

  int ongoingCount = 0;
  int completedCount = 0;

  CollectionReference? _treatmentCollection; // Change to nullable
  List<String> cattleNames = [];
  bool _isLoading = false; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchAdminEmail(); // Start by fetching admin email
  }

  Future<void> _fetchAdminEmail() async {
    _adminEmail = await widget.adminEmailFuture;
    print("Admin Email: $_adminEmail"); // Debug print
    if (_adminEmail != null) {
      _initializeCollection(); // Initialize the collection
      await _fetchCattleNames(); // Fetch cattle names after initializing
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Admin email not set')),
      );
    }
  }

  Future<void> _fetchCattleNames() async {
    setState(() {
      cattleNames = [];
      _isLoading = true; // Start loading
    });

    QuerySnapshot snapshot;

    try {
      if (_adminEmail != null) {
        snapshot = await FirebaseFirestore.instance
            .collection('cattle')
            .doc(_adminEmail)
            .collection('entries')
            .get();
        print('Fetched cattle for admin: ${snapshot.docs.length} entries'); // Debug print
        
        for (var doc in snapshot.docs) {
          print('Entry ID: ${doc.id}, Name: ${doc['name']}'); // Debug print
        }
      } else {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          snapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('cattle')
              .get();
          print('Fetched cattle for user: ${snapshot.docs.length} entries'); // Debug print
        } else {
          // Handle case when user is not logged in
          snapshot = await FirebaseFirestore.instance.collection('cattle').get();
          print('Fetched all cattle: ${snapshot.docs.length} entries'); // Debug print
        }
      }

      // Extracting names from the snapshot
      setState(() {
        cattleNames = snapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      print('Error fetching cattle names: $e');
    } finally {
      setState(() {
        _isLoading = false; // End loading
      });
    }
  }

  void _initializeCollection() {
    setState(() {
      if (_adminEmail != null) {
        _treatmentCollection = FirebaseFirestore.instance
            .collection('treatments_records')
            .doc(_adminEmail)
            .collection('entries');
      } else {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          _treatmentCollection = FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('treatments');
        } else {
          // Handle case when user is not logged in
          _treatmentCollection =
              FirebaseFirestore.instance.collection('treatments');
        }
      }
    });
    print('Initialized Treatment Collection for Admin: $_adminEmail');
  }

  void _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  String? selectedCattleName;

  void _showAddTreatmentModal(BuildContext context) {
    _dateController.clear();
    _doctorController.clear();
    _drugController.clear();
    _diseaseController.clear();
    _notesController.clear();
    selectedCattleName = null; // Reset selected cattle name

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add New Treatment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              // Dropdown for selecting cattle
              DropdownButton<String>(
                hint: Text('Select Cattle being Treated'),
                value: selectedCattleName,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCattleName = newValue;
                  });
                },
                items: cattleNames.map<DropdownMenuItem<String>>((String name) {
                  return DropdownMenuItem<String>(
                    value: name,
                    child: Text(name),
                  );
                }).toList(),
              ),
              TextField(
                controller: _doctorController,
                decoration: InputDecoration(
                  labelText: 'Veterinary Doctor\'s Name',
                ),
              ),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Date of Treatment',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
              ),
              TextField(
                controller: _drugController,
                decoration: InputDecoration(
                  labelText: 'Drug Used',
                ),
              ),
              TextField(
                controller: _diseaseController,
                decoration: InputDecoration(
                  labelText: 'Disease Being Treated',
                ),
              ),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (selectedCattleName != null) {
                    _addTreatmentToFirebase();
                    Navigator.pop(context);
                  } else {
                    print('Please select a cattle');
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditTreatmentModal(
      BuildContext context, Map<String, dynamic> treatment) {
    _dateController.text = treatment['date'];
    _doctorController.text = treatment['doctor'];
    _drugController.text = treatment['drug'];
    _diseaseController.text = treatment['disease'];
    _notesController.text = treatment['notes'];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Treatment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _doctorController,
                decoration: InputDecoration(
                  labelText: 'Veterinary Doctor\'s Name',
                ),
              ),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Date of Treatment',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
              ),
              TextField(
                controller: _drugController,
                decoration: InputDecoration(
                  labelText: 'Drug Used',
                ),
              ),
              TextField(
                controller: _diseaseController,
                decoration: InputDecoration(
                  labelText: 'Disease Being Treated',
                ),
              ),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _updateTreatmentInFirebase(treatment['id']);
                  Navigator.pop(context);
                },
                child: Text('Save Changes'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addTreatmentToFirebase() {
    if (_doctorController.text.isNotEmpty &&
        _dateController.text.isNotEmpty &&
        _drugController.text.isNotEmpty &&
        _diseaseController.text.isNotEmpty &&
        _notesController.text.isNotEmpty &&
        selectedCattleName != null) {
      // Ensure cattle is selected

      _treatmentCollection?.add({
        'doctor': _doctorController.text,
        'date': _dateController.text,
        'drug': _drugController.text,
        'disease': _diseaseController.text,
        'notes': _notesController.text,
        'cattleName': selectedCattleName, // Add the selected cattle name
        'status': 'ongoing',
      }).then((value) {
        print('Treatment Added');
        _updateCounts();
      }).catchError((error) {
        print('Failed to add treatment: $error');
      });
    } else {
      print('Please fill all fields and select a cattle');
    }
  }

  void _updateTreatmentInFirebase(String id) {
    if (_doctorController.text.isNotEmpty &&
        _dateController.text.isNotEmpty &&
        _drugController.text.isNotEmpty &&
        _diseaseController.text.isNotEmpty &&
        _notesController.text.isNotEmpty) {
      _treatmentCollection?.doc(id).update({
        'doctor': _doctorController.text,
        'date': _dateController.text,
        'drug': _drugController.text,
        'disease': _diseaseController.text,
        'notes': _notesController.text,
      }).then((value) {
        print('Treatment Updated');
        _updateCounts();
      }).catchError((error) {
        print('Failed to update treatment: $error');
      });
    } else {
      print('Please fill all fields');
    }
  }

  Future<void> _deleteTreatment(String id) async {
    bool? confirmDelete = await _showConfirmationDialog();

    if (confirmDelete == true) {
      try {
        await _treatmentCollection?.doc(id).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Treatment deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        _updateCounts();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting treatment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool?> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete this treatment? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Stream<List<Map<String, dynamic>>> _streamTreatments() {
  if (_treatmentCollection == null) {
    // Return an empty stream or handle this case as needed
    return Stream.value([]); // Returns an empty list as a stream
  }

  return _treatmentCollection!.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?; // Explicitly cast to Map<String, dynamic>
      return {...?data, 'id': doc.id}; // Use null-aware operator to handle potential null data
    }).toList();
  });
}

  void _updateCounts() {
    _treatmentCollection!.get().then((snapshot) {
      int ongoing = 0;
      int completed = 0;

      for (var doc in snapshot.docs) {
        if (doc['status'] == 'ongoing') {
          ongoing++;
        } else if (doc['status'] == 'completed') {
          completed++;
        }
      }

      setState(() {
        ongoingCount = ongoing;
        completedCount = completed;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cattle Treatment'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Treatment Overview Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCountCard('Ongoing Treatments', ongoingCount),
                  _buildCountCard('Completed Treatments', completedCount),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _showAddTreatmentModal(context),
                child: Text('Add Treatment'),
              ),
              SizedBox(height: 16.0),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _streamTreatments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No treatments found.'));
                  }

                  final treatments = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: treatments.length,
                    itemBuilder: (context, index) {
                      final treatment = treatments[index];
                      return ListTile(
                        title: Text('Disease: ${treatment['disease']}'),
                        subtitle: Text('Doctor: ${treatment['doctor']}'),
                        trailing: PopupMenuButton(
                          icon: Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: Text('Edit'),
                              value: 'edit',
                            ),
                            PopupMenuItem(
                              child: Text('Delete'),
                              value: 'delete',
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditTreatmentModal(context, treatment);
                            } else if (value == 'delete') {
                              _deleteTreatment(treatment['id']);
                            }
                          },
                        ),
                        leading: Checkbox(
                          value: treatment['status'] == 'completed',
                          onChanged: (bool? checked) {
                            _treatmentCollection!.doc(treatment['id']).update({
                              'status': checked! ? 'completed' : 'ongoing'
                            }).then((_) {
                              _updateCounts(); // Refresh counts after updating status
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountCard(String title, int count) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
