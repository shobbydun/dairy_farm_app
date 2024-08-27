import 'package:flutter/material.dart';

class PregnancyPage extends StatefulWidget {
  @override
  _PregnancyPageState createState() => _PregnancyPageState();
}

class _PregnancyPageState extends State<PregnancyPage> {
  DateTime? _expectedDateOfBirth;

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
              _buildPregnancyCard(context), // Pass context here
              _buildPregnancyListSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build the Pregnancy Management Card
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
                    _showPregnancyModal(context); // context is available here
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

  // Method to build Pregnancy List Section
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
            Table(
              columnWidths: {
                0: FlexColumnWidth(),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
                3: FixedColumnWidth(64.0),
              },
              children: [
                TableRow(
                  children: [
                    _tableHeaderCell('Cattle ID'),
                    _tableHeaderCell('Date of Conceiving'),
                    _tableHeaderCell('Expected Date of Birth'),
                    _tableHeaderCell('Actions'),
                  ],
                ),
                // Replace with dynamic data fetching and rendering logic
                TableRow(
                  children: [
                    _tableCell('001'),
                    _tableCell('2024-01-15'),
                    _tableCell('2024-10-15'),
                    IconButton(
                      onPressed: () {
                        // Handle delete action
                      },
                      icon: Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableHeaderCell(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold, 
          color: Colors.lightBlueAccent,
        ),
      ),
    );
  }

  Widget _tableCell(String content) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(content),
    );
  }

  void _showPregnancyModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Pregnancy'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField('Cattle ID', TextInputType.number),
                _buildDatePickerField(context, 'Date of Detection'),
                _buildDatePickerField(context, 'Expected Date of Birth'),
                _buildTextField('Notes', TextInputType.text),
                _buildTextField('Cost (if applicable)', TextInputType.number),
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
              child: Text('Submit', style: TextStyle(color: Colors.lightBlueAccent)),
              onPressed: () {
                // Handle form submission logic here
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextInputType inputType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context, String label) {
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
            setState(() {
              if (label == 'Expected Date of Birth') {
                _expectedDateOfBirth = pickedDate;
              }
            });
          }
        },
        controller: TextEditingController(
          text: _expectedDateOfBirth != null
              ? "${_expectedDateOfBirth!.toLocal()}".split(' ')[0]
              : '',
        ),
      ),
    );
  }
}

// void main() {
//   runApp(MaterialApp(
//     home: PregnancyPage(),
//   ));
// }
