import 'package:dairy_harbor/components/inventory_components/bar_chart_data.dart';
import 'package:dairy_harbor/components/widgets/line_chart.dart';
import 'package:dairy_harbor/services_functions/data_service.dart';
import 'package:flutter/material.dart';

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final DataService _dataService = DataService();

  List<Map<String, dynamic>> fetchedData = [];
  List<Map<String, dynamic>> cowSalesData = [];
  int cattleCount = 0;
  int workersCount = 0;
  int calvesCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    // Fetch data concurrently
    Future.wait([
      _dataService.fetchMilkSalesData().then((data) {
        setState(() {
          fetchedData = data;
        });
      }),
      _dataService.fetchCowSalesData().then((data) {
        setState(() {
          cowSalesData = data;
        });
      }),
      _dataService.fetchCattleCount().then((count) {
        setState(() {
          cattleCount = count;
        });
      }),
      _dataService.fetchWorkersCount().then((count) {
        setState(() {
          workersCount = count;
        });
      }),
      _dataService.fetchCalvesCount().then((count) {
        setState(() {
          calvesCount = count;
        });
      }),
    ]).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildFarmStats(
              cattleCount: cattleCount,
              workersCount: workersCount,
              calvesCount: calvesCount,
            ),
            _buildOrderStatsCard(context),
            _buildSummaryCardsSection(context),
            _buildCattleStatusWidget(context),
            _buildWeekExpenseOverviewCard(context),
            const SizedBox(height: 20),
            _buildCowSalesCard(context),
            //_buildScatterPlot(),
            const SizedBox(height: 20),
            //_buildHeatmap(),
          ],
        ),
      ),
    );
  }

  Widget _buildCattleStatusWidget(BuildContext context) {
    final List<Map<String, dynamic>> cattleData = [
      {
        'serial_number': '001',
        'status': 'milking',
        'weight': 450.0,
        'lactation_stage': 'early'
      },
      {
        'serial_number': '002',
        'status': 'pregnant',
        'weight': 550.0,
        'lactation_stage': 'none'
      },
      {
        'serial_number': '003',
        'status': 'dry',
        'weight': 500.0,
        'lactation_stage': 'none'
      },
      {
        'serial_number': '004',
        'status': 'sick',
        'weight': 420.0,
        'lactation_stage': 'early'
      },
      {
        'serial_number': '005',
        'status': 'heifer',
        'weight': 300.0,
        'lactation_stage': 'none'
      },
      {
        'serial_number': '006',
        'status': 'bull',
        'weight': 700.0,
        'lactation_stage': 'none'
      },
      {
        'serial_number': '007',
        'status': 'healthy calf',
        'weight': 200.0,
        'lactation_stage': 'none'
      },
      {
        'serial_number': '008',
        'status': 'milking',
        'weight': 450.0,
        'lactation_stage': 'early'
      },
      {
        'serial_number': '009',
        'status': 'pregnant',
        'weight': 550.0,
        'lactation_stage': 'none'
      },
      {
        'serial_number': '010',
        'status': 'dry',
        'weight': 500.0,
        'lactation_stage': 'none'
      },
      {
        'serial_number': '011',
        'status': 'sick',
        'weight': 420.0,
        'lactation_stage': 'early'
      },
      {
        'serial_number': '012',
        'status': 'heifer',
        'weight': 300.0,
        'lactation_stage': 'none'
      },
      {
        'serial_number': '013',
        'status': 'bull',
        'weight': 700.0,
        'lactation_stage': 'none'
      },
      {
        'serial_number': '014',
        'status': 'healthy calf',
        'weight': 200.0,
        'lactation_stage': 'none'
      },
    ];

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage(
                'assets/abstract-light-blue-wide-background-with-radial-blue-gradients-vector.jpg'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cattle Status',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity, // Full width for horizontal scroll
                height: 300, // Limit the height to trigger vertical scrolling
                child: SingleChildScrollView(
                  scrollDirection:
                      Axis.horizontal, // Horizontal scrolling for the table
                  child: SizedBox(
                    width: 800, // Adjust this width based on your table needs
                    child: SingleChildScrollView(
                      scrollDirection:
                          Axis.vertical, // Vertical scrolling for rows
                      child: DataTable(
                        columns: const [
                          DataColumn(
                              label: Text('Serial No.',
                                  style: TextStyle(color: Colors.black))),
                          DataColumn(
                              label: Text('Status',
                                  style: TextStyle(color: Colors.black))),
                          DataColumn(
                              label: Text('Weight (kg)',
                                  style: TextStyle(color: Colors.black))),
                          DataColumn(
                              label: Text('Lactation Stage',
                                  style: TextStyle(color: Colors.black))),
                        ],
                        rows: cattleData
                            .map((cattle) => DataRow(
                                  cells: [
                                    DataCell(Text(cattle['serial_number'],
                                        style: const TextStyle(
                                            color: Colors.black))),
                                    DataCell(Text(cattle['status'],
                                        style: const TextStyle(
                                            color: Colors.black))),
                                    DataCell(Text(cattle['weight'].toString(),
                                        style: const TextStyle(
                                            color: Colors.black))),
                                    DataCell(Text(cattle['lactation_stage'],
                                        style: const TextStyle(
                                            color: Colors.black))),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Farm stats section
  Widget _buildFarmStats(
      {required int cattleCount,
      required int workersCount,
      required int calvesCount}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSummaryCard(
          title: 'Cattle ',
          value: '$cattleCount',
          icon: Icons.pets,
          color: Colors.green,
        ),
        _buildSummaryCard(
          title: 'Employees',
          value: '$workersCount',
          icon: Icons.people,
          color: Colors.blue,
        ),
        _buildSummaryCard(
          title: 'Calves ',
          value: '$calvesCount',
          icon: Icons.cake,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      {required String title,
      required String value,
      required IconData icon,
      required Color color}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      shadowColor: color.withOpacity(0.5),
      child: Container(
        width: 125,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              Icon(
                icon,
                size: 30,
                color: Colors.white,
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Section for additional summary cards
  Widget _buildSummaryCardsSection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSummaryCard(
              title: 'Monthly Revenue',
              value: '\Kshs34,890',
              icon: Icons.attach_money,
              color: Colors.purple,
            ),
            _buildSummaryCard(
              title: 'Expenses',
              value: '\Kshs15,230',
              icon: Icons.money_off,
              color: Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  // Order stats card
  Widget _buildOrderStatsCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage(
                'assets/abstract-light-blue-wide-background-with-radial-blue-gradients-vector.jpg'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Milk Sales',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              LineChartSample2(
                fetchedData: fetchedData,
                collectionName: 'milk_sales',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekExpenseOverviewCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Match the rounded corners
      ),
      margin: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage(
              'assets/abstract-light-blue-wide-background-with-radial-blue-gradients-vector.jpg',
            ),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Weekly Feed Expenses',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Set text color for better contrast
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              BarChartSample2(), // Assuming this widget already handles its internal layout and styling
            ],
          ),
        ),
      ),
    );
  }

  // Expense overview card
  Widget _buildCowSalesCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage(
                'assets/abstract-light-blue-wide-background-with-radial-blue-gradients-vector.jpg'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Cow Sales',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              LineChartSample2(
                fetchedData: cowSalesData,
                collectionName: 'cow_sales',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // // Placeholder for scatter plot
  // Widget _buildScatterPlot() {
  //   return Container(
  //     height: 300,
  //     color: Colors.grey[200],
  //     child: const Center(child: Text("Scatter Plot Placeholder")),
  //   );
  // }

  // // Placeholder for heatmap
  // Widget _buildHeatmap() {
  //   return Container(
  //     height: 300,
  //     color: Colors.grey[200],
  //     child: const Center(child: Text("Heatmap Placeholder")),
  //   );
  // }

  // Reusable summary card widget
//   Widget _buildSummaryCard({required String title, required String value, required IconData icon, required Color color}) {
//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Icon(icon, color: color, size: 36),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             Text(
//               value,
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
}
