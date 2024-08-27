import 'package:dairy_harbor/pages/inventory/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalvingPage extends StatefulWidget {
  const CalvingPage({super.key});

  @override
  _CalvingPageState createState() => _CalvingPageState();
}

class _CalvingPageState extends State<CalvingPage> {
  final List<Calf> _calves = []; // List to hold calf records

  void _addNewCalf(Calf newCalf) {
    setState(() {
      _calves.add(newCalf);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calving Management'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationScreen()),
                  );
            },
          ),
        ],
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
    int recentCalvings = _calves.where((calf) => DateTime.now().difference(calf.birthDate).inDays <= 30).length;

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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4.0),
              Text(
                '$value',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
      title: Text(calf.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('Birth Date: ${DateFormat.yMMMd().format(calf.birthDate)}\nMother: ${calf.mother}'),
      leading: Icon(Icons.pets, color: Colors.blueAccent),
      trailing: Icon(Icons.edit, color: Colors.grey),
      onTap: () {
        // Handle calf detail view or edit
      },
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
              'For assistance, contact our support team at support@dairyfarmapp.com',
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
}

class _CalfForm extends StatefulWidget {
  final void Function(Calf) onSubmit;

  const _CalfForm({required this.onSubmit});

  @override
  __CalfFormState createState() => __CalfFormState();
}

class __CalfFormState extends State<_CalfForm> {
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _motherController = TextEditingController();
  String _gender = 'Male';
  String _healthStatus = 'Healthy';

  @override
  Widget build(BuildContext context) {
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
                _birthDateController.text = DateFormat.yMMMd().format(pickedDate);
              });
            }
          },
        ),
        const SizedBox(height: 16.0),
        TextField(
          controller: _motherController,
          decoration: InputDecoration(
            labelText: 'Mother Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16.0),
        DropdownButtonFormField<String>(
          value: _gender,
          items: ['Male', 'Female'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _gender = newValue!;
            });
          },
          decoration: InputDecoration(
            labelText: 'Gender',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16.0),
        DropdownButtonFormField<String>(
          value: _healthStatus,
          items: ['Healthy', 'Sick', 'Injured'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _healthStatus = newValue!;
            });
          },
          decoration: InputDecoration(
            labelText: 'Health Status',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty &&
                _birthDateController.text.isNotEmpty &&
                _motherController.text.isNotEmpty) {
              widget.onSubmit(
                Calf(
                  name: _nameController.text,
                  birthDate: DateFormat.yMMMd().parse(_birthDateController.text),
                  mother: _motherController.text,
                  gender: _gender,
                  healthStatus: _healthStatus,
                ),
              );
              _nameController.clear();
              _birthDateController.clear();
              _motherController.clear();
              setState(() {
                _gender = 'Male';
                _healthStatus = 'Healthy';
              });
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

class Calf {
  final String name;
  final DateTime birthDate;
  final String mother;
  final String gender;
  final String healthStatus;

  Calf({
    required this.name,
    required this.birthDate,
    required this.mother,
    required this.gender,
    required this.healthStatus,
  });
}
