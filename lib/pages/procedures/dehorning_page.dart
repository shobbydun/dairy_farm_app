import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DehorningPage extends StatefulWidget {
  const DehorningPage({Key? key}) : super(key: key);

  @override
  _DehorningPageState createState() => _DehorningPageState();
}

class _DehorningPageState extends State<DehorningPage> {
  List<QueryDocumentSnapshot> cattleRecords = [];
  final TextEditingController costController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCattleRecords();
  }

  Future<void> _fetchCattleRecords() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _showSnackBar('User not logged in.');
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('cattle')
        .where('userId', isEqualTo: userId)
        .get();
    setState(() {
      cattleRecords = snapshot.docs;
    });
  }

  void _submitProcedureDetails(String cattleId, String date, String vetName,
      String? method, String notes, double cost) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _showSnackBar('User not logged in.');
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('dehorning')
        .add({
      'cattle_id': cattleId,
      'date': date,
      'veterinarian': vetName,
      'method': method,
      'notes': notes,
      'cost': cost,
      'isCompleted': false,
    });
  }

  void _updateRecord(String id, String cattleId, String date,
      String vetName, String? method, double cost) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _showSnackBar('User not logged in.');
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('dehorning')
        .doc(id)
        .update({
      'cattle_id': cattleId,
      'date': date,
      'veterinarian': vetName,
      'method': method,
      'cost': cost,
    });
  }

  void _updateCompletionStatus(String id, bool isCompleted) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _showSnackBar('User not logged in.');
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('dehorning')
        .doc(id)
        .update({
      'isCompleted': isCompleted,
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dehorning Management'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDashboardOverview(),
            _buildDehorningRecords(userId),
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

  Widget _buildDashboardOverview() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .collection('dehorning')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();

              final records = snapshot.data!.docs;
              final totalDehornings = records.length;
              final pendingProcedures = records.where((record) => !(record['isCompleted'] ?? false)).length;

              return Row(
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
              );
            },
          ),
          SizedBox(height: 16),
          _buildRecentActivities(),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, IconData icon, Color color) {
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

  Widget _buildRecentActivities() {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activities',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.blueAccent),
            ),
            SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .collection('dehorning')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Container();

                final records = snapshot.data!.docs;
                return Column(
                  children: records.map((record) {
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDehorningRecords(String? userId) {
    if (userId == null) {
      return Center(child: Text('User not logged in.'));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dehorning Records',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.blueAccent),
          ),
          SizedBox(height: 16),
          Card(
            elevation: 5,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('dehorning')
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                      DataColumn(label: Text('Cost')),
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
                          DataCell(Text(data['cost']?.toString() ?? '')),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  costController.text = data['cost']?.toString() ?? ''; // Set the cost for editing
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

  void _deleteRecord(String id) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this record?'),
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
    ) ?? false;

    if (shouldDelete) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        _showSnackBar('User not logged in.');
        return;
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('dehorning')
          .doc(id)
          .delete();
    }
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
          title: Text(id == null ? 'Schedule Dehorning' : 'Edit Dehorning Record'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField(
                  items: cattleRecords.map((record) {
                    final data = record.data() as Map<String, dynamic>;
                    return DropdownMenuItem(
                      value: data['name'],
                      child: Text(data['name']),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    cattleIdController.text = (newValue as String?) ?? '';
                  },
                  value: cattleId,
                  decoration: const InputDecoration(
                    labelText: 'Select Cattle',
                  ),
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Date Of Dehorning'),
                  keyboardType: TextInputType.datetime,
                  onTap: _selectDate,
                  readOnly: true,
                ),
                TextField(
                  controller: vetNameController,
                  decoration: const InputDecoration(
                      labelText: 'Veterinary Doctor\'s Name'),
                ),
                DropdownButtonFormField(
                  items: [
                    'Burning',
                    'Chemical',
                    'Surgical',
                    'Electrolytic',
                    'Hot Iron'
                  ].map((String method) {
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
                TextField(
                  controller: costController,
                  decoration: const InputDecoration(labelText: 'Cost of Dehorning'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    double cost = double.tryParse(costController.text) ?? 0.0;
                    if (id == null) {
                      // Add new record
                      _submitProcedureDetails(
                        cattleIdController.text,
                        dateController.text,
                        vetNameController.text,
                        method,
                        '',
                        cost,
                      );
                    } else {
                      // Update existing record
                      _updateRecord(
                        id,
                        cattleIdController.text,
                        dateController.text,
                        vetNameController.text,
                        method,
                        cost,
                      );
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('Submit', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
