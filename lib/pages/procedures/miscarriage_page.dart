import 'package:flutter/material.dart';

class MiscarriagePage extends StatefulWidget {
  @override
  _MiscarriagePageState createState() => _MiscarriagePageState();
}

class _MiscarriagePageState extends State<MiscarriagePage> {
  final _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Miscarriage Records'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Miscarriage Card
              Card(
                color: Colors.white,
                elevation: 4.0,
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
                        'Miscarriage Details',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlueAccent),
                      ),
                      const SizedBox(height: 16.0),
                      _buildMiscarriageForm(),
                    ],
                  ),
                ),
              ),

              // Miscarriage List
              Card(
                color: Colors.white,
                elevation: 4.0,
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
                        'Miscarriage List',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlueAccent),
                      ),
                      const SizedBox(height: 16.0),
                      _buildMiscarriageList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiscarriageForm() {
    return Column(
      children: [
        // Cattle Serial Number
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Select Cattle',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16.0),

        // Date of Miscarriage
        TextFormField(
          controller: _dateController,
          decoration: InputDecoration(
            labelText: 'Date Of Miscarriage',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: GestureDetector(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                 
                  String formattedDate = '${pickedDate.year.toString().padLeft(4, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                  setState(() {
                    _dateController.text = formattedDate;
                  });
                }
              },
              child: Icon(Icons.calendar_today),
            ),
          ),
          keyboardType: TextInputType.datetime,
        ),
        const SizedBox(height: 16.0),

        // Notes
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Notes',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16.0),

        ElevatedButton(
          onPressed: () {
            // Handle form submission
          },
          child: const Text('Submit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiscarriageList() {
    // Placeholder list of miscarriage records
    final List<Map<String, String>> records = [
      {'serial': '1234', 'date': '2024-08-20'},
      {'serial': '5678', 'date': '2024-08-22'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Serial Number')),
          DataColumn(label: Text('Miscarriage Date')),
          DataColumn(label: Text('Actions')),
        ],
        rows: records.map((record) {
          return DataRow(
            cells: [
              DataCell(Text(record['serial']!)),
              DataCell(Text(record['date']!)),
              DataCell(
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    
                  },
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
