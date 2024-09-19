import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DewormingPage extends StatefulWidget {
  @override
  _DewormingPageState createState() => _DewormingPageState();
}

class _DewormingPageState extends State<DewormingPage> {
  final _cattleIdController = TextEditingController();
  final _dateOfDewormingController = TextEditingController();
  final _vetNameController = TextEditingController();
  final _methodController = TextEditingController();
  final _diseaseController = TextEditingController();
  final _drugUsedController = TextEditingController();
  final _notesController = TextEditingController();
  final _costController = TextEditingController(); // New cost controller

  late final CollectionReference _dewormingCollection;
  List<DocumentSnapshot> _dewormingList = [];
  List<DocumentSnapshot> _cattleList = []; // To hold cattle data
  String? _selectedCattleId; // To hold selected cattle ID
  bool _isFormVisible = false;
  String? _editingDocId;

  @override
  void initState() {
    super.initState();
    _initializeCollection();
    _fetchDewormingRecords();
    _fetchCattle(); // Fetch cattle data on initialization
  }

  void _initializeCollection() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in.')),
      );
      return;
    }
    _dewormingCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('deworming');
  }

  Future<void> _fetchDewormingRecords() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final snapshot = await _dewormingCollection.get();
      setState(() {
        _dewormingList = snapshot.docs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load records: $e')),
      );
    }
  }

  Future<void> _fetchCattle() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('cattle')
          .where('userId',
              isEqualTo: userId) 
          .get();
      setState(() {
        _cattleList = snapshot.docs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load cattle: $e')),
      );
    }
  }

  Future<void> _submitForm() async {
    final dateOfDeworming = _dateOfDewormingController.text;
    final vetName = _vetNameController.text;
    final method = _methodController.text;
    final disease = _diseaseController.text;
    final drugUsed = _drugUsedController.text;
    final notes = _notesController.text;
    final cost = _costController.text; // New cost input

    if (dateOfDeworming.isEmpty ||
        _selectedCattleId == null ||
        vetName.isEmpty ||
        method.isEmpty ||
        disease.isEmpty ||
        drugUsed.isEmpty ||
        cost.isEmpty) {
      // Check for cost
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in.')),
      );
      return;
    }

    try {
      if (_editingDocId == null) {
        // Add new record
        await _dewormingCollection.add({
          'date': dateOfDeworming,
          'cattleId': _selectedCattleId, // Use selected cattle ID
          'vetName': vetName,
          'method': method,
          'disease': disease,
          'drugUsed': drugUsed,
          'notes': notes,
          'cost': cost, // Save cost
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data saved successfully')),
        );
      } else {
        // Update existing record
        await _dewormingCollection.doc(_editingDocId).update({
          'date': dateOfDeworming,
          'cattleId': _selectedCattleId,
          'vetName': vetName,
          'method': method,
          'disease': disease,
          'drugUsed': drugUsed,
          'notes': notes,
          'cost': cost, // Update cost
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data updated successfully')),
        );
        setState(() {
          _editingDocId = null;
        });
      }

      _fetchDewormingRecords(); // Refresh the list
      _clearForm();
      setState(() {
        _isFormVisible = false; // Hide the form
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save data: $e')),
      );
    }
  }

  void _clearForm() {
    _selectedCattleId = null; // Clear selected cattle ID
    _dateOfDewormingController.clear();
    _vetNameController.clear();
    _methodController.clear();
    _diseaseController.clear();
    _drugUsedController.clear();
    _notesController.clear();
    _costController.clear(); // Clear cost field
  }

  void _editRecord(DocumentSnapshot doc) {
    setState(() {
      _editingDocId = doc.id;
      _selectedCattleId = doc['cattleId']; // Set selected cattle ID
      _dateOfDewormingController.text = doc['date'];
      _vetNameController.text = doc['vetName'];
      _methodController.text = doc['method'];
      _diseaseController.text = doc['disease'];
      _drugUsedController.text = doc['drugUsed'];
      _notesController.text = doc['notes'];
      _costController.text = doc['cost'].toString(); // Set cost for editing
      _isFormVisible = true;
    });
  }

  void _deleteRecord(String docId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      await _dewormingCollection.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Record deleted successfully')),
      );
      _fetchDewormingRecords(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete record: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deworming'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: 16.0),
                    if (_isFormVisible) _buildDewormingForm(),
                    const SizedBox(height: 16.0),
                    _buildDewormingList(),
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
            _isFormVisible = !_isFormVisible; // Toggle form visibility
            if (_isFormVisible) {
              _clearForm();
              _editingDocId = null;
            }
          });
        },
        backgroundColor: Colors.lightBlueAccent,
        child: Icon(_isFormVisible ? Icons.close : Icons.add),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              'assets/deworm.jpeg',
              fit: BoxFit.cover,
              height: 300,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Deworming',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlueAccent,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'A detailed summary of your livestock\'s deworming schedules and overall health status.',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDewormingForm() {
    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deworming Form',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            _buildCattleDropdown(), // Dropdown for cattle selection
            _buildFormField(
              controller: _dateOfDewormingController,
              labelText: 'Date Of Deworming',
              inputType: TextInputType.datetime,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  String formattedDate =
                      '${pickedDate.year.toString().padLeft(4, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                  _dateOfDewormingController.text = formattedDate;
                }
              },
            ),
            _buildFormField(
              controller: _vetNameController,
              labelText: 'Veterinary Doctor\'s Name',
            ),
            _buildDropdownField(
              controller: _methodController,
              labelText: 'Method Of Deworming',
              items: [
                'Pour-On',
                'Oral Drench',
                'Injectable',
                'Feed Additive',
                'Bolus',
                'Paste'
              ],
            ),
            _buildFormField(
              controller: _diseaseController,
              labelText: 'Name of Disease',
            ),
            _buildFormField(
              controller: _drugUsedController,
              labelText: 'Name of Medicine',
            ),
            _buildFormField(
              controller: _costController,
              labelText: 'Cost of Deworming', // New cost field
              inputType: TextInputType.number,
            ),
            _buildFormField(
              controller: _notesController,
              labelText: 'Notes',
              isMultiline: true,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(_editingDocId == null ? 'Submit' : 'Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCattleDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: _selectedCattleId,
        onChanged: (String? newValue) {
          setState(() {
            _selectedCattleId = newValue; // Set selected cattle ID
          });
        },
        decoration: InputDecoration(
          labelText: 'Select Cattle',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: _cattleList.map((doc) {
          return DropdownMenuItem<String>(
            value: doc.id, // Use document ID as value
            child: Text(doc['name']), // Display cattle name
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String labelText,
    TextInputType inputType = TextInputType.text,
    bool isMultiline = false,
    void Function()? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        keyboardType: inputType,
        maxLines: isMultiline ? 3 : 1,
        onTap: onTap,
      ),
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String labelText,
    required List<String> items,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: controller.text.isEmpty ? null : controller.text,
        onChanged: (String? newValue) {
          setState(() {
            controller.text = newValue!;
          });
        },
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDewormingList() {
    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deworming List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            _dewormingList.isNotEmpty
                ? Column(
                    children: _dewormingList.map((doc) {
                      final date = doc['date'] ?? '';
                      final cattleId = doc['cattleId'] ?? '';
                      final vetName = doc['vetName'] ?? '';
                      final method = doc['method'] ?? '';
                      final disease = doc['disease'] ?? '';
                      final drugUsed = doc['drugUsed'] ?? '';
                      final notes = doc['notes'] ?? '';
                      final cost = (doc.data() as Map<String, dynamic>)
                              .containsKey('cost')
                          ? doc['cost']
                          : 'N/A'; // Check for existence

                      return Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16.0),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date: $date',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text('Cattle ID: $cattleId'),
                              Text('Veterinary Doctor: $vetName'),
                              Text('Method: $method'),
                              Text('Disease: $disease'),
                              Text('Drug Used: $drugUsed'),
                              Text('Cost: \$${cost.toString()}',
                                  style: TextStyle(
                                      color: Colors.green)), // Display cost
                              Text('Notes: $notes'),
                            ],
                          ),
                          trailing: Wrap(
                            spacing: 12,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editRecord(doc),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteRecord(doc.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  )
                : Text('No deworming records found.'),
          ],
        ),
      ),
    );
  }
}
