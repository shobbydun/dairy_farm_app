import 'package:dairy_harbor/services_functions/firestore_services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'farm_machinery_page.dart';
import 'feeds_page.dart';

class InventoryMainPage extends StatelessWidget {
  const InventoryMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return ChangeNotifierProvider<FirestoreServices>(
      create: (context) => FirestoreServices(userId),
      child: Consumer<FirestoreServices>(
        builder: (context, firestoreService, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.lightBlueAccent,
              elevation: 0,
            ),
            body: FutureBuilder<Map<String, dynamic>>(
              future: Future.wait([
                firestoreService.getProfile(),
                firestoreService.getFeeds(),
                firestoreService.getMachinery(),
              ]).then((results) {
                return {
                  'profile': results[0],
                  'feeds': results[1],
                  'machinery': results[2],
                };
              }),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!;
                final profile = data['profile'];
                final feeds = data['feeds'];
                final machinery = data['machinery'];

                final totalCows = profile?['numberOfCows'] ?? 'N/A';
                final milkProduction = profile?['dailyMilkProduction'] ?? 'N/A';
                final feedStock = feeds.length.toString();
                final machineryStatus = machinery.isEmpty ? 'N/A' : 'Operational';

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 13),
                        const Text(
                          'Inventory Overview:',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          height: 200,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildStatCard(
                                  'Total Cows',
                                  totalCows,
                                  Icons.pets,
                                  () {
                                    Navigator.pushNamed(context, '/cattleListPage');
                                  },
                                ),
                                _buildStatCard(
                                  'Milk Production',
                                  '$milkProduction Liters',
                                  Icons.local_drink,
                                  () {
                                    Navigator.pushNamed(context, '/milkSales');
                                  },
                                ),
                                _buildStatCard(
                                  'Feed Stock',
                                  '$feedStock Bags',
                                  Icons.food_bank,
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FeedsPage(),
                                      ),
                                    );
                                  },
                                ),
                                _buildStatCard(
                                  'Machinery Status',
                                  machineryStatus,
                                  Icons.build,
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FarmMachineryPage(),
                                      ),
                                    );
                                  },
                                ),
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
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
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
                                      show: false,
                                    ),
                                    barGroups: showingGroups(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        // Navigation buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildNavigationButton(
                              'Feeds Overview',
                              Icons.food_bank,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FeedsPage(),
                                  ),
                                );
                              },
                            ),
                            _buildNavigationButton(
                              'Machinery Overview',
                              Icons.build,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FarmMachineryPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Helper method to build a statistic card with navigation
  Widget _buildStatCard(
      String title, String value, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
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
      ),
    );
  }

  // Helper method to build a navigation button
  Widget _buildNavigationButton(
      String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // Dummy functions for chart titles
  Widget getBottomTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(value.toInt().toString(), style: TextStyle(fontSize: 12)),
    );
  }

  Widget getLeftTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(value.toInt().toString(), style: TextStyle(fontSize: 12)),
    );
  }

  List<BarChartGroupData> showingGroups() {
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
              toY: 6,
              color: Colors.red,
              width: 30,
              borderRadius: BorderRadius.circular(5)),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
              toY: 12,
              color: Colors.redAccent,
              width: 30,
              borderRadius: BorderRadius.circular(5)),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
              toY: 18,
              color: Colors.orange,
              width: 30,
              borderRadius: BorderRadius.circular(5)),
        ],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(
              toY: 24,
              color: Colors.green,
              width: 30,
              borderRadius: BorderRadius.circular(5)),
        ],
      ),
    ];
  }
}
