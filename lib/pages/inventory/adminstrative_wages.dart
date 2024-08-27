import 'package:dairy_harbor/components/inventory_components/add_wage_page.dart';
import 'package:dairy_harbor/components/inventory_components/edit_wage_page.dart';
import 'package:dairy_harbor/services_functions/delete_wage_page.dart';
import 'package:flutter/material.dart';

class AdministrativeWages extends StatelessWidget {
  const AdministrativeWages({super.key});

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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddWagePage()),
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
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search Administrative Wages',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
                ),
              ),
            ),
            const SizedBox(height: 20),

          
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filter by:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    hint: Text('Select filter'),
                    items: [
                      DropdownMenuItem(value: 'Date', child: Text('Date')),
                      DropdownMenuItem(value: 'Employee', child: Text('Employee')),
                      DropdownMenuItem(value: 'Department', child: Text('Department')),
                    ],
                    onChanged: (value) {
            
                    },
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

        
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Total Wages: Kshs 43,500',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),

            // Administrative Wages Table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16.0,
                  headingRowHeight: 56.0,
                  dataRowHeight: 60.0,
                  columns: const [
                    DataColumn(label: Text('Employee Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Department', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Wage', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: [
                    _buildDataRow(context, 'John Doe', 'Finance', '2024-08-01', 'Kshs 21,500'),
                    _buildDataRow(context, 'Jane Smith', 'Security', '2024-08-01', 'Kshs 22,000'),
                    _buildDataRow(context, 'Alice Johnson', 'Maintenance', '2024-08-05', 'Kshs 25,000'),
                    _buildDataRow(context, 'Bob Brown', 'IT', '2024-08-10', 'Kshs 28,000'),
                    _buildDataRow(context, 'Carol White', 'Admin', '2024-08-15', 'Kshs 30,000'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, String name, String department, String date, String wage) {
    return DataRow(
      cells: [
        DataCell(Text(name)),
        DataCell(Text(department)),
        DataCell(Text(date)),
        DataCell(Text(wage)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blueAccent),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditWagePage(
                        employeeName: name,
                        department: department,
                        date: date,
                        wage: wage,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () {
                  showDeleteWageDialog(context, () {
                
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Wage record deleted')),
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
