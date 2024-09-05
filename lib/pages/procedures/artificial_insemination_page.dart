import 'package:cloud_firestore/cloud_firestore.dart';
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
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                  stream: FirebaseFirestore.instance
                      .collection('artificial_inseminations')
                      .limit(50)
                      .snapshots(),
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
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: data.docs.map<DataRow>((doc) {
                          final fields = doc.data() as Map<String, dynamic>;
                          return DataRow(cells: [
                            DataCell(Text(fields['date'] ?? 'N/A')),
                            DataCell(Text(fields['serialNumber'] ?? 'N/A')),
                            DataCell(Text(fields['vetName'] ?? 'N/A')),
                            DataCell(Text(fields['breed'] ?? 'N/A')),
                            DataCell(Row(
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
                            )),
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
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Select Cattle'),
                  value: _selectedCattle,
                  items: [
                    DropdownMenuItem(value: 'Cattle1', child: Text('Cattle1')),
                    DropdownMenuItem(value: 'Cattle2', child: Text('Cattle2')),
                  ],
                  onChanged: (value) {
                    if (mounted) {
                      setState(() {
                        _selectedCattle = value;
                      });
                    }
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
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Select Breed'),
                  value: _selectedBreed,
                  items: [
                    DropdownMenuItem(value: 'Breed1', child: Text('Breed1')),
                    DropdownMenuItem(value: 'Breed2', child: Text('Breed2')),
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
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Sexed Semen'),
                  value: _selectedSexed,
                  items: [
                    DropdownMenuItem(value: 'Sexed1', child: Text('Sexed1')),
                    DropdownMenuItem(value: 'Sexed2', child: Text('Sexed2')),
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
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(labelText: 'Additional Notes'),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (docId == null) {
                          _submitData(context);
                        } else {
                          _updateData(context, docId);
                        }
                        Navigator.pop(context);
                      },
                      child: Text(
                        docId == null ? 'Submit' : 'Update',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Close',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _resetForm() {
    if (mounted) {
      setState(() {
        _dateController.clear();
        _serialNumberController.clear();
        _vetNameController.clear();
        _notesController.clear();
        _selectedCattle = null;
        _selectedBreed = null;
        _selectedSexed = null;
      });
    }
  }

  Future<void> _submitData(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('artificial_inseminations')
          .add({
        'date': _dateController.text,
        'serialNumber': _serialNumberController.text,
        'vetName': _vetNameController.text,
        'breed': _selectedBreed,
        'sexed': _selectedSexed,
        'notes': _notesController.text,
        'cattle': _selectedCattle,
      });
      _showSnackBar('AI record added successfully');
    } catch (e) {
      _showSnackBar('Failed to add record: $e');
    }
  }

  Future<void> _updateData(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance
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
      });
      _showSnackBar('AI record updated successfully');
    } catch (e) {
      _showSnackBar('Failed to update record: $e');
    }
  }

  Future<void> _loadDocument(String docId) async {
    try {
      final doc = await FirebaseFirestore.instance
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
      try {
        await FirebaseFirestore.instance
            .collection('artificial_inseminations')
            .doc(docId)
            .delete();
        _showSnackBar('Record deleted successfully');
      } catch (e) {
        _showSnackBar('Failed to delete record: $e');
      }
    }
  }
}
