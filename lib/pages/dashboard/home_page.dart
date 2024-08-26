import 'package:dairy_harbor/components/widgets/my_app_bar.dart';
import 'package:dairy_harbor/components/widgets/side_bar.dart';
import 'package:dairy_harbor/services_functions/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class HomePage extends StatefulWidget {
  final FirestoreServices firestoreServices;
  final List<BarChartGroupData> barChartData;
  final List<PieChartSectionData> pieChartData;
  final List<LineChartBarData> lineChartData;
  final bool animate;
  final User? user;
  final String userId;

  HomePage({
    required this.barChartData,
    required this.pieChartData,
    required this.lineChartData,
    required this.animate,
    this.user, // Make user optional
    required this.firestoreServices,
    required this.userId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? businessName;

  @override
  void initState() {
    super.initState();
    if (widget.user != null && widget.userId.isNotEmpty) {
      _fetchBusinessName();
    } else {
      print("No user is currently logged in or user ID is empty.");
    }
  }

  Future<void> _fetchBusinessName() async {
    try {
      final name = await widget.firestoreServices.getBusinessName();
      setState(() {
        businessName = name ?? 'No Business Name';
      });
    } catch (e) {
      print("Error fetching business name: $e");
    }
  }

  void _onSelectPage(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNavbar(), // Use CustomNavbar here
      drawer: SidebarMenu(
        onSelectPage: _onSelectPage, // Pass the navigation callback
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildWelcomeCard(context),
            _buildStatsCards(context),
            _buildRevenueChart(context),
            _buildOrderStatsCard(context),
            _buildExpenseOverviewCard(context),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(
          context, '/login'); // Replace with your login page route
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 64, 196, 255),
      shape: RoundedRectangleBorder(
        side:
            const BorderSide(color: Color.fromARGB(255, 2, 95, 171), width: 1),
        borderRadius: BorderRadius.circular(4.0),
      ),
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Congratulations Munei! 🎉',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
                'Welcome to your dashboard, Check your new badge in your profile.'),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/manageCattle');
                    },
                    child: const Text('My Cattle'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/workerList');
                    },
                    child: const Text('My Workers'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/reports');
                    },
                    child: const Text('Reports'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/dailyProduction');
                    },
                    child: const Text('Record Milk Production'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Card(
            color: const Color.fromARGB(255, 64, 196, 255),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.blue, width: 1),
              borderRadius: const BorderRadius.all(Radius.circular(4.0)),
            ),
            margin: const EdgeInsets.all(8.0),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Total Monthly Production in Litres',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Total: 1000 Litres'),
                  Text('Increase: 10%'),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            color: const Color.fromARGB(255, 64, 196, 255),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.blue, width: 1),
              borderRadius: const BorderRadius.all(Radius.circular(4.0)),
            ),
            margin: const EdgeInsets.all(8.0),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Sales', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Total Sales: Kshs:5000'),
                  Text('Increase: 15%'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueChart(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 64, 196, 255),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.blue, width: 1),
        borderRadius: BorderRadius.circular(4.0),
      ),
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Total Revenue',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                        reservedSize: 20,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                        reservedSize: 43,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 0.0, top: 0),
                            child: Text(
                              '${value.toInt()}',
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 14),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: widget.barChartData.map((barGroup) {
                    return barGroup.copyWith(
                      barsSpace: 1, // Adjust space between bars
                      showingTooltipIndicators: [], // Show tooltip only on touch
                      barRods: barGroup.barRods.map((barRod) {
                        return barRod.copyWith(
                          toY: barRod.toY,
                          width: 55, // Adjust the width to make bars thicker
                          borderRadius:
                              BorderRadius.circular(7), // No rounded corners
                        );
                      }).toList(),
                    );
                  }).toList(),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipPadding: EdgeInsets.all(8),
                      //tooltipBgColor: Colors.blue, // Background color of tooltip
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toStringAsFixed(2)}',
                          TextStyle(color: Colors.white),
                        );
                      },
                    ),
                    touchCallback:
                        (FlTouchEvent event, BarTouchResponse? response) {
                      if (event is FlTapUpEvent && response != null) {
                        // Show tooltip on touch
                        final touchedBarIndex =
                            response.spot?.touchedBarGroupIndex ?? -1;
                        if (touchedBarIndex != -1) {
                          // Force a rebuild or update state if needed to show tooltip
                          setState(() {
                            // Update the state if needed
                          });
                        }
                      }
                    },
                    handleBuiltInTouches: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatsCard(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 64, 196, 255),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.blue, width: 1),
        borderRadius: BorderRadius.circular(4.0),
      ),
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Order Statistics',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('Total Orders: 50'),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: widget.pieChartData,
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


Widget _buildExpenseOverviewCard(BuildContext context) {
  final double chartWidth = 12 * 40.0;

  return Card(
    color: const Color.fromARGB(255, 64, 196, 255),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
    ),
    margin: const EdgeInsets.all(8.0),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0), // Increased padding
            child: const Text(
              'Expense Overview',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), // Increased font size
            ),
          ),
          SizedBox(
            height: 200,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: chartWidth, // Width to enable scrolling
                child: LineChart(
                  LineChartData(
                    lineBarsData: widget.lineChartData.map((lineBarData) {
                      return lineBarData.copyWith(
                        isCurved: true,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(show: false),
                        aboveBarData: BarAreaData(show: false),
                        barWidth: 5, 
                      );
                    }).toList(),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30, 
                          interval: 1, 
                          getTitlesWidget: (value, meta) {
                            final monthIndex = value.toInt();
                            final date = DateTime(2024, monthIndex + 1);
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                DateFormat('MMM').format(date),
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                '${value.toInt()}',
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false, // Hide top titles
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false, // Hide right titles
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: false, // Hide the border
                    ),
                    gridData: FlGridData(
                      show: false, // Hide the grid lines
                    ),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

}
