import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PregnancyPage extends StatefulWidget {
  @override
  _PregnancyPageState createState() => _PregnancyPageState();
}

class _PregnancyPageState extends State<PregnancyPage> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  DateTime? _dateOfDetection;
  DateTime? _expectedDateOfBirth;
  String? _editDocId;
  String? _selectedCattleName;
  List<String> _cattleNames = [];
  late CollectionReference _pregnancyCollection;

  @override
  void initState() {
    super.initState();
    _initializeCollection();
    _fetchCattleNames();
  }

  void _initializeCollection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _pregnancyCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pregnancy_records');
    } else {
      _pregnancyCollection = FirebaseFirestore.instance.collection('pregnancy_records');
    }
  }

Future<void> _fetchCattleNames() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  QuerySnapshot snapshot;

  if (uid != null) {
    snapshot = await FirebaseFirestore.instance
        .collection('cattle')
        .where('userId', isEqualTo: uid)
        .get();
  } else {
    throw Exception('User not logged in');
  }

  setState(() {
    _cattleNames = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?; 
      return data?['name'] as String? ?? ''; 
    }).toList();
  });
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregnancy Management'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _buildPregnancyCard(context),
              const SizedBox(height: 16.0),
              _buildPregnancyListSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPregnancyCard(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 6.0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.asset(
                'assets/preg.jpeg',
                fit: BoxFit.cover,
                height: 300,
                width: double.infinity,
              ),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: Text(
                  'Pregnancy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage and schedule pregnancies efficiently to ensure the well-being of your livestock.',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: () {
                    _showPregnancyModal(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                  ),
                  child: const Text('Add Pregnancy'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPregnancyListSection() {
    return Card(
      color: Colors.white,
      elevation: 6.0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pregnancy List',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlueAccent,
              ),
            ),
            const SizedBox(height: 8.0),
            StreamBuilder<QuerySnapshot>(
              stream: _pregnancyCollection.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No Records Found'));
                }

                return SizedBox(
                  height: 400,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final cattleName = data['cattle_name'] ?? 'N/A';
                      final dateOfDetection = (data['date_of_detection'] as Timestamp).toDate();
                      final expectedDateOfBirth = (data['expected_date_of_birth'] as Timestamp).toDate();

                      return _buildRecordCard(doc.id, cattleName, dateOfDetection, expectedDateOfBirth, data);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(String docId, String cattleName, DateTime dateOfDetection, DateTime expectedDateOfBirth, Map<String, dynamic> data) {
    return Card(
      color: Colors.white,
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cattle Name: $cattleName',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.0),
            Text('Date of Conceiving: ${dateOfDetection.toLocal().toString().split(' ')[0]}'),
            SizedBox(height: 4.0),
            Text('Expected Date of Birth: ${expectedDateOfBirth.toLocal().toString().split(' ')[0]}'),
            SizedBox(height: 4.0),
            Text('Notes: ${data['notes'] ?? 'N/A'}'),
            SizedBox(height: 4.0),
            Text('Cost: ${data['cost'] ?? 'N/A'}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey),
          onSelected: (value) {
            if (value == 'edit') {
              _showPregnancyModal(context, docId, data);
            } else if (value == 'delete') {
              _confirmDelete(docId);
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
      ),
    );
  }

  void _showPregnancyModal(BuildContext context, [String? docId, Map<String, dynamic>? data]) {
    if (data != null) {
      _selectedCattleName = data['cattle_name'] ?? '';
      _dateOfDetection = (data['date_of_detection'] as Timestamp).toDate();
      _expectedDateOfBirth = (data['expected_date_of_birth'] as Timestamp).toDate();
      _notesController.text = data['notes'] ?? '';
      _costController.text = data['cost'] ?? '';
      _editDocId = docId;
    } else {
      _selectedCattleName = null;
      _notesController.clear();
      _costController.clear();
      _dateOfDetection = null;
      _expectedDateOfBirth = null;
      _editDocId = null;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(docId == null ? 'Add Pregnancy' : 'Edit Pregnancy'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildCattleDropdown(),
                _buildDatePickerField(context, 'Date of Detection', (date) {
                  setState(() {
                    _dateOfDetection = date;
                  });
                }),
                _buildDatePickerField(context, 'Expected Date of Birth', (date) {
                  setState(() {
                    _expectedDateOfBirth = date;
                  });
                }),
                _buildTextField('Notes', TextInputType.text, _notesController),
                _buildTextField('Cost (if applicable)', TextInputType.number, _costController),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(docId == null ? 'Submit' : 'Save Changes',
                  style: TextStyle(color: Colors.lightBlueAccent)),
              onPressed: () async {
                if (_selectedCattleName != null &&
                    _dateOfDetection != null &&
                    _expectedDateOfBirth != null) {
                  if (docId == null) {
                    // Add new record
                    await _pregnancyCollection.add({
                      'cattle_name': _selectedCattleName,
                      'date_of_detection': _dateOfDetection,
                      'expected_date_of_birth': _expectedDateOfBirth,
                      'notes': _notesController.text,
                      'cost': _costController.text,
                    });
                  } else {
                    // Update existing record
                    await _pregnancyCollection.doc(docId).update({
                      'cattle_name': _selectedCattleName,
                      'date_of_detection': _dateOfDetection,
                      'expected_date_of_birth': _expectedDateOfBirth,
                      'notes': _notesController.text,
                      'cost': _costController.text,
                    });
                  }

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCattleDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedCattleName,
        decoration: InputDecoration(
          labelText: 'Select Cattle',
          border: OutlineInputBorder(),
        ),
        items: _cattleNames.map((name) {
          return DropdownMenuItem(
            value: name,
            child: Text(name),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCattleName = value;
          });
        },
        validator: (value) => value == null ? 'Please select a cattle' : null,
      ),
    );
  }

  Widget _buildTextField(String label, TextInputType inputType, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        keyboardType: inputType,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context, String label, Function(DateTime) onDateSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today, color: Colors.lightBlueAccent),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (pickedDate != null) {
            onDateSelected(pickedDate);
          }
        },
        controller: TextEditingController(
          text: (label == 'Expected Date of Birth' ? _expectedDateOfBirth : _dateOfDetection)?.toLocal().toString().split(' ')[0] ?? '',
        ),
      ),
    );
  }

  void _confirmDelete(String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this record?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.lightBlueAccent)),
              onPressed: () async {
                await _pregnancyCollection.doc(docId).delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
