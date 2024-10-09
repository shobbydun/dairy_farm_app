import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dairy_harbor/components/widgets/line_chart.dart';
import 'package:dairy_harbor/components/widgets/my_app_bar.dart';
import 'package:dairy_harbor/components/widgets/my_card.dart';
import 'package:dairy_harbor/components/widgets/side_bar.dart';
import 'package:dairy_harbor/services_functions/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage extends StatefulWidget {
  final FirestoreServices firestoreServices;
  final bool animate;
  final User? user;
  final String userId;
  final Future<String?> adminEmailFuture;

  HomePage({
    super.key,
    required this.animate,
    this.user,
    required this.firestoreServices,
    required this.userId,
    required this.adminEmailFuture,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? farmName;
  String? _adminEmail;

  final _controller = PageController();

  // final DataService _dataService = DataService();

  List<Map<String, dynamic>> fetchedData = [];
  int _cattleCount = 0;
  int _workersCount = 0;
  int _calvesCount = 0;
  double totalSales = 0.0;
  double totalMilkDistributed = 0.0;
  bool isLoading = true;
  List<FlSpot> chartData = [];
  List<double> dailyExpenses = List<double>.filled(7, 0.0);
  double chartMaxY = 0.0;
  double _monthlyRevenue = 0.0;
  double _cowSales = 0.0;
  double _feedCost = 0.0;
  double _salaryCost = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    if (widget.user != null && widget.userId.isNotEmpty) {
      await _fetchFarmName(); // Fetch farm name first
      await _fetchAdminEmail(); // Then fetch admin email
    } else {
      print("No user is currently logged in or user ID is empty.");
      setState(() {
        isLoading = false; // Update loading state
      });
    }
  }

  Future<void> _fetchAdminEmail() async {
    try {
      // Fetch admin email
      _adminEmail = await widget.adminEmailFuture;
      print('Admin Email: $_adminEmail');

      // Only proceed if admin email is successfully fetched
      if (_adminEmail != null) {
        await _fetchCounts();
        await _fetchData();
        await _fetchWeeklyExpenses();
        await _fetchSummaryData();
        await _loadData();
      } else {
        print('Admin email is null, skipping data fetches.');
      }
    } catch (e) {
      print('Error fetching admin email: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // Ensure loading state is updated
        });
      }
    }
  }

  Future<void> _loadData() async {
  setState(() {
    isLoading = true;
  });

  try {
    // Fetch milk sales data
    final milkSalesSnapshot = await FirebaseFirestore.instance
        .collection('milk_production')
        .doc(_adminEmail)
        .collection('entries')
        .get();

    final fetchedData = milkSalesSnapshot.docs.map((doc) => doc.data()).toList();

    
    if (mounted) {
      setState(() {
        this.fetchedData = fetchedData;
        
      });
    }
  } catch (e) {
    print('Error fetching data: $e');
    if (mounted) {
      setState(() {
        this.fetchedData = [];
        
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


  Future<void> _fetchFarmName() async {
    try {
      final name = await widget.firestoreServices.getFarmName();
      setState(() {
        farmName = name ?? '';
      });
    } catch (e) {
      print("Error fetching farm name: $e");
    }
  }

  Future<void> _fetchSummaryData() async {
    try {
      _monthlyRevenue = await getMonthlyRevenue();
      _feedCost = await getMonthlyExpenses(); // Adjust to only get feed cost

      // Fetch wages separately and sum them up
      List<Map<String, dynamic>> wages = await getWages();
      _salaryCost = wages.fold(
          0.0,
          (sum, wage) =>
              sum + (double.tryParse(wage['wage']?.toString() ?? '0') ?? 0.0));

      _cowSales = await getMonthlyCowSales(); // Fetch cow sales

      if (mounted) {
        setState(() {
          // Update any relevant UI elements
        });
      }

      print('Monthly Revenue: $_monthlyRevenue');
      print('Feed Cost: $_feedCost');
      print('Salary Cost: $_salaryCost');
      print('Cow Sales: $_cowSales');
    } catch (e) {
      print('Error fetching summary data: $e');
    }
  }

  Future<double> getMonthlyCowSales() async {
    if (_adminEmail != null) {
      try {
        // Fetch cow sales data
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('cow_sales')
            .doc(_adminEmail)
            .collection('entries')
            .where('date',
                isGreaterThanOrEqualTo:
                    DateTime(DateTime.now().year, DateTime.now().month, 1))
            .get();

        double totalCowSales = 0.0;

        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>?; // Safe cast to Map
          if (data != null) {
            totalCowSales += data['amount'] ?? 0.0; // Safely access 'amount'
          }
        }

        return totalCowSales;
      } catch (e) {
        print('Error fetching monthly cow sales: $e');
        return 0.0;
      }
    }
    return 0.0;
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
        totalFeedCost +=
            feed['cost'] ?? 0.0; // Ensure 'cost' is accessed safely
      }

      List<Map<String, dynamic>> wages = await getWages();
      for (var wage in wages) {
        // Check if wage is not null
        totalWages += double.tryParse(wage['wage']?.toString() ?? '0') ??
            0.0; // Safe access
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
        return [];
      }
    }
    return [];
  }

  Future<void> _fetchData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && _adminEmail != null) {
      try {
        print('Fetching data for admin email: $_adminEmail');
        QuerySnapshot entriesSnapshot = await FirebaseFirestore.instance
            .collection('milk_production')
            .doc(_adminEmail)
            .collection('entries')
            .get();

        print('Fetched ${entriesSnapshot.docs.length} entries.');

        double sales = 0.0;
        double milkDistributed = 0.0;
        List<FlSpot> spots = [];

        for (var doc in entriesSnapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          DateTime date = (data['date'] as Timestamp).toDate();
          int dayOfWeek = date.weekday; // 1 (Monday) to 7 (Sunday)
          double milkInLitres =
              double.tryParse(data['final_in_litres'].toString()) ?? 0;
          double pricePerLitre =
              double.tryParse(data['price_per_litre'].toString()) ?? 0;

          double totalSale = milkInLitres * pricePerLitre;

          if (totalSale > 0) {
            spots.add(FlSpot(dayOfWeek.toDouble(), totalSale));
          }

          sales += totalSale;
          milkDistributed += milkInLitres;
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
      } catch (e) {
        print('Error fetching data: $e');
      }
    } else {
      print('User is not authenticated or admin email is null.');
    }
  }

  void _onSelectPage(String route) {
    Navigator.pushNamed(context, route);
  }

  Future<void> _fetchCounts() async {
    if (_adminEmail == null) {
      if (mounted) {
        setState(() {
          _cattleCount = 0;
          _workersCount = 0;
          _calvesCount = 0;
        });
      }
      return;
    }

    try {
      // Count cattle
      final cattleSnapshot = await FirebaseFirestore.instance
          .collection('cattle')
          .doc(_adminEmail)
          .collection('entries')
          .get();

      print('Cattle entries fetched: ${cattleSnapshot.docs.length}');
      final cattleCount = cattleSnapshot.docs.length;

      // Count workers
      final workersSnapshot = await FirebaseFirestore.instance
          .collection('workers')
          .doc(_adminEmail)
          .collection('entries')
          .get();

      print('Workers entries fetched: ${workersSnapshot.docs.length}');
      final workersCount = workersSnapshot.docs.length;

      // Count calves
      final calvesSnapshot = await FirebaseFirestore.instance
          .collection('calves')
          .doc(_adminEmail)
          .collection('entries')
          .get();

      print('Calves entries fetched: ${calvesSnapshot.docs.length}');
      final calvesCount = calvesSnapshot.docs.length;

      if (mounted) {
        setState(() {
          _cattleCount = cattleCount;
          _workersCount = workersCount;
          _calvesCount = calvesCount;
        });
      }
    } catch (e) {
      print('Error fetching counts: $e');
      if (mounted) {
        setState(() {
          _cattleCount = 0;
          _workersCount = 0;
          _calvesCount = 0;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNavbar(),
      drawer: SidebarMenu(
        onSelectPage: _onSelectPage,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildWelcomeCard(context),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PageView(
                scrollDirection: Axis.horizontal,
                controller: _controller,
                children: [
                  MyCard(
                    balance: _monthlyRevenue + _cowSales,
                    cardHeader: 'Total monthly production',
                    color: Color.fromARGB(255, 88, 216, 92),
                    backgroundImage: 'assets/milk_sales.jpeg',
                  ),
                  MyCard(
                    balance: _cowSales,
                    cardHeader: 'Cow Sales',
                    color: Color.fromARGB(255, 27, 187, 152),
                    backgroundImage: 'assets/card_background_2.jpg',
                  ),
                  MyCard(
                    balance: -_feedCost,
                    cardHeader: 'Cow Feeds Management',
                    color: Color.fromARGB(255, 18, 99, 161),
                    backgroundImage: 'assets/card_background_3.jpg',
                  ),
                  MyCard(
                    balance: -_salaryCost,
                    cardHeader: 'Employee Salary management',
                    color: Color.fromARGB(255, 10, 72, 13),
                    backgroundImage: 'assets/slaary.jpeg',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 3, 154, 242),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SmoothPageIndicator(
                controller: _controller,
                count: 4,
                effect: const ExpandingDotsEffect(
                  activeDotColor: Color.fromARGB(255, 3, 154, 242),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildFarmStats(
              cattleCount: _cattleCount,
              workersCount: _workersCount,
              calvesCount: _calvesCount,
              context: context,
            ),
            _buildStatsCards(context, totalSales, totalMilkDistributed),
            _buildOrderStatsCard(context),
            _buildExpenseOverviewCard(context),
            _buildInventorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: const AssetImage(
                'assets/abstract-light-blue-wide-background-with-radial-blue-gradients-vector.jpg'),
            fit: BoxFit.cover, // Adjust the image to cover the entire card
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(
                  0.8), // Optional: Add a color filter for better text visibility
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildColorizedAnimation(context), // Use the animated text here
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Your farm procedures, records, inventory, sales and Reports on the Go',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'DAILY WE DAIRY',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/cattleListPage');
                    },
                    child: const Text('My Cattle'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/workerList');
                    },
                    child: const Text('My Employees'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/reports');
                    },
                    child: const Text('Reports'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorizedAnimation(BuildContext context) => Center(
        child: AnimatedTextKit(
          repeatForever: true, // Ensures the animation repeats forever
          animatedTexts: [
            ColorizeAnimatedText(
              'Hello ${farmName?.toUpperCase()}🎉',
              textStyle: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              colors: const [
                Colors.purple,
                Colors.blue,
                Color.fromARGB(255, 6, 230, 25),
                Color.fromARGB(255, 10, 27, 213),
              ],
            ),
          ],
        ),
      );
  Widget _buildStatsCards(
      BuildContext context, double totalSales, double totalMilkDistributed) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Card(
            color: Color.fromARGB(255, 64, 196, 255),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Total Monthly Production in Litres',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      'Total: ${totalMilkDistributed > 0 ? totalMilkDistributed : 'No data'} Litres'),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            color: Color.fromARGB(255, 64, 196, 255),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Sales', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      'Total Sales: Kshs${totalSales > 0 ? totalSales : 'No data'}'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

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
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (fetchedData.isEmpty)
                const Center(child: Text('No data available'))
              else
                Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  height: 300.0,
                  child: LineChartSample2(
                    fetchedData: fetchedData, // Pass the fetched milk sales data here
                    collectionName: 'milk_production', // Indicating this is for milk sales
                  ),
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

  Widget _buildExpenseOverviewCard(BuildContext context) {
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

  Widget _buildInventorySection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Consistent rounded corners
      ),
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
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
            children: [
              const Text(
                'Inventory',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Adjusted text color for visibility
                ),
              ),
              const SizedBox(height: 8.0),
              _buildInventoryItem(
                  'Feed', '15% low', Icons.food_bank, Colors.blue),
              _buildInventoryItem(
                  'Pasture', '20% growth', Icons.grass, Colors.green),
              _buildInventoryItem('Dairy Equipment', '5% maintenance',
                  Icons.build, Colors.orange),
              _buildInventoryItem(
                  'Housing', '10% renovation', Icons.home, Colors.brown),
              _buildInventoryItem('Other Materials', '15% inspection',
                  Icons.hardware, Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryItem(
      String title, String subtitle, IconData icon, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white, // Adjusted text color for better contrast
        ),
      ),
      subtitle: Text(
        subtitle,
        style:
            const TextStyle(color: Colors.white70), // Slightly lighter subtitle
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color,
      {Function()? onTap}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.lightBlue,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFarmStats({
    required int cattleCount,
    required int workersCount,
    required int calvesCount,
    required BuildContext context,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/cattleListPage');
            },
            child: _buildInfoCard(
              'Cows',
              '$cattleCount',
              Icons.pets,
              Colors.brown,
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/workerList');
            },
            child: _buildInfoCard(
              'Employees',
              '$workersCount',
              Icons.people,
              Colors.blue,
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/calving');
            },
            child: _buildInfoCard(
              'Calves',
              '$calvesCount',
              Icons.pets,
              Colors.green,
            ),
          ),
        ),
      ],
    );
  }
}
