import 'package:flutter/material.dart';

class ArtificialInseminationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artificial Insemination'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: Colors.grey[200], // Background color for the whole page
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10)), // Rounded top corners
                    child: Image.asset(
                      'assets/insem.jpeg', // Update with your image path
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Artificial Insemination',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
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

            // Button to open modal
            ElevatedButton(
              onPressed: () => _showInseminationModal(context),
              child: Text('Inseminate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),

            SizedBox(height: 20),

            // AI List Header
            Text(
              'Artificial Insemination List',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
            ),

            // AI List Table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Serial Number')),
                    DataColumn(label: Text('Vet Name')),
                    DataColumn(label: Text('Donor Breed')),
                    DataColumn(label: Text('Delete')),
                  ],
                  rows: [
                    // Example Row
                    DataRow(cells: [
                      DataCell(Text('2024-08-25')),
                      DataCell(Text('SN12345')),
                      DataCell(Text('Dr. John')),
                      DataCell(Text('Holstein Friesian')),
                      DataCell(IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Handle delete action
                        },
                      )),
                    ]),
                    // Add more rows here
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInseminationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows the modal to adapt its size based on its content
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Artificial Insemination',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 10),
                // Cattle selection
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Select Cattle'),
                  items: [
                    DropdownMenuItem(value: 'Cattle1', child: Text('Cattle1')),
                    DropdownMenuItem(value: 'Cattle2', child: Text('Cattle2')),
                    // Add more cattle options here
                  ],
                  onChanged: (value) {},
                ),
                SizedBox(height: 10),
                // Date of Insemination
                TextFormField(
                  decoration:
                      InputDecoration(labelText: 'Date Of Insemination'),
                  keyboardType: TextInputType.datetime,
                ),
                SizedBox(height: 10),
                // Vet Name
                TextFormField(
                  decoration:
                      InputDecoration(labelText: 'Veterinary Doctor\'s Name'),
                ),
                SizedBox(height: 10),
                // Semen Breed
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Semen Breed'),
                  items: [
                    DropdownMenuItem(
                        value: 'Holstein Friesian',
                        child: Text('Holstein Friesian')),
                    DropdownMenuItem(value: 'Jersey', child: Text('Jersey')),
                    // Add more semen breeds here
                  ],
                  onChanged: (value) {},
                ),
                SizedBox(height: 10),
                // Sexed
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Sexed'),
                  items: [
                    DropdownMenuItem(value: 'Yes', child: Text('Yes')),
                    DropdownMenuItem(value: 'No', child: Text('No')),
                  ],
                  onChanged: (value) {},
                ),
                SizedBox(height: 10),
                // Notes
                TextFormField(
                  decoration: InputDecoration(labelText: 'Notes'),
                  maxLines: 3,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Handle submit action
                      },
                      child: Text('Submit'),
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
                      child: Text('Close'),
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
}
