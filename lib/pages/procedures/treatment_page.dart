import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TreatmentPage extends StatefulWidget {
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

  int ongoingCount = 0;
  int completedCount = 0;

  @override
  void initState() {
    super.initState();
    _updateCounts();
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

  void _showAddTreatmentModal(BuildContext context) {
    _dateController.clear();
    _doctorController.clear();
    _drugController.clear();
    _diseaseController.clear();
    _notesController.clear();

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
                  _addTreatmentToFirebase();
                  Navigator.pop(context);
                },
                child: Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditTreatmentModal(BuildContext context, Map<String, dynamic> treatment) {
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
        _notesController.text.isNotEmpty) {
      
      FirebaseFirestore.instance.collection('treatments').add({
        'doctor': _doctorController.text,
        'date': _dateController.text,
        'drug': _drugController.text,
        'disease': _diseaseController.text,
        'notes': _notesController.text,
        'status': 'ongoing', 
      }).then((value) {
        print('Treatment Added');
        _updateCounts(); 
      }).catchError((error) {
        print('Failed to add treatment: $error');
      });
    } else {
      print('Please fill all fields');
    }
  }

  void _updateTreatmentInFirebase(String id) {
    if (_doctorController.text.isNotEmpty &&
        _dateController.text.isNotEmpty &&
        _drugController.text.isNotEmpty &&
        _diseaseController.text.isNotEmpty &&
        _notesController.text.isNotEmpty) {
      
      FirebaseFirestore.instance.collection('treatments').doc(id).update({
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
        await FirebaseFirestore.instance.collection('treatments').doc(id).delete();
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
          content: Text('Are you sure you want to delete this treatment? This action cannot be undone.'),
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
    return FirebaseFirestore.instance
        .collection('treatments')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }

  void _updateCounts() {
    FirebaseFirestore.instance
        .collection('treatments')
        .get()
        .then((snapshot) {
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
                            FirebaseFirestore.instance
                                .collection('treatments')
                                .doc(treatment['id'])
                                .update({
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
