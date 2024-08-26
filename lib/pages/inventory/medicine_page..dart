import 'package:dairy_harbor/components/inventory_components/add_medicine_page.dart';
import 'package:dairy_harbor/components/inventory_components/edit_medicine_page.dart';
import 'package:dairy_harbor/components/inventory_components/medicine_detail_page.dart';
import 'package:flutter/material.dart';
 // Add the import

class MedicinePage extends StatelessWidget {
  const MedicinePage({super.key});

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
              // Handle refresh action
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
                    items: [
                      DropdownMenuItem(value: 'Expiry Date', child: Text('Expiry Date')),
                      DropdownMenuItem(value: 'Supplier', child: Text('Supplier')),
                      DropdownMenuItem(value: 'Quantity', child: Text('Quantity')),
                    ],
                    onChanged: (value) {
                      // Handle filter change
                    },
                  ),
                ],
              ),
            ),

            // Total Count and Statistics
            Container(
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
                    'Total Medicines: 5', // Update count
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Expiring Soon: 2', // Example value
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Medicine List Table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Expiry Date')),
                    DataColumn(label: Text('Supplier')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text('Penicillin')),
                      DataCell(Text('50 vials')),
                      DataCell(Text('2025-12-01')),
                      DataCell(Text('Pharma Inc.')),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.info, color: Colors.blueAccent),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MedicineDetailPage(medicineId: 'penicillin-id')),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orangeAccent),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditMedicinePage(medicineId: 'penicillin-id')),
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
                                // Handle delete action
                              }
                            },
                          ),
                        ],
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Amoxicillin')),
                      DataCell(Text('30 vials')),
                      DataCell(Text('2024-10-15')),
                      DataCell(Text('HealthCare Ltd.')),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.info, color: Colors.blueAccent),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MedicineDetailPage(medicineId: 'amoxicillin-id')),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orangeAccent),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditMedicinePage(medicineId: 'amoxicillin-id')),
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
                                // Handle delete action
                              }
                            },
                          ),
                        ],
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Ibuprofen')),
                      DataCell(Text('40 tablets')),
                      DataCell(Text('2024-08-20')),
                      DataCell(Text('Medicines Co.')),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.info, color: Colors.blueAccent),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MedicineDetailPage(medicineId: 'ibuprofen-id')),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orangeAccent),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditMedicinePage(medicineId: 'ibuprofen-id')),
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
                                // Handle delete action
                              }
                            },
                          ),
                        ],
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Cetirizine')),
                      DataCell(Text('60 tablets')),
                      DataCell(Text('2024-12-05')),
                      DataCell(Text('Allergy Inc.')),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.info, color: Colors.blueAccent),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MedicineDetailPage(medicineId: 'cetirizine-id')),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orangeAccent),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditMedicinePage(medicineId: 'cetirizine-id')),
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
                                // Handle delete action
                              }
                            },
                          ),
                        ],
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Metformin')),
                      DataCell(Text('90 tablets')),
                      DataCell(Text('2025-06-30')),
                      DataCell(Text('Diabetes Ltd.')),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.info, color: Colors.blueAccent),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MedicineDetailPage(medicineId: 'metformin-id')),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orangeAccent),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditMedicinePage(medicineId: 'metformin-id')),
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
                                // Handle delete action
                              }
                            },
                          ),
                        ],
                      )),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
