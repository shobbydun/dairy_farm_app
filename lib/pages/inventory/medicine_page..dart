import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:dairy_harbor/components/inventory_components/add_medicine_page.dart';
import 'package:dairy_harbor/components/inventory_components/edit_medicine_page.dart';
import 'package:dairy_harbor/components/inventory_components/medicine_detail_page.dart';
import 'package:flutter/material.dart';

class MedicinePage extends StatefulWidget {
  const MedicinePage({super.key});

  @override
  _MedicinePageState createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _filterValue = 'Select filter';
  String _searchQuery = '';
  late Stream<QuerySnapshot> _medicinesStream;
  String _sortField = 'addedDate'; 
  bool _ascending = false; 

  @override
  void initState() {
    super.initState();
    _updateStream();
  }

  void _updateStream() {
    Query query = _firestore.collection('medicines');

    //  sorting
    if (_sortField == 'expiryDate') {
      query = query.orderBy('expiryDate', descending: _ascending);
    } else if (_sortField == 'name') {
      query = query.orderBy('name');
    } else if (_sortField == 'supplier') {
      query = query.orderBy('supplier');
    }

    //  search query
    _medicinesStream = query.snapshots();
  }

  Future<void> _deleteMedicine(String medicineId) async {
    try {
      await _firestore.collection('medicines').doc(medicineId).delete();
    } catch (e) {
      print('Error deleting medicine: $e');
    }
  }

  void _onFilterChanged(String? value) {
    setState(() {
      _filterValue = value ?? 'Select filter';
      switch (_filterValue) {
        case 'Expiry Date':
          _sortField = 'expiryDate';
          _ascending = false; // latest added at the top
          break;
        case 'Name':
          _sortField = 'name';
          _ascending = true;
          break;
        case 'Supplier':
          _sortField = 'supplier';
          _ascending = true;
          break;
        default:
          _sortField = 'addedDate'; //  sort by addedDate
          _ascending = false;
      }
      _updateStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Medicine Inventory",
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
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _updateStream(); // Refresh the data
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddMedicinePage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.4),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query.toLowerCase();
                    _updateStream(); // Refresh the stream when searching
                  });
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search Medicines',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Filter Options
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filter by:'),
                  DropdownButton<String>(
                    hint: Text('Select filter'),
                    value: _filterValue == 'Select filter' ? null : _filterValue,
                    items: [
                      DropdownMenuItem(value: 'Expiry Date', child: Text('Expiry Date')),
                      DropdownMenuItem(value: 'Name', child: Text('Name')),
                      DropdownMenuItem(value: 'Supplier', child: Text('Supplier')),
                    ],
                    onChanged: _onFilterChanged,
                  ),
                ],
              ),
            ),

            // Total Count and Statistics
            StreamBuilder<QuerySnapshot>(
              stream: _medicinesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final medicines = snapshot.data!.docs;
                final totalMedicines = medicines.length;
                final expiringSoon = medicines.where((doc) {
                  final expiryDate = DateTime.parse(doc['expiryDate']);
                  return expiryDate.isBefore(DateTime.now().add(Duration(days: 30)));
                }).length;

                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Medicines: $totalMedicines',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Expiring Soon: $expiringSoon',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // DataTable
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _medicinesStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final medicines = snapshot.data!.docs.where((doc) {
                      final name = doc['name'].toString().toLowerCase();
                      final supplier = doc['supplier'].toString().toLowerCase();
                      return name.contains(_searchQuery) || supplier.contains(_searchQuery);
                    }).toList();

                    return DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Quantity')),
                        DataColumn(label: Text('Expiry Date')),
                        DataColumn(label: Text('Supplier')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: medicines.map((doc) {
                        final id = doc.id;
                        final name = doc['name'];
                        final quantity = doc['quantity'];
                        final expiryDate = doc['expiryDate'];
                        final supplier = doc['supplier'];

                        return DataRow(cells: [
                          DataCell(Text(name)),
                          DataCell(Text(quantity)),
                          DataCell(Text(expiryDate)),
                          DataCell(Text(supplier)),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.info, color: Colors.blueAccent),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MedicineDetailPage(medicineId: id),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.orangeAccent),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditMedicinePage(medicineId: id),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () async {
                                  bool? confirm = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Confirm Delete'),
                                        content: Text('Are you sure you want to delete this item?'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Delete'),
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm ?? false) {
                                    _deleteMedicine(id);
                                  }
                                },
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
