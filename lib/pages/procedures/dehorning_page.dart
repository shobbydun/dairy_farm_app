import 'package:flutter/material.dart';
//import 'package:syncfusion_flutter_calendar/calendar.dart'; // For calendar view

class DehorningPage extends StatelessWidget {
  const DehorningPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dehorning Management'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              _showNotificationModal(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard Overview
            _buildDashboardOverview(context),

            // Dehorning Schedule
            _buildDehorningSchedule(context),

            // Dehorning Records
            _buildDehorningRecords(context),

            // Procedure Details Form
            _buildProcedureDetails(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDehorningModal(context);
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDashboardOverview(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              _buildDashboardCard(context, 'Total Dehornings', Icons.analytics,
                  Colors.blueAccent),
              SizedBox(width: 16),
              _buildDashboardCard(context, 'Pending Procedures',
                  Icons.pending_actions, Colors.orange),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildDashboardCard(
                  context, 'Success Rate', Icons.check_circle, Colors.green),
              SizedBox(width: 16),
              _buildDashboardCard(
                  context, 'Recent Activities', Icons.history, Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context, String title, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 40, color: color),
              SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDehorningSchedule(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 5,
            //
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _showScheduleModal(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
            ),
            child: const Text('Schedule New Procedure'),
          ),
        ],
      ),
    );
  }

  Widget _buildDehorningRecords(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dehorning Records',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.blueAccent),
          ),
          SizedBox(height: 16),
          Card(
            elevation: 5,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Cattle ID')),
                  DataColumn(label: Text('Method')),
                  DataColumn(label: Text('Veterinarian')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: List.generate(10, (index) {
                  return DataRow(
                    cells: [
                      DataCell(Text('2024-08-26')),
                      DataCell(Text('Cattle ${index + 1}')),
                      DataCell(Text('Method ${index + 1}')),
                      DataCell(Text('Vet ${index + 1}')),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // Handle edit action
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              // Handle delete action
                            },
                          ),
                        ],
                      )),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcedureDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Procedure Details',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Cattle ID'),
                  ),
                  TextField(
                    decoration:
                        const InputDecoration(labelText: 'Date Of Dehorning'),
                    keyboardType: TextInputType.datetime,
                  ),
                  TextField(
                    decoration: const InputDecoration(
                        labelText: 'Veterinary Doctor\'s Name'),
                  ),
                  DropdownButtonFormField(
                    items: ['Burning', 'Chemical'].map((String method) {
                      return DropdownMenuItem(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      // Handle change
                    },
                    decoration: const InputDecoration(
                      labelText: 'Method Of Dehorning',
                    ),
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Handle submit logic
                    },
                    child: const Text('Submit'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDehorningModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Schedule Dehorning',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField(
                  items: ['Cattle 1', 'Cattle 2'].map((String cattle) {
                    return DropdownMenuItem(
                      value: cattle,
                      child: Text(cattle),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    // Handle selection
                  },
                  decoration: const InputDecoration(
                    labelText: 'Select Cattle',
                  ),
                ),
                TextField(
                  decoration:
                      const InputDecoration(labelText: 'Date Of Dehorning'),
                  keyboardType: TextInputType.datetime,
                ),
                TextField(
                  decoration: const InputDecoration(
                      labelText: 'Veterinary Doctor\'s Name'),
                ),
                DropdownButtonFormField(
                  items: ['Burning', 'Chemical'].map((String method) {
                    return DropdownMenuItem(
                      value: method,
                      child: Text(method),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    // Handle change
                  },
                  decoration: const InputDecoration(
                    labelText: 'Method Of Dehorning',
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Handle submit logic
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotificationModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notifications'),
          content: const Text('No new notifications at this time.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showScheduleModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Schedule New Procedure',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add form fields here similar to _buildProcedureDetails()
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle schedule submission
              },
              child: const Text('Schedule'),
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            ),
          ],
        );
      },
    );
  }
}
