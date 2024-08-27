import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NaturalInseminationPage extends StatefulWidget {
  @override
  _NaturalInseminationPageState createState() => _NaturalInseminationPageState();
}

class _NaturalInseminationPageState extends State<NaturalInseminationPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _cattleIdController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  String? _selectedBreed;

  void _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _showAddInseminationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Insemination Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date picker for date of insemination
                TextField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Date of Insemination',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  keyboardType: TextInputType.datetime,
                  readOnly: true,
                ),
                // Dropdown for cattle ID selection
                TextField(
                  controller: _cattleIdController,
                  decoration: InputDecoration(labelText: 'Cattle ID'),
                  keyboardType: TextInputType.number,
                ),
                // Dropdown for father breed selection
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Father's Breed"),
                  value: _selectedBreed,
                  items: ['Holstein Friesian', 'Jersey', 'Guernsey', 'Brown Swiss', 'Ayrshire']
                      .map((breed) => DropdownMenuItem(
                            value: breed,
                            child: Text(breed),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBreed = value;
                    });
                  },
                ),
                // Notes text field
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(labelText: 'Notes'),
                  maxLines: 3,
                ),
                // Cost text field
                TextField(
                  controller: _costController,
                  decoration: InputDecoration(labelText: 'Cost'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle form submission
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Natural Insemination'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Overview Section
              _buildOverviewCard('Natural Insemination', 'Track and Manage', 'Details of natural insemination events'),
              
              const SizedBox(height: 16.0),

              // Button to add new insemination record
              ElevatedButton(
                onPressed: () => _showAddInseminationDialog(context),
                child: const Text('Add New Insemination Record'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 16.0),

              // List of insemination records
              _buildInseminationList(),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build an overview card
  Widget _buildOverviewCard(String title, String subtitle, String description) {
    return Card(
      color: Colors.white,
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Text(description, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // Method to build the list of insemination records
  Widget _buildInseminationList() {
    // Example static data for insemination records
    List<Map<String, String>> inseminationRecords = [
      {'date': '2024-08-25', 'cattleId': '101', 'fatherBreed': 'Holstein Friesian'},
      {'date': '2024-08-20', 'cattleId': '102', 'fatherBreed': 'Jersey'},
      {'date': '2024-08-18', 'cattleId': '103', 'fatherBreed': 'Guernsey'},
    ];

    return Column(
      children: inseminationRecords.map((record) {
        return Card(
          color: Colors.white,
          elevation: 4.0,
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${record['date']}', style: const TextStyle(fontSize: 16)),
                Text('Cattle ID: ${record['cattleId']}', style: const TextStyle(fontSize: 16)),
                Text('Father Breed: ${record['fatherBreed']}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Handle deletion
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: NaturalInseminationPage(),
  ));
}
