import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalvingPage extends StatefulWidget {
  final Future<String?> adminEmailFuture;
  CalvingPage({super.key, required this.adminEmailFuture});

  @override
  _CalvingPageState createState() => _CalvingPageState();
}

class _CalvingPageState extends State<CalvingPage> {
  final List<Calf> _calves = [];
  List<String> _motherNames = [];
  String? _adminEmail;

  Future<void> _fetchAdminEmail() async {
    _adminEmail = await widget.adminEmailFuture;
    setState(() {
      // Now that admin email is fetched, fetch calves.
      _fetchCalvesFromFirebase();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAdminEmail();
  }

  Future<void> _fetchCalvesFromFirebase() async {
    if (_adminEmail == null) {
      _showSnackBar('Admin email is not set');
      return;
    }

    final calfCollection = FirebaseFirestore.instance
        .collection('calves')
        .doc(_adminEmail)
        .collection('entries');

    try {
      // Fetch calves
      final calfSnapshot = await calfCollection.get();
      final calvesList = calfSnapshot.docs.map((doc) {
        final data = doc.data();
        return Calf(
          id: doc.id,
          name: data['name'],
          birthDate: (data['birthDate'] as Timestamp).toDate(),
          mother: data['mother'],
          gender: data['gender'],
          healthStatus: data['healthStatus'],
          filledInBy: data['filled_in_by'], // Fetch filled_in_by
        );
      }).toList();

      // Fetch mother names from the cattle collection
      final cattleCollection = FirebaseFirestore.instance.collection('cattle');
      final motherNamesSnapshot =
          await cattleCollection.doc(_adminEmail).collection('entries').get();

      _motherNames = motherNamesSnapshot.docs
          .map((doc) => doc.data()['name'] as String)
          .toList();

      setState(() {
        _calves.clear();
        _calves.addAll(calvesList);
      });
    } catch (error) {
      _showSnackBar('Failed to fetch records: $error');
    }
  }

  void _addNewCalf(Calf newCalf) async {
    print("Adding new calf: ${newCalf.name}");
    await _saveCalfToFirebase(newCalf);
    setState(() {
      _calves.add(newCalf);
    });
    print("Clearing form fields");
    _clearCalfForm();
  }

  Future<void> _saveCalfToFirebase(Calf calf) async {
    // Ensure the admin email is set
    if (_adminEmail == null) {
      _showSnackBar('Admin email is not set');
      return;
    }

    // Reference to the admin's calf collection
    String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final calfCollection = FirebaseFirestore.instance
        .collection('calves')
        .doc(_adminEmail) // Use the admin's email as the document ID
        .collection('entries'); // Fetch from the 'entries' subcollection

    try {
      await calfCollection.add({
        'admin_email': _adminEmail, // Optionally include the admin email
        'name': calf.name,
        'birthDate': calf.birthDate,
        'mother': calf.mother,
        'gender': calf.gender,
        'healthStatus': calf.healthStatus,
        'filled_in_by': currentUserEmail
      });
      _showSnackBar('Calf record saved successfully!');
    } catch (error) {
      _showSnackBar('Failed to save calf record: $error');
    }
  }

  void _updateCalf(Calf calf) async {
    if (_adminEmail == null) {
      _showSnackBar('Admin email is not set');
      return;
    }

    final calfDoc = FirebaseFirestore.instance
        .collection('calves')
        .doc(_adminEmail)
        .collection('entries')
        .doc(calf.id);

    try {
      await calfDoc.update({
        'name': calf.name,
        'birthDate': calf.birthDate,
        'gender': calf.gender,
        'healthStatus': calf.healthStatus,
      });

      if (!mounted) return; // Check if the widget is still mounted
      _showSnackBar('Calf record updated successfully!');

      // Refresh the list after updating
      await _fetchCalvesFromFirebase();

      _clearCalfForm(); // Call to clear the fields after updating
    } catch (error) {
      if (!mounted) return; // Check if the widget is still mounted
      _showSnackBar('Failed to update calf record: ${error.toString()}');
    }
  }

  void _clearCalfForm() {
    final calfFormState = context.findAncestorStateOfType<__CalfFormState>();
    calfFormState?.clearFields(); // Ensure you have access to the clear method
  }

  void _deleteCalf(String calfId) async {
    // Ensure the admin email is set
    if (_adminEmail == null) {
      _showSnackBar('Admin email is not set');
      return;
    }

    // Check if calfId is valid
    if (calfId.isEmpty) {
      _showSnackBar('Calf ID is not valid');
      return;
    }

    // Reference to the specific calf document
    final calfDoc = FirebaseFirestore.instance
        .collection('calves')
        .doc(_adminEmail) // Use admin's email as document ID
        .collection('entries')
        .doc(calfId); // Use the calfId directly

    // Log the document path for debugging
    print(
        'Attempting to delete calf with ID: $calfId at path: ${calfDoc.path}');

    try {
      // Attempt to delete the calf document
      await calfDoc.delete();
      _showSnackBar('Calf record deleted successfully!');

      // Refresh the list of calves
      _fetchCalvesFromFirebase();
    } catch (error) {
      // Handle any errors during deletion
      _showSnackBar('Failed to delete calf record: ${error.toString()}');
    }
  }

  Future<void> _fetchMotherNamesFromFirebase() async {
    if (_adminEmail == null) {
      _showSnackBar('Admin email is not set');
      return;
    }

    final cattleCollection = FirebaseFirestore.instance.collection('cattle');
    final motherNamesSnapshot =
        await cattleCollection.doc(_adminEmail).collection('entries').get();

    _motherNames = motherNamesSnapshot.docs
        .map((doc) => doc.data()['name'] as String)
        .toList();

    setState(() {
      // Optionally refresh UI if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calving Management'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _buildDashboard(),
              const SizedBox(height: 20),
              _buildCalfRecordsList(),
              const SizedBox(height: 20),
              _buildAddNewCalfSection(context),
              const SizedBox(height: 20),
              _buildHelpAndSupportSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    int totalCalves = _calves.length;
    int recentCalvings = _calves
        .where((calf) => DateTime.now().difference(calf.birthDate).inDays <= 30)
        .length;

    return Card(
      color: Colors.greenAccent[50],
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDashboardCard('Total Calves', totalCalves),
                _buildDashboardCard('Recent Calvings', recentCalvings),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, int value) {
    return Expanded(
      child: Card(
        color: Colors.white,
        elevation: 6.0,
        margin: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.pets, size: 40, color: Colors.blueAccent),
              const SizedBox(height: 8.0),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4.0),
              Text(
                '$value',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalfRecordsList() {
    if (_calves.isEmpty) {
      return Center(
        child: Text('No calf records available'),
      );
    }
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
            Text(
              'Calf Records',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 16.0),
            ..._calves.map((calf) => _buildCalfRecordTile(calf)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalfRecordTile(Calf calf) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CalfDetailsPage(calf: calf),
          ),
        );
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
        title: Text(calf.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          'Birth Date: ${DateFormat.yMMMd().format(calf.birthDate)}\nMother: ${calf.mother}',
        ),
        leading: Icon(Icons.pets, color: Colors.blueAccent),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.grey),
              onPressed: () {
                _showCalfForm(context, calf);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _confirmDelete(calf.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewCalfSection(BuildContext context) {
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
            Text(
              'Add New Calf',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 16.0),
            _CalfForm(onSubmit: _addNewCalf),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpAndSupportSection() {
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
            Text(
              'Help & Support',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'For assistance, contact our support team at shobbyduncan@gmail.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCalfForm(BuildContext context, Calf? calf) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: _CalfForm(
          calf: calf,
          onSubmit: (updatedCalf) {
            if (calf == null) {
              _addNewCalf(updatedCalf); // Adding new calf
            } else {
              _updateCalf(updatedCalf); // Updating existing calf
            }
            Navigator.pop(context); // Close the modal after submission
          },
        ),
      );
    },
  ).then((_) {
    // After the modal closes, clear the fields
    _clearCalfForm();
  });
}


  Future<void> _confirmDelete(String calfId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this calf record?'),
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
      _deleteCalf(calfId);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _CalfForm extends StatefulWidget {
  final void Function(Calf) onSubmit;
  final Calf? calf;

  const _CalfForm({required this.onSubmit, this.calf});

  @override
  __CalfFormState createState() => __CalfFormState();
}

class __CalfFormState extends State<_CalfForm> {
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  String _mother = '';
  String _gender = 'Male';
  String _healthStatus = 'Healthy';

  // Method to clear the form fields
  void clearFields() {
    _nameController.clear();
    _birthDateController.clear();
    setState(() {
      _mother = '';
      _gender = 'Male';
      _healthStatus = 'Healthy';
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.calf != null) {
      _nameController.text = widget.calf!.name;
      _birthDateController.text =
          DateFormat.yMMMd().format(widget.calf!.birthDate);
      _mother = widget.calf!.mother;
      _gender = widget.calf!.gender;
      _healthStatus = widget.calf!.healthStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    final calvingPageState =
        context.findAncestorStateOfType<_CalvingPageState>();

    // Get the current user's email
    String filledInBy = FirebaseAuth.instance.currentUser?.email ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Calf Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16.0),
        TextField(
          controller: _birthDateController,
          decoration: InputDecoration(
            labelText: 'Birth Date',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.datetime,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              setState(() {
                _birthDateController.text =
                    DateFormat.yMMMd().format(pickedDate);
              });
            }
          },
        ),
        const SizedBox(height: 16.0),
        if (widget.calf == null) ...[
          DropdownButtonFormField<String>(
            value: _mother.isNotEmpty ? _mother : null,
            decoration: InputDecoration(
              labelText: 'Mother Name',
              border: OutlineInputBorder(),
            ),
            items: calvingPageState?._motherNames.map((name) {
              return DropdownMenuItem<String>(
                value: name,
                child: Text(name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _mother = value!;
              });
            },
          ),
          const SizedBox(height: 16.0),
        ],
        DropdownButtonFormField<String>(
          value: _gender,
          decoration: InputDecoration(
            labelText: 'Gender',
            border: OutlineInputBorder(),
          ),
          items: ['Male', 'Female'].map((gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Text(gender),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _gender = value!;
            });
          },
        ),
        const SizedBox(height: 16.0),
        DropdownButtonFormField<String>(
          value: _healthStatus,
          decoration: InputDecoration(
            labelText: 'Health Status',
            border: OutlineInputBorder(),
          ),
          items: ['Healthy', 'Sick'].map((status) {
            return DropdownMenuItem<String>(
              value: status,
              child: Text(status),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _healthStatus = value!;
            });
          },
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty &&
                _birthDateController.text.isNotEmpty) {
              widget.onSubmit(
                Calf(
                  id: widget.calf?.id ?? '',
                  name: _nameController.text,
                  birthDate:
                      DateFormat.yMMMd().parse(_birthDateController.text),
                  mother: widget.calf?.mother ?? _mother,
                  gender: _gender,
                  healthStatus: _healthStatus,
                  filledInBy: filledInBy,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill all fields')),
              );
            }
          },
          child: Text(widget.calf == null ? 'Add Calf' : 'Update Calf'),
        ),
      ],
    );
  }
}

class Calf {
  final String id;
  final String name;
  final DateTime birthDate;
  final String mother;
  final String gender;
  final String healthStatus;
  final String filledInBy;

  Calf({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.mother,
    required this.gender,
    required this.healthStatus,
    required this.filledInBy,
  });
}

class CalfDetailsPage extends StatelessWidget {
  final Calf calf;

  const CalfDetailsPage({Key? key, required this.calf}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${calf.name} Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailCard(Icons.pets, 'Name', calf.name),
              SizedBox(height: 16),
              _buildDetailCard(Icons.calendar_today, 'Birth Date',
                  DateFormat.yMMMd().format(calf.birthDate)),
              SizedBox(height: 16),
              _buildDetailCard(Icons.woman, 'Mother', calf.mother),
              SizedBox(height: 16),
              _buildDetailCard(Icons.male, 'Gender', calf.gender),
              SizedBox(height: 16),
              _buildDetailCard(
                  Icons.health_and_safety, 'Health Status', calf.healthStatus),
              SizedBox(height: 16),
              _buildDetailCard(Icons.person, 'Filled In By', calf.filledInBy),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(IconData icon, String title, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.blueAccent),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(value, style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
