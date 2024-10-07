import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PestControlPage extends StatefulWidget {
  final Future<String?> adminEmailFuture;

  PestControlPage({required this.adminEmailFuture});
  @override
  _PestControlPageState createState() => _PestControlPageState();
}

class _PestControlPageState extends State<PestControlPage> {
  final _pestTypeController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _statusController = TextEditingController();
  final _costController = TextEditingController();
  String? _editingDocId;
  bool _isFormVisible = false;
  CollectionReference? _pestControlCollection;
  String? _adminEmail;

  @override
  void initState() {
    super.initState();
    _fetchAdminEmail();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _fetchAdminEmail() async {
    _adminEmail = await widget.adminEmailFuture;
    print("Admin Email: $_adminEmail"); // Debug print
    if (_adminEmail != null) {
      _initializeCollection(); // Initialize the collection
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Admin email not set')),
      );
    }
  }

  void _initializeCollection() {
    if (_adminEmail != null) {
      setState(() {
        _pestControlCollection = FirebaseFirestore.instance
            .collection('pest_control_records')
            .doc(_adminEmail)
            .collection('entries');
      });
      print('Initialized Collection for Admin: $_adminEmail');
    }
  }

  Future<void> _submitRecord() async {
    if (_pestControlCollection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Collection not initialized')),
      );
      return;
    }

    final pestType = _pestTypeController.text;
    final treatment = _treatmentController.text;
    final status = _statusController.text;
    final cost = double.tryParse(_costController.text) ?? 0.0;

    if (pestType.isNotEmpty && treatment.isNotEmpty && status.isNotEmpty) {
      try {
        if (_editingDocId == null) {
          await _pestControlCollection!.add({
            'pest_type': pestType,
            'treatment': treatment,
            'status': status,
            'date': Timestamp.now(),
            'cost': cost,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pest Control Record Saved')),
          );
        } else {
          await _pestControlCollection!.doc(_editingDocId).update({
            'pest_type': pestType,
            'treatment': treatment,
            'status': status,
            'cost': cost,
          });
          setState(() => _editingDocId = null);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pest Control Record Updated')),
          );
        }

        _pestTypeController.clear();
        _treatmentController.clear();
        _statusController.clear();
        _costController.clear();
        setState(() => _isFormVisible = false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save record: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  Future<void> _confirmDelete(String docId) async {
    if (_pestControlCollection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Collection not initialized')),
      );
      return;
    }

    final result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (result == true) {
      try {
        await _pestControlCollection!.doc(docId).delete();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete record: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pest Control Management'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _buildDashboard(),
              _buildRecordSection(
                'Pest Control Records',
                _buildPestControlRecordsList(),
              ),
              if (_isFormVisible) _buildAddOrEditPestControlSection(),
              _buildHelpAndSupportSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isFormVisible = !_isFormVisible;
            if (!_isFormVisible) {
              _editingDocId = null;
              _pestTypeController.clear();
              _treatmentController.clear();
              _statusController.clear();
              _costController.clear();
            }
          });
        },
        child: Icon(_isFormVisible ? Icons.close : Icons.add),
        backgroundColor: Colors.lightBlueAccent,
      ),
    );
  }

  Widget _buildDashboard() {
    return StreamBuilder<QuerySnapshot>(
      stream: _pestControlCollection?.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No Records Found'));
        }

        final records = snapshot.data!.docs;
        final totalRecords = records.length;

        final todayRecords = records.where((doc) {
          final date = (doc['date'] as Timestamp).toDate();
          return date.day == DateTime.now().day &&
              date.month == DateTime.now().month &&
              date.year == DateTime.now().year;
        }).length;

        final totalCost = records.fold<double>(0.0, (sum, doc) {
          final data = doc.data() as Map<String, dynamic>;
          final cost = data['cost'] as double? ?? 0.0;
          return sum + cost;
        });

        return Card(
          color: Colors.lightBlue[50],
          elevation: 4.0,
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                    Icon(Icons.dashboard,
                        color: Colors.lightBlueAccent, size: 28),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOverviewCard('Total Pest Controls',
                        totalRecords.toString(), Icons.security),
                    _buildOverviewCard('Total Expenses',
                        totalCost.toStringAsFixed(2), Icons.attach_money),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOverviewCard('Pest Controls Today',
                        todayRecords.toString(), Icons.today),
                    _buildOverviewCard('Pest Controls This Month',
                        totalRecords.toString(), Icons.calendar_today),
                  ],
                ),
                const SizedBox(height: 16.0),
                _buildCharts(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon) {
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
              Icon(icon, size: 40, color: Colors.lightBlueAccent),
              const SizedBox(height: 8.0),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4.0),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharts() {
    return StreamBuilder<QuerySnapshot>(
      stream: _pestControlCollection?.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No Records Found'));
        }

        final records = snapshot.data!.docs;
        final monthlyCosts = List.generate(12, (index) => 0.0);

        for (var doc in records) {
          final data = doc.data() as Map<String, dynamic>;
          final date = (data['date'] as Timestamp).toDate();
          final cost =
              data.containsKey('cost') ? (data['cost'] as double? ?? 0.0) : 0.0;
          monthlyCosts[date.month - 1] += cost;
        }

        return Column(
          children: [
            Text(
              'Pest Trends',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlueAccent,
              ),
            ),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: List.generate(12, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: monthlyCosts[index],
                          color: Colors.lightBlueAccent,
                          width: 15,
                        ),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(
                            fontSize: 10,
                            color: Colors.black,
                          );
                          String text;
                          switch (value.toInt()) {
                            case 0:
                              text = 'Jan';
                              break;
                            case 1:
                              text = 'Feb';
                              break;
                            case 2:
                              text = 'Mar';
                              break;
                            case 3:
                              text = 'Apr';
                              break;
                            case 4:
                              text = 'May';
                              break;
                            case 5:
                              text = 'Jun';
                              break;
                            case 6:
                              text = 'Jul';
                              break;
                            case 7:
                              text = 'Aug';
                              break;
                            case 8:
                              text = 'Sep';
                              break;
                            case 9:
                              text = 'Oct';
                              break;
                            case 10:
                              text = 'Nov';
                              break;
                            case 11:
                              text = 'Dec';
                              break;
                            default:
                              text = '';
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(text, style: style),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecordSection(String title, Widget recordsList) {
    return Card(
      color: Colors.white,
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlueAccent,
              ),
            ),
            const SizedBox(height: 16.0),
            recordsList,
          ],
        ),
      ),
    );
  }

  Widget _buildPestControlRecordsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _pestControlCollection?.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No Records Found'));
        }

        final records = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          itemCount: records.length,
          itemBuilder: (context, index) {
            final doc = records[index];
            final date = (doc['date'] as Timestamp).toDate();
            final formattedDate = '${date.day}/${date.month}/${date.year}';

            final data = doc.data() as Map<String, dynamic>;
            final cost = data.containsKey('cost')
                ? (data['cost'] as double?)?.toStringAsFixed(2) ?? '0.00'
                : '0.00';

            return ListTile(
              title: Text('${data['pest_type']} - ${data['treatment']}'),
              subtitle: Text(
                  'Status: ${data['status']} \nDate: $formattedDate \nCost: \$${cost}'),
              trailing: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') {
                    setState(() {
                      _isFormVisible = true;
                      _editingDocId = doc.id;
                      _pestTypeController.text = data['pest_type'];
                      _treatmentController.text = data['treatment'];
                      _statusController.text = data['status'];
                      _costController.text = cost;
                    });
                  } else if (value == 'delete') {
                    _confirmDelete(doc.id);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ];
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAddOrEditPestControlSection() {
    return Card(
      color: Colors.white,
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _editingDocId == null ? 'Add New Record' : 'Edit Record',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlueAccent,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _pestTypeController,
              decoration: InputDecoration(
                labelText: 'Pest Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _treatmentController,
              decoration: InputDecoration(
                labelText: 'Treatment',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _statusController,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _costController,
              decoration: InputDecoration(
                labelText: 'Cost',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitRecord,
              child:
                  Text(_editingDocId == null ? 'Add Record' : 'Update Record'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpAndSupportSection() {
    return Card(
      color: Colors.white,
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Help and Support',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlueAccent,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'For any issues or support, please contact us at shobbyduncan@Gmail.com',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
