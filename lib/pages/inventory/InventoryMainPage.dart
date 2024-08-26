import 'package:dairy_harbor/components/inventory_components/bar_chart_data.dart';
import 'package:dairy_harbor/pages/inventory/notification_page.dart';
import 'package:dairy_harbor/pages/inventory/user_profile.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';


class InventoryMainPage extends StatelessWidget {
  const InventoryMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0,
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
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfile(),
                  ));
            },
          ),
        ],
      ),
      // drawer: Drawer(
      //   backgroundColor: Colors.blue,
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: [
      //       DrawerHeader(
      //         child: Text(
      //           'Dairy \nFarm \nApp',
      //           style: TextStyle(
      //             color: Colors.black,
      //             fontSize: 24,
      //           ),
      //         ),
      //       ),
      //       // Home and Inventory ExpansionTile
      //       ExpansionTile(
      //         leading: Icon(Icons.inventory, color: Colors.black),
      //         title: Text('Inventory', style: TextStyle(color: Colors.white)),
      //         children: <Widget>[
      //           ListTile(
      //             leading: Icon(Icons.grain, color: Colors.black),
      //             title: Text('Feeds', style: TextStyle(color: Colors.white)),
      //             onTap: () {
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(builder: (context) => FeedsPage()),
      //               );
      //             },
      //           ),
      //           ListTile(
      //             leading: Icon(Icons.local_pharmacy, color: Colors.black),
      //             title: Text('Medicine', style: TextStyle(color: Colors.white)),
      //             onTap: () {
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(builder: (context) => MedicinePage()),
      //               );
      //             },
      //           ),
      //           ListTile(
      //             leading: Icon(Icons.build, color: Colors.black),
      //             title: Text('Farm Machinery', style: TextStyle(color: Colors.white)),
      //             onTap: () {
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(builder: (context) => FarmMachineryPage()),
      //               );
      //             },
      //           ),
      //         ],
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.admin_panel_settings, color: Colors.black),
      //         title: Text('Administrative', style: TextStyle(color: Colors.white)),
      //         onTap: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => AdministrativeWages()),
      //           );
      //         },
      //       ),
      //       // Add more ListTiles if needed
      //     ],
      //   ),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Header
              const SizedBox(height: 13),
              const Text(
                'Inventory Overview:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              // Cards for Detailed Statistics
              Container(
                height: 200,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatCard('Total Cows', '50', Icons.pets),
                      _buildStatCard(
                          'Milk Production', '300 Liters', Icons.local_drink),
                      _buildStatCard('Feed Stock', '200 Bags', Icons.food_bank),
                      _buildStatCard(
                          'Machinery Status', 'Operational', Icons.build),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Placeholder for Charts/Graphs
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.lightBlueAccent.withOpacity(0.8),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Milk Production Trends',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 38,
                                getTitlesWidget: getBottomTitles,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 38,
                                getTitlesWidget: getLeftTitles,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: const Color(0xff37434d),
                              width: 1,
                            ),
                          ),
                          barGroups:
                              showingGroups(), // Ensure this function is defined
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Additional content or widgets can be added here
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build a statistic card
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
