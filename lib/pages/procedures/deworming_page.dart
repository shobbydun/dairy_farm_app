import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DewormingPage extends StatefulWidget {
  final Future<String?> adminEmailFuture;

  DewormingPage({required this.adminEmailFuture});

  @override
  _DewormingPageState createState() => _DewormingPageState();
}

class _DewormingPageState extends State<DewormingPage> {
  //final _cattleIdController = TextEditingController();
  final _dateOfDewormingController = TextEditingController();
  final _vetNameController = TextEditingController();
  final _methodController = TextEditingController();
  final _diseaseController = TextEditingController();
  final _drugUsedController = TextEditingController();
  final _notesController = TextEditingController();
  final _costController = TextEditingController();
  final _cattleSerialNumberController = TextEditingController();
  String? _selectedCattleName;
  String? _adminEmail;

  late final CollectionReference _dewormingCollection;
  List<DocumentSnapshot> _dewormingList = [];
  List<DocumentSnapshot> _cattleList = []; // To hold cattle data
  String? _selectedCattleId; // To hold selected cattle ID
  bool _isFormVisible = false;
  String? _editingDocId;

  @override
  void initState() {
    super.initState();
    // Removed the direct fetch of records here
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchAdminEmail();
  }

  Future<void> _fetchAdminEmail() async {
    final email = await widget.adminEmailFuture;
    setState(() {
      _adminEmail = email;
    });

    if (_adminEmail != null) {
      _initializeCollection();
      _fetchDewormingRecords();
      _fetchCattle(); // Fetch cattle data after the admin email is set
    } else {
      // Move the SnackBar display here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Admin email not set.')),
      );
    }
  }

  void _initializeCollection() {
    if (_adminEmail != null) {
      _dewormingCollection = FirebaseFirestore.instance
          .collection('deworming')
          .doc(_adminEmail)
          .collection('entries');
    }
  }

  Future<void> _fetchDewormingRecords() async {
    if (_adminEmail == null) return;

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
    if (_adminEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Admin email not set.')),
      );
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('cattle')
          .doc(_adminEmail) // Using adminEmail as the document ID
          .collection('entries') // Accessing the 'entries' sub-collection
          .get();

      setState(() {
        _cattleList =
            snapshot.docs; // Update the state with the fetched documents
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
    final cost = _costController.text;

    if (dateOfDeworming.isEmpty ||
        _selectedCattleId == null ||
        vetName.isEmpty ||
        method.isEmpty ||
        disease.isEmpty ||
        drugUsed.isEmpty ||
        cost.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    if (_adminEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Admin email not set.')),
      );
      return;
    }

    try {
      if (_editingDocId == null) {
        // Add new record
        await _dewormingCollection.add({
          'date': dateOfDeworming,
          'cattle_name': _selectedCattleName, // Save the name
          'cattle_serial_number':
              _cattleSerialNumberController.text, // Save serial number
          'cattle_id': _selectedCattleId, // Add cattle_id here
          'vet_name': vetName,
          'method': method,
          'disease': disease,
          'drug_used': drugUsed,
          'notes': notes,
          'cost': double.tryParse(cost) ?? 0.0, // Save cost as double
        });
      } else {
        // Update existing record
        await _dewormingCollection.doc(_editingDocId).update({
          'date': dateOfDeworming,
          'cattle_name': _selectedCattleName, // Update the name
          'cattle_serial_number':
              _cattleSerialNumberController.text, // Update serial number
          'cattle_id': _selectedCattleId, // Update cattle_id here
          'vet_name': vetName,
          'method': method,
          'disease': disease,
          'drug_used': drugUsed,
          'notes': notes,
          'cost': double.tryParse(cost) ?? 0.0, // Update cost as double
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
    _selectedCattleId = null;
    _dateOfDewormingController.clear();
    _vetNameController.clear();
    _methodController.clear();
    _diseaseController.clear();
    _drugUsedController.clear();
    _notesController.clear();
    _costController.clear();
  }

  void _editRecord(DocumentSnapshot doc) {
    setState(() {
      _editingDocId = doc.id;

      // Cast doc.data() to Map<String, dynamic>
      final data = doc.data() as Map<String, dynamic>;

      // Check if 'cattle_id' exists
      if (data.containsKey('cattle_id')) {
        _selectedCattleId = data['cattle_id'];
      } else {
        _selectedCattleId =
            null; // Handle the absence of cattle_id appropriately
      }

      _dateOfDewormingController.text = data['date'] ?? '';
      _vetNameController.text = data['vet_name'] ?? '';
      _methodController.text = data['method'] ?? '';
      _diseaseController.text = data['disease'] ?? '';
      _drugUsedController.text = data['drug_used'] ?? '';
      _notesController.text = data['notes'] ?? '';
      _costController.text =
          data['cost']?.toString() ?? ''; // Ensure correct type
      _isFormVisible = true;
    });
  }

  void _deleteRecord(String docId) async {
    if (_adminEmail == null) return;

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
      body: SingleChildScrollView(
        // Changed to SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
            _buildCattleDropdown(),
            _buildFormField(
              controller:
                  _cattleSerialNumberController, // New serial number field
              labelText: 'Cattle Serial Number',
            ), // Dropdown for cattle selection
            _buildFormField(
              controller: _dateOfDewormingController,
              labelText: 'Date Of Deworming',
              inputType: TextInputType.datetime,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
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
        value: _selectedCattleName, // Use name instead of ID
        onChanged: (String? newValue) {
          setState(() {
            _selectedCattleName = newValue; // Set selected cattle name
            // Set the cattle ID as well based on name (if needed)
            _selectedCattleId =
                _cattleList.firstWhere((doc) => doc['name'] == newValue).id;
          });
        },
        decoration: InputDecoration(
          labelText: 'Select Cattle',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: _cattleList.map((doc) {
          return DropdownMenuItem<String>(
            value: doc['name'], // Save the name instead of ID
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
            // Set a fixed height for the ListView to avoid layout issues
            SizedBox(
              height: 400, // Adjust this height based on your UI requirements
              child: _dewormingList.isNotEmpty
                  ? ListView.builder(
                      itemCount: _dewormingList.length,
                      itemBuilder: (context, index) {
                        final doc = _dewormingList[index];
                        final cattleName = doc['cattle_name'] ?? '';
                        final cattleSerialNumber =
                            doc['cattle_serial_number'] ?? '';
                        final date = doc['date'] ?? '';
                        final vetName = doc['vet_name'] ?? '';
                        final method = doc['method'] ?? '';
                        final disease = doc['disease'] ?? '';
                        final drugUsed = doc['drug_used'] ?? '';
                        final notes = doc['notes'] ?? '';
                        final cost = (doc.data() as Map<String, dynamic>)
                                .containsKey('cost')
                            ? doc['cost']
                            : 'N/A';

                        return Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date: $date',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text('Cattle Name: $cattleName'),
                                Text(
                                    'Cattle Serial Number: $cattleSerialNumber'),
                                Text('Veterinary Doctor: $vetName'),
                                Text('Method: $method'),
                                Text('Disease: $disease'),
                                Text('Drug Used: $drugUsed'),
                                Text('Cost: \Kshs${cost.toString()}',
                                    style: TextStyle(color: Colors.green)),
                                Text('Notes: $notes'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon:
                                          Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _editRecord(doc),
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteRecord(doc.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Text('No Deworming records found.'),
            ),
          ],
        ),
      ),
    );
  }
}
