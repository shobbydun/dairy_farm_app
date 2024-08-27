import 'package:dairy_harbor/pages/inventory/notification_page.dart';
import 'package:dairy_harbor/pages/inventory/user_profile.dart';
import 'package:flutter/material.dart';
 

class FeedsPage extends StatelessWidget {
  const FeedsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Feeds",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            },
          ),
          CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfile()),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 20),

              // Container with Image Background and Text
              Container(
                padding: const EdgeInsets.all(160.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image:
                        AssetImage('assets/ttech.jpeg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Align(
                  alignment: Alignment.center,
              
                ),
              ),

              SizedBox(height: 26),

              Text(
                'Feed Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.lightBlueAccent,
                    width: 2, 
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Feed Name')),
                      DataColumn(label: Text('Supplier')),
                      DataColumn(label: Text('Quantity')),
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(Text('2024-08-01')),
                        DataCell(Text('Corn Silage')),
                        DataCell(Text('ABC Feeds')),
                        DataCell(Text('100 kg')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('2024-08-02')),
                        DataCell(Text('Alfalfa Hay')),
                        DataCell(Text('XYZ Supplies')),
                        DataCell(Text('80 kg')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('2024-08-03')),
                        DataCell(Text('Soybean Meal')),
                        DataCell(Text('Farmers Union')),
                        DataCell(Text('60 kg')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('2024-08-04')),
                        DataCell(Text('Oat Grain')),
                        DataCell(Text('Green Valley')),
                        DataCell(Text('120 kg')),
                      ]),
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

  // Helper method search bar
  Widget _buildSearchBar() {
    return Container(
      width: double.infinity,
      height: 50, 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.lightBlueAccent.withOpacity(0.8),
            blurRadius: 8,
            offset: Offset(0, 4), 
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search', 
          prefixIcon: Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }
}
