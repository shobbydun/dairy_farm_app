import 'package:dairy_harbor/components/inventory_components/add_wage_page.dart';
import 'package:dairy_harbor/components/inventory_components/edit_wage_page.dart';
import 'package:dairy_harbor/main.dart';
import 'package:dairy_harbor/services_functions/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdministrativeWages extends StatefulWidget {
  final Future<String?> adminEmailFuture;
  AdministrativeWages({super.key, required this.adminEmailFuture});
  @override
  _AdministrativeWagesState createState() => _AdministrativeWagesState();
}

class _AdministrativeWagesState extends State<AdministrativeWages> {
  late FirestoreServices _firestoreServices;
  List<Map<String, dynamic>> _wages = [];
  List<Map<String, dynamic>> _filteredWages = [];
  String _selectedFilter = '';
  final TextEditingController _searchController = TextEditingController();
  String? _adminEmail;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final adminEmailFuture =
        getAdminEmailFromFirestore(); // Update to get admin email if necessary
    _firestoreServices = FirestoreServices(userId, adminEmailFuture);
    _loadWages();
    _fetchAdminEmail();
    _searchController.addListener(_filterWages);
  }

  Future<void> _fetchAdminEmail() async {
    _adminEmail = await widget.adminEmailFuture;
    print('Admin Email: $_adminEmail');
    _loadWages();
    setState(() {});
  }

  Future<void> _loadWages() async {
    try {
      final wages = await _firestoreServices.getWages();
      setState(() {
        _wages = wages;
        _filteredWages = wages;
      });
    } catch (e) {
      print("Error loading wages: $e");
    }
  }

  Future<void> _addWage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddWagePage()),
    );
    _loadWages();
  }

  Future<void> _editWage(String docId, String employeeName, String department,
      String date, String wage) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditWagePage(
          docId: docId,
          employeeName: employeeName,
          department: department,
          date: date,
          wage: wage,
        ),
      ),
    );
    _loadWages();
  }

  Future<void> _deleteWage(String docId) async {
    try {
      await _firestoreServices.deleteWage(docId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wage record deleted')),
      );
      _loadWages();
    } catch (e) {
      print("Error deleting wage: $e");
    }
  }

  void _filterWages() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredWages = _wages.where((wage) {
        final name = (wage['employeeName'] ?? '').toLowerCase();
        final department = (wage['department'] ?? '').toLowerCase();
        final date = (wage['date'] ?? '').toLowerCase();
        final wageStr = (wage['wage'] ?? '').toLowerCase();

        if (_selectedFilter == 'Date') {
          return date.contains(query);
        } else if (_selectedFilter == 'Employee') {
          return name.contains(query);
        } else if (_selectedFilter == 'Department') {
          return department.contains(query);
        } else {
          return name.contains(query) ||
              department.contains(query) ||
              date.contains(query) ||
              wageStr.contains(query);
        }
      }).toList();
    });
  }


  void _applyFilter(String? value) {
    setState(() {
      _selectedFilter = value ?? '';
      _filterWages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Administrative Wages",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addWage,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search by Employee Name, Department, or Date',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter by:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: DropdownButton<String>(
                      hint: Text('Select filter'),
                      value:
                          _selectedFilter.isNotEmpty ? _selectedFilter : null,
                      items: [
                        DropdownMenuItem(
                          value: 'Date',
                          child: Text('Date',
                              style: TextStyle(color: Colors.black)),
                        ),
                        DropdownMenuItem(
                          value: 'Employee',
                          child: Text('Employee',
                              style: TextStyle(color: Colors.black)),
                        ),
                        DropdownMenuItem(
                          value: 'Department',
                          child: Text('Department',
                              style: TextStyle(color: Colors.black)),
                        ),
                      ],
                      onChanged: _applyFilter,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      isExpanded: false,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Total Wages: Kshs ${_calculateTotalWages()}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columnSpacing: 16.0,
                    headingRowHeight: 56.0,
                    dataRowHeight: 60.0,
                    columns: const [
                      DataColumn(
                          label: Text(
                        'Employee Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataColumn(
                          label: Text(
                        'Department',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataColumn(
                          label: Text(
                        'Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataColumn(
                          label: Text(
                        'Wage',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataColumn(
                          label: Text(
                        'Actions',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                    ],
                    rows: _filteredWages.map((wage) {
                      return DataRow(
                        cells: [
                          DataCell(Text(wage['employeeName'] ?? '')),
                          DataCell(Text(wage['department'] ?? '')),
                          DataCell(Text(wage['date'] ?? '')),
                          DataCell(Text(wage['wage'] ?? '')),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit,
                                      color: Colors.blueAccent),
                                  onPressed: () {
                                    _editWage(
                                      wage['id'] ?? '',
                                      wage['employeeName'] ?? '',
                                      wage['department'] ?? '',
                                      wage['date'] ?? '',
                                      wage['wage'] ?? '',
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () {
                                    showDeleteWageDialog(context, () {
                                      _deleteWage(wage['id'] ?? '');
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Calculate total wages
  String _calculateTotalWages() {
    double total = 0.0;
    for (var wage in _filteredWages) {
      final wageString =
          (wage['wage'] ?? '').replaceAll('Kshs ', '').replaceAll(',', '');
      final wageValue = double.tryParse(wageString) ?? 0.0;
      total += wageValue;
    }
    return total.toStringAsFixed(2);
  }

  // Show delete wage dialog
  void showDeleteWageDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Wage'),
          content: Text('Are you sure you want to delete this wage record?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
