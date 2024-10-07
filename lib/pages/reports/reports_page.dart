import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dairy_harbor/components/widgets/line_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReportsPage extends StatefulWidget {
  final Future<String?> adminEmailFuture;

  ReportsPage({super.key, required this.adminEmailFuture});

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  List<Map<String, dynamic>> fetchedData = [];
  List<Map<String, dynamic>> cowSalesData = [];
  int cattleCount = 0;
  int workersCount = 0;
  int calvesCount = 0;
  List<FlSpot> chartData = [];
  double totalSales = 0.0;
  double totalMilkDistributed = 0.0;
  List<double> dailyExpenses = List<double>.filled(7, 0.0);
  bool isLoading = true;
  double _monthlyRevenue = 0.0;
  double _monthlyExpenses = 0.0;

  String? _adminEmail;

  @override
  void initState() {
    super.initState();
    _fetchAdminEmail();
  }

  Future<void> _fetchAdminEmail() async {
    _adminEmail = await widget.adminEmailFuture;
    setState(() {}); // Update state after fetching admin email
    await _fetchSummaryData();
    await _loadData();
    await _fetchData();
  }

  Future<void> _fetchSummaryData() async {
    try {
      _monthlyRevenue = await getMonthlyRevenue();
      _monthlyExpenses = await getMonthlyExpenses();

      if (mounted) {
        setState(() {
          // Update any relevant UI elements
        });
      }

      print('Monthly Revenue: $_monthlyRevenue');
      print('Monthly Expenses: $_monthlyExpenses');
    } catch (e) {
      print('Error fetching summary data: $e');
    }
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch milk sales data
      final milkSalesSnapshot = await FirebaseFirestore.instance
          .collection('milk_sales')
          .doc(_adminEmail)
          .collection('entries')
          .get();

      final fetchedData =
          milkSalesSnapshot.docs.map((doc) => doc.data()).toList();

      // Fetch cow sales data
      final cowSalesSnapshot = await FirebaseFirestore.instance
          .collection('cow_sales')
          .doc(_adminEmail)
          .collection('entries')
          .get();

      final cowSalesData =
          cowSalesSnapshot.docs.map((doc) => doc.data()).toList();

      // Fetch cattle count
      final cattleSnapshot = await FirebaseFirestore.instance
          .collection('cattle')
          .doc(_adminEmail)
          .collection('entries')
          .get();

      final cattleCount = cattleSnapshot.docs.length;

      // Fetch workers count
      final workersSnapshot = await FirebaseFirestore.instance
          .collection('workers')
          .doc(_adminEmail)
          .collection('entries')
          .get();

      final workersCount = workersSnapshot.docs.length;

      // Fetch calves count
      final calvesSnapshot = await FirebaseFirestore.instance
          .collection('calves')
          .doc(_adminEmail)
          .collection('entries')
          .get();

      final calvesCount = calvesSnapshot.docs.length;

      if (mounted) {
        setState(() {
          this.fetchedData = fetchedData;
          this.cowSalesData = cowSalesData;
          this.cattleCount = cattleCount;
          this.workersCount = workersCount;
          this.calvesCount = calvesCount;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      if (mounted) {
        setState(() {
          this.fetchedData = [];
          this.cowSalesData = [];
          this.cattleCount = 0;
          this.workersCount = 0;
          this.calvesCount = 0;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && _adminEmail != null) {
      try {
        print('Fetching data for admin email: $_adminEmail');

        // Call _loadData to fetch the necessary data
        await _loadData();

        QuerySnapshot entriesSnapshot = await FirebaseFirestore.instance
            .collection('milk_production')
            .doc(_adminEmail)
            .collection('entries')
            .get();

        double sales = 0.0;
        double milkDistributed = 0.0;
        Map<int, double> salesPerDay = {};

        for (var doc in entriesSnapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          DateTime date = (data['date'] as Timestamp).toDate();
          int dayOfWeek = date.weekday; // 1 (Monday) to 7 (Sunday)
          double milkInLitres =
              double.tryParse(data['final_in_litres'].toString()) ?? 0;
          double pricePerLitre =
              double.tryParse(data['price_per_litre'].toString()) ?? 0;

          double totalSale = milkInLitres * pricePerLitre;

          // Accumulate sales for each day of the week
          if (totalSale > 0) {
            salesPerDay[dayOfWeek] = (salesPerDay[dayOfWeek] ?? 0) + totalSale;
          }

          sales += totalSale;
          milkDistributed += milkInLitres;
        }

        // Convert the accumulated sales into FlSpot list
        List<FlSpot> spots = [];
        for (int i = 1; i <= 7; i++) {
          spots.add(FlSpot(i.toDouble(), salesPerDay[i] ?? 0));
        }

        if (mounted) {
          setState(() {
            totalSales = sales;
            totalMilkDistributed = milkDistributed;
            chartData = spots.isNotEmpty ? spots : [FlSpot(0, 0)];
          });
        }

        print(
            'Total Sales: $totalSales, Total Milk Distributed: $totalMilkDistributed');
        await _fetchWeeklyExpenses(); // Fetch weekly expenses after data fetch
      } catch (e) {
        print('Error fetching data: $e');
      }
    } else {
      print('User is not authenticated or admin email is null.');
    }
  }

  Future<void> _fetchWeeklyExpenses() async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(Duration(days: 6));

      print('Start of Week: ${startOfWeek.toIso8601String()}');
      print('End of Week: ${endOfWeek.toIso8601String()}');

      if (_adminEmail != null) {
        print('Admin Email: $_adminEmail');

        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('feeds')
            .doc(_adminEmail)
            .collection('entries')
            .get();

        // Reset daily expenses before processing
        List<double> dailyExpenses = List<double>.filled(7, 0.0);

        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;

          // Handle different types for date
          DateTime date;
          if (data['date'] is Timestamp) {
            date = (data['date'] as Timestamp).toDate();
          } else if (data['date'] is String) {
            date = DateTime.parse(data['date']);
          } else {
            print('Unexpected date format for document ID: ${doc.id}');
            continue; // Skip this document if date format is unexpected
          }

          double cost = data['cost'] ?? 0.0;

          int dayIndex = date.weekday - 1; // 0 = Monday, 6 = Sunday
          dailyExpenses[dayIndex] += cost;

          print('Document ID: ${doc.id}, Date: $date, Cost: $cost');
        }

        print('Fetched ${snapshot.docs.length} expenses.');
        print('Daily Expenses: $dailyExpenses');

        // Update state with the calculated daily expenses and chart data
        setState(() {
          this.dailyExpenses = dailyExpenses; // Store the expenses
          chartData = List<FlSpot>.generate(
              7, (index) => FlSpot(index.toDouble(), dailyExpenses[index]));
        });
      } else {
        print('Admin email is null, cannot fetch expenses.');
      }
    } catch (e) {
      print('Error fetching weekly expenses: $e');
    }
  }

  Future<double> getMonthlyRevenue() async {
    if (_adminEmail != null) {
      try {
        List<Map<String, dynamic>> milkEntries = await _fetchMilkEntries();
        double totalRevenue = 0.0;

        for (var entry in milkEntries) {
          double finalMilkInLitres = entry['final_in_litres'] ?? 0.0;
          double pricePerLitre = entry['price_per_litre'] ?? 0.0;
          totalRevenue += finalMilkInLitres * pricePerLitre;
        }

        return totalRevenue;
      } catch (e) {
        print('Error fetching monthly revenue: $e');
        return 0.0;
      }
    }
    return 0.0;
  }

  Future<double> getMonthlyExpenses() async {
    double totalFeedCost = 0.0;
    double totalWages = 0.0;

    try {
      List<Map<String, dynamic>> feeds = await getFeeds();
      for (var feed in feeds) {
        totalFeedCost += feed['cost'] ?? 0.0;
      }

      List<Map<String, dynamic>> wages = await getWages();
      for (var wage in wages) {
        totalWages += double.tryParse(wage['wage'].toString()) ?? 0.0;
      }
    } catch (e) {
      print('Error fetching monthly expenses: $e');
    }

    return totalFeedCost + totalWages;
  }

  Future<List<Map<String, dynamic>>> _fetchMilkEntries() async {
    if (_adminEmail != null) {
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('milk_production')
            .doc(_adminEmail)
            .collection('entries')
            .where('date',
                isGreaterThanOrEqualTo:
                    DateTime(DateTime.now().year, DateTime.now().month, 1))
            .get();

        return snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return {
            'final_in_litres': data['final_in_litres'] ?? 0.0,
            'price_per_litre': data['price_per_litre'] ?? 0.0,
          };
        }).toList();
      } catch (e) {
        print('Error fetching milk entries: $e');
        return [];
      }
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getFeeds() async {
    if (_adminEmail != null) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('feeds')
            .doc(_adminEmail)
            .collection('entries')
            .get();

        return querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          // If date is a String, convert it to Timestamp
          if (data['date'] is String) {
            data['date'] = Timestamp.fromDate(DateTime.parse(data['date']));
          }

          // Convert Timestamp to String for display
          if (data['date'] is Timestamp) {
            data['date'] = (data['date'] as Timestamp)
                .toDate()
                .toIso8601String()
                .split('T')[0]; // Format to 'yyyy-MM-dd'
          }

          return {'id': doc.id, ...data};
        }).toList();
      } catch (e) {
        print('Error fetching feeds: $e');
        rethrow;
      }
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getWages() async {
    if (_adminEmail != null) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('wages')
            .doc(_adminEmail)
            .collection('entries')
            .get();

        return querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {'id': doc.id, ...data};
        }).toList();
      } catch (e) {
        print('Error fetching wages: $e');
        rethrow;
      }
    }
    return [];
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
              value: 'Kshs ${_monthlyRevenue.toStringAsFixed(2)}',
              icon: Icons.attach_money,
              color: Colors.purple,
            ),
            _buildSummaryCard(
              title: 'Expenses',
              value: 'Kshs ${_monthlyExpenses.toStringAsFixed(2)}',
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
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/milkSales');
      },
      child: Card(
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
                  'Milk Sales for this week',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  height: 300.0,
                  child: chartData.isNotEmpty
                      ? LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    int index = value.toInt();
                                    if (index >= 1 && index <= 7) {
                                      return Text([
                                        'Mon',
                                        'Tue',
                                        'Wed',
                                        'Thu',
                                        'Fri',
                                        'Sat',
                                        'Sun'
                                      ][index - 1]);
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  getTitlesWidget: (value, meta) {
                                    return Text(value.toInt().toString());
                                  },
                                ),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: chartData,
                                isCurved: true,
                                color: Colors.green,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                            minX: 1,
                            maxX: 7,
                            minY: 0,
                            maxY: chartData.isNotEmpty
                                ? chartData
                                        .map((spot) => spot.y)
                                        .reduce((a, b) => a > b ? a : b) *
                                    1.2
                                : 1, // Default value if chartData is empty
                          ),
                        )
                      : Center(child: Text('No data available')),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Tap for more details',
                  style: TextStyle(
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekExpenseOverviewCard(BuildContext context) {
    // Determine the highest expense to set color thresholds
    double maxExpense = dailyExpenses.reduce((a, b) => a > b ? a : b);
    Color getColor(double value) {
      if (value > maxExpense * 0.75) {
        return Colors.green; // High
      } else if (value > maxExpense * 0.25) {
        return Colors.yellow; // Medium
      } else {
        return Colors.red; // Low
      }
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
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
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 200, // Set the height for the chart
                child: BarChart(
                  BarChartData(
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 20,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              [
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                                'Sun'
                              ][value.toInt()],
                              style: const TextStyle(color: Colors.black),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(
                      7,
                      (index) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: dailyExpenses[index],
                            color: getColor(dailyExpenses[index]),
                            width: 32,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      ),
                    ),
                    gridData: FlGridData(show: false),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/feeds');
                },
                child: const Text(
                  'Tap for more details',
                  style: TextStyle(
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                  ),
                ),
              ),
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
