import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalvingPage extends StatefulWidget {
  const CalvingPage({super.key});

  @override
  _CalvingPageState createState() => _CalvingPageState();
}

class _CalvingPageState extends State<CalvingPage> {
  final List<Calf> _calves = [];
  List<String> _motherNames = [];

  @override
  void initState() {
    super.initState();
    _fetchCalvesFromFirebase();
  }

  Future<void> _fetchCalvesFromFirebase() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _showSnackBar('User not logged in');
      return;
    }
    final cattleCollection = FirebaseFirestore.instance.collection('cattle');
    final calfCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('calves');
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
        );
      }).toList();

      // Fetch cattle names for dropdown
      final cattleSnapshot = await cattleCollection.where('userId', isEqualTo: uid).get();
      _motherNames = cattleSnapshot.docs.map((doc) => doc.data()['name'] as String).toList();

      setState(() {
        _calves.clear();
        _calves.addAll(calvesList);
      });
    } catch (error) {
      _showSnackBar('Failed to fetch records: $error');
    }
  }

  void _addNewCalf(Calf newCalf) {
    setState(() {
      _calves.add(newCalf);
    });
    _saveCalfToFirebase(newCalf);
  }

  void _saveCalfToFirebase(Calf calf) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _showSnackBar('User not logged in');
      return;
    }

    final calfCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('calves');

    try {
      await calfCollection.add({
        'name': calf.name,
        'birthDate': calf.birthDate,
        'mother': calf.mother,
        'gender': calf.gender,
        'healthStatus': calf.healthStatus,
      });
      _showSnackBar('Calf record saved successfully!');
    } catch (error) {
      _showSnackBar('Failed to save calf record: $error');
    }
  }

  void _updateCalf(Calf calf) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _showSnackBar('User not logged in');
      return;
    }

    final calfDoc =
        FirebaseFirestore.instance.collection('users').doc(uid).collection('calves').doc(calf.id);

    try {
      await calfDoc.update({
        'name': calf.name,
        'birthDate': calf.birthDate,
        'mother': calf.mother,
        'gender': calf.gender,
        'healthStatus': calf.healthStatus,
      });
      _showSnackBar('Calf record updated successfully!');
      _fetchCalvesFromFirebase(); // Refresh list
    } catch (error) {
      _showSnackBar('Failed to update calf record: $error');
    }
  }

  void _deleteCalf(String calfId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _showSnackBar('User not logged in');
      return;
    }

    final calfDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('calves')
        .doc(calfId);

    try {
      await calfDoc.delete();
      _showSnackBar('Calf record deleted successfully!');
      _fetchCalvesFromFirebase(); // Refresh list
    } catch (error) {
      _showSnackBar('Failed to delete calf record: $error');
    }
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
      title:
          Text(calf.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
          'Birth Date: ${DateFormat.yMMMd().format(calf.birthDate)}\nMother: ${calf.mother}'),
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
                _addNewCalf(updatedCalf);
              } else {
                _updateCalf(updatedCalf);
              }
              Navigator.pop(context);
            },
          ),
        );
      },
    );
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
  final _motherController = TextEditingController();
  String _mother = ''; 
  String _gender = 'Male';
  String _healthStatus = 'Healthy';

  @override
  void initState() {
    super.initState();
    if (widget.calf != null) {
      _nameController.text = widget.calf!.name;
      _birthDateController.text =
          DateFormat.yMMMd().format(widget.calf!.birthDate);
      _motherController.text = widget.calf!.mother;
      _gender = widget.calf!.gender;
      _healthStatus = widget.calf!.healthStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    final calvingPageState = context.findAncestorStateOfType<_CalvingPageState>();

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
                _birthDateController.text.isNotEmpty &&
                _mother.isNotEmpty) {
              widget.onSubmit(
                Calf(
                  id: widget.calf?.id ?? '',
                  name: _nameController.text,
                  birthDate: DateFormat.yMMMd().parse(_birthDateController.text),
                  mother: _mother,
                  gender: _gender,
                  healthStatus: _healthStatus,
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

  Calf({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.mother,
    required this.gender,
    required this.healthStatus,
  });
}
