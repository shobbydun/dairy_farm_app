import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ArtificialInseminationPage extends StatefulWidget {
  @override
  _ArtificialInseminationPageState createState() =>
      _ArtificialInseminationPageState();
}

class _ArtificialInseminationPageState
    extends State<ArtificialInseminationPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _vetNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  String? _selectedCattle;
  String? _selectedBreed;
  String? _selectedSexed;
  String? _currentDocId;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void dispose() {
    _dateController.dispose();
    _serialNumberController.dispose();
    _vetNameController.dispose();
    _notesController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    if (_scaffoldMessengerKey.currentState != null) {
      _scaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey,
      appBar: AppBar(
        title: Text('Artificial Insemination'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[200],
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(10)),
                      child: Image.asset(
                        'assets/insem.jpeg',
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Artificial Insemination',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        'Record AI procedures to manage breeding schedules, track genetic improvements, and enhance your herd\'s reproductive efficiency.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _showInseminationModal(context, null),
                child: Text(
                  'Inseminate',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Artificial Insemination List',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _getUserSpecificStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No data available'));
                    }
                    final data = snapshot.data!;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Serial Number')),
                          DataColumn(label: Text('Vet Name')),
                          DataColumn(label: Text('Donor Breed')),
                          DataColumn(label: Text('Cost')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: data.docs.map<DataRow>((doc) {
                          final fields = doc.data() as Map<String, dynamic>;
                          return DataRow(cells: [
                            DataCell(Text(fields['date'] ?? 'N/A')),
                            DataCell(Text(fields['serialNumber'] ?? 'N/A')),
                            DataCell(Text(fields['vetName'] ?? 'N/A')),
                            DataCell(Text(fields['breed'] ?? 'N/A')),
                            DataCell(Text(fields['cost'] ?? 'N/A')),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () =>
                                        _showInseminationModal(context, doc.id),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _confirmDelete(doc.id),
                                  ),
                                ],
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getUserSpecificStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not logged in');
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('artificial_inseminations')
        .limit(50)
        .snapshots();
  }

  void _showInseminationModal(BuildContext context, String? docId) {
    if (docId != null) {
      _loadDocument(docId);
    } else {
      _resetForm();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  docId == null ? 'Add New AI' : 'Edit AI',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 10),

                // Cattle Dropdown populated from the database
                FutureBuilder<List<String>>(
                  future: _fetchCattleFromDatabase(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('No cattle found');
                    }

                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Select Cattle'),
                      value: _selectedCattle,
                      items: snapshot.data!.map((cattle) {
                        return DropdownMenuItem(
                            value: cattle, child: Text(cattle));
                      }).toList(),
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            _selectedCattle = value;
                          });
                        }
                      },
                    );
                  },
                ),
                SizedBox(height: 10),

                TextFormField(
                  controller: _serialNumberController,
                  decoration: InputDecoration(labelText: 'Serial Number'),
                ),
                SizedBox(height: 10),

                TextFormField(
                  controller: _dateController,
                  decoration:
                      InputDecoration(labelText: 'Date Of Insemination'),
                  keyboardType: TextInputType.datetime,
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dateController.text =
                            "${pickedDate.toLocal()}".split(' ')[0];
                      });
                    }
                  },
                ),
                SizedBox(height: 10),

                TextFormField(
                  controller: _vetNameController,
                  decoration: InputDecoration(labelText: 'Veterinarian Name'),
                ),
                SizedBox(height: 10),

                // Updated Breed Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Select Breed'),
                  value: _selectedBreed,
                  items: [
                    DropdownMenuItem(
                        value: 'Holstein', child: Text('Holstein')),
                    DropdownMenuItem(value: 'Angus', child: Text('Angus')),
                    DropdownMenuItem(value: 'Jersey', child: Text('Jersey')),
                    DropdownMenuItem(
                        value: 'Guernsey', child: Text('Guernsey')),
                    DropdownMenuItem(
                        value: 'Hereford', child: Text('Hereford')),
                    DropdownMenuItem(
                        value: 'Simmental', child: Text('Simmental')),
                    DropdownMenuItem(
                        value: 'Charolais', child: Text('Charolais')),
                    DropdownMenuItem(value: 'Brahman', child: Text('Brahman')),
                    DropdownMenuItem(
                        value: 'Dairy Shorthorn',
                        child: Text('Dairy Shorthorn')),
                    DropdownMenuItem(value: 'Dexter', child: Text('Dexter')),
                    DropdownMenuItem(
                        value: 'Milking Shorthorn',
                        child: Text('Milking Shorthorn')),
                    DropdownMenuItem(
                        value: 'Ayrshire', child: Text('Ayrshire')),
                  ],
                  onChanged: (value) {
                    if (mounted) {
                      setState(() {
                        _selectedBreed = value;
                      });
                    }
                  },
                ),
                SizedBox(height: 10),

// Updated Sexed Semen Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Select Sexed Semen'),
                  value: _selectedSexed,
                  items: [
                    DropdownMenuItem(value: 'Sexed A', child: Text('Sexed A')),
                    DropdownMenuItem(value: 'Sexed B', child: Text('Sexed B')),
                    DropdownMenuItem(value: 'Sexed X', child: Text('Sexed X')),
                    DropdownMenuItem(value: 'Sexed Y', child: Text('Sexed Y')),
                    DropdownMenuItem(
                        value: 'Ultra Sexed', child: Text('Ultra Sexed')),
                    DropdownMenuItem(
                        value: 'Gendered Semen', child: Text('Gendered Semen')),
                  ],
                  onChanged: (value) {
                    if (mounted) {
                      setState(() {
                        _selectedSexed = value;
                      });
                    }
                  },
                ),

                SizedBox(height: 10),

                // New Cost Field
                TextFormField(
                  controller: _costController,
                  decoration: InputDecoration(labelText: 'Cost of AI'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),

                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(labelText: 'Notes'),
                ),
                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    if (docId == null) {
                      _submitData(context);
                    } else {
                      _updateData(context, docId);
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    docId == null ? 'Submit' : 'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<String>> _fetchCattleFromDatabase() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not logged in');
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('cattle')
        .where('userId', isEqualTo: uid)
        .get();

    return snapshot.docs.map((doc) => doc.data()['name'] as String).toList();
  }

  Future<void> _submitData(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _showSnackBar('User not logged in');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('artificial_inseminations')
          .add({
        'date': _dateController.text,
        'serialNumber': _serialNumberController.text,
        'vetName': _vetNameController.text,
        'breed': _selectedBreed,
        'sexed': _selectedSexed,
        'notes': _notesController.text,
        'cattle': _selectedCattle,
        'cost': _costController.text,
      });
      _showSnackBar('AI record added successfully');
      _resetForm();
    } catch (e) {
      _showSnackBar('Failed to add record: $e');
    }
  }

  Future<void> _updateData(BuildContext context, String docId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _showSnackBar('User not logged in');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('artificial_inseminations')
          .doc(docId)
          .update({
        'date': _dateController.text,
        'serialNumber': _serialNumberController.text,
        'vetName': _vetNameController.text,
        'breed': _selectedBreed,
        'sexed': _selectedSexed,
        'notes': _notesController.text,
        'cattle': _selectedCattle,
        'cost': _costController.text,
      });
      _showSnackBar('AI record updated successfully');
    } catch (e) {
      _showSnackBar('Failed to update record: $e');
    }
  }

  Future<void> _loadDocument(String docId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _showSnackBar('User not logged in');
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('artificial_inseminations')
          .doc(docId)
          .get();
      if (doc.exists) {
        final fields = doc.data() as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _currentDocId = docId;
            _selectedCattle = fields['cattle'];
            _dateController.text = fields['date'] ?? '';
            _vetNameController.text = fields['vetName'] ?? '';
            _selectedBreed = fields['breed'];
            _selectedSexed = fields['sexed'];
            _serialNumberController.text = fields['serialNumber'] ?? '';
            _notesController.text = fields['notes'] ?? '';
            _costController.text = fields['cost']?.toString() ?? '';
          });
        }
      }
    } catch (error) {
      _showSnackBar('Failed to load document: $error');
    }
  }

  Future<void> _confirmDelete(String docId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
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

    if (shouldDelete == true) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        _showSnackBar('User not logged in');
        return;
      }

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('artificial_inseminations')
            .doc(docId)
            .delete();
        _showSnackBar('Record deleted successfully');
      } catch (e) {
        _showSnackBar('Failed to delete record: $e');
      }
    }
  }

  void _resetForm() {
    setState(() {
      _currentDocId = null;
      _selectedCattle = null;
      _selectedBreed = null;
      _selectedSexed = null;
      _dateController.clear();
      _serialNumberController.clear();
      _vetNameController.clear();
      _notesController.clear();
      _costController.clear();
    });
  }
}
