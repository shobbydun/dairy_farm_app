import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DehorningPage extends StatefulWidget {
  const DehorningPage({Key? key}) : super(key: key);

  @override
  _DehorningPageState createState() => _DehorningPageState();
}

class _DehorningPageState extends State<DehorningPage> {
  List<QueryDocumentSnapshot> records = [];
  int totalDehornings = 0;
  int pendingProcedures = 0;
  double successRate = 0.0;
  List<QueryDocumentSnapshot> recentActivities = [];

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('dehorning').get();
    final allRecords = snapshot.docs;
    setState(() {
      records = allRecords;
      totalDehornings = allRecords.length;

      // Calculate pending procedures
      pendingProcedures = allRecords.where((record) {
        final data = record.data() as Map<String, dynamic>;
        return !(data['isCompleted'] ?? false); 
      }).length;

      // Get recent activities (e.g., last 5 records sorted by date)
      recentActivities = allRecords.where((record) {
        final data = record.data() as Map<String, dynamic>;
        return data['date'] != null; // Filter out records with no date
      }).toList()
        ..sort((a, b) {
          final dateA = (a.data() as Map<String, dynamic>)['date'] as String?;
          final dateB = (b.data() as Map<String, dynamic>)['date'] as String?;
          if (dateA == null || dateB == null) return 0; // Handle null dates
          return DateTime.parse(dateB)
              .compareTo(DateTime.parse(dateA)); // Sort by date descending
        });

      // Limit to the most recent 5 records
      recentActivities = recentActivities.take(5).toList();
    });
  }

  void _submitProcedureDetails(String cattleId, String date, String vetName,
      String? method, String notes) async {
    if (method != null) {
      await FirebaseFirestore.instance.collection('dehorning').add({
        'cattle_id': cattleId,
        'date': date,
        'veterinarian': vetName,
        'method': method,
        'notes': notes,
        'status': 'pending', // Add a status field
        'isCompleted': false, // Default to not completed
      });
      _fetchRecords(); // Refresh records after submission
    }
  }

  void _updateCompletionStatus(String id, bool isCompleted) async {
    await FirebaseFirestore.instance.collection('dehorning').doc(id).update({
      'isCompleted': isCompleted,
    });
    _fetchRecords(); // Refresh records after update
  }

  void _showDehorningModal(
      {String? id,
      String? cattleId,
      String? date,
      String? vetName,
      String? methodOfDehorning}) {
    final TextEditingController cattleIdController =
        TextEditingController(text: cattleId);
    final TextEditingController dateController =
        TextEditingController(text: date);
    final TextEditingController vetNameController =
        TextEditingController(text: vetName);
    String? method = methodOfDehorning;
    DateTime? selectedDate;

    void _selectDate() async {
      DateTime currentDate = DateTime.now();
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? currentDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (pickedDate != null && pickedDate != selectedDate) {
        selectedDate = pickedDate;
        dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(id == null ? 'Schedule Dehorning' : 'Edit Dehorning Record'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField(
                  items: ['Cattle 1', 'Cattle 2'].map((String cattle) {
                    return DropdownMenuItem(
                      value: cattle,
                      child: Text(cattle),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    cattleIdController.text = newValue ?? '';
                  },
                  value: cattleId,
                  decoration: const InputDecoration(
                    labelText: 'Select Cattle',
                  ),
                ),
                TextField(
                  controller: dateController,
                  decoration:
                      const InputDecoration(labelText: 'Date Of Dehorning'),
                  keyboardType: TextInputType.datetime,
                  onTap: _selectDate,
                  readOnly: true, // Make it read-only to prevent manual entry
                ),
                TextField(
                  controller: vetNameController,
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
                    method = newValue;
                  },
                  value: methodOfDehorning,
                  decoration: const InputDecoration(
                    labelText: 'Method Of Dehorning',
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (id == null) {
                      // Add new record
                      _submitProcedureDetails(
                        cattleIdController.text,
                        dateController.text,
                        vetNameController.text,
                        method,
                        '',
                      );
                    } else {
                      // Update existing record
                      await FirebaseFirestore.instance
                          .collection('dehorning')
                          .doc(id)
                          .update({
                        'cattle_id': cattleIdController.text,
                        'date': dateController.text,
                        'veterinarian': vetNameController.text,
                        'method': method,
                        // Ensure to update the status if necessary
                      });
                      _fetchRecords(); // Refresh records after update
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('Submit',
                      style: TextStyle(color: Colors.white)),
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
          title: const Text(
            'Notifications',
            style: TextStyle(color: Colors.blueAccent),
          ),
          content: const Text('No new notifications.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRecord(String id) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content:
                  const Text('Are you sure you want to delete this record?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (shouldDelete) {
      await FirebaseFirestore.instance.collection('dehorning').doc(id).delete();
      _fetchRecords(); // Refresh records after deletion
    }
  }

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
            _buildDashboardOverview(context),
            _buildDehorningRecords(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDehorningModal(); // Schedule a new procedure
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
              _buildDashboardCard(
                context,
                'Total Dehornings: $totalDehornings',
                Icons.analytics,
                Colors.blueAccent,
              ),
              SizedBox(width: 16),
              _buildDashboardCard(
                context,
                'Pending Procedures: $pendingProcedures',
                Icons.pending_actions,
                Colors.orange,
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              SizedBox(width: 16),
              _buildDashboardCard(
                context,
                'Recent Activities',
                Icons.history,
                Colors.blue,
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildRecentActivities(context),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
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

  Widget _buildRecentActivities(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activities',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.blueAccent),
            ),
            SizedBox(height: 16),
            ...recentActivities.map((record) {
              final data = record.data() as Map<String, dynamic>;
              final id = record.id;
              final isCompleted = data['isCompleted'] ?? false;

              return ListTile(
                title: Text(data['cattle_id'] ?? 'No Cattle ID'),
                subtitle: Text(
                    'Date: ${data['date'] ?? 'N/A'}, Method: ${data['method'] ?? 'N/A'}'),
                trailing: Checkbox(
                  value: isCompleted,
                  onChanged: (bool? value) {
                    if (value != null) {
                      _updateCompletionStatus(id, value);
                    }
                  },
                ),
              );
            }).toList(),
          ],
        ),
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('dehorning')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(child: Text('No records available')),
                  );
                }

                final records = snapshot.data!.docs;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Cattle ID')),
                      DataColumn(label: Text('Method')),
                      DataColumn(label: Text('Veterinarian')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: records.map((record) {
                      final data = record.data() as Map<String, dynamic>;
                      final id = record.id;

                      return DataRow(
                        cells: [
                          DataCell(Text(data['date'] ?? '')),
                          DataCell(Text(data['cattle_id'] ?? '')),
                          DataCell(Text(data['method'] ?? '')),
                          DataCell(Text(data['veterinarian'] ?? '')),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showDehorningModal(
                                    id: id,
                                    cattleId: data['cattle_id'],
                                    date: data['date'],
                                    vetName: data['veterinarian'],
                                    methodOfDehorning: data['method'],
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _deleteRecord(id);
                                },
                              ),
                            ],
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
