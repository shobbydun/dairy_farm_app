import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dairy_harbor/components/widgets/my_app_bar.dart';
import 'package:dairy_harbor/components/widgets/my_card.dart';
import 'package:dairy_harbor/components/widgets/side_bar.dart';
import 'package:dairy_harbor/pages/inventory/feeds_page.dart';
import 'package:dairy_harbor/pages/manage_cattle/cattle_list_page.dart';
import 'package:dairy_harbor/pages/milk/milk_distribution_sales.dart';
import 'package:dairy_harbor/pages/procedures/calving_page.dart';
import 'package:dairy_harbor/pages/workers/worker_list_page.dart';
import 'package:dairy_harbor/services_functions/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage extends StatefulWidget {
  final FirestoreServices firestoreServices;
  final List<BarChartGroupData> barChartData;
  final List<PieChartSectionData> pieChartData;
  final List<LineChartBarData> lineChartData;
  final bool animate;
  final User? user;
  final String userId;

  HomePage({
    super.key,
    required this.barChartData,
    required this.pieChartData,
    required this.lineChartData,
    required this.animate,
    this.user,
    required this.firestoreServices,
    required this.userId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? farmName;

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

  @override
  void initState() {
    super.initState();
    //_loadData();
    if (widget.user != null && widget.userId.isNotEmpty) {
      _fetchFarmName();
    } else {
      print("No user is currently logged in or user ID is empty.");
    }
    _fetchCounts();
    _fetchData();
    _fetchWeeklyExpenses();
  }

  void _fetchData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch all documents in the milk_production collection for the user
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('milk_production')
          .get(); // No date filtering

      double sales = 0.0;
      double milkDistributed = 0.0;

      // Initialize daily data storage
      Map<int, double> dailyData = {}; // For each day of the week

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        double milkInLitres =
            double.tryParse(data['final_in_litres'].toString()) ?? 0;
        double pricePerLitre =
            double.tryParse(data['price_per_litre'].toString()) ?? 0;

        // Calculate sales and milk distributed
        sales += milkInLitres * pricePerLitre;
        milkDistributed += milkInLitres;

        // Assuming `date` is stored in the document to determine the day
        DateTime date = (data['date'] as Timestamp).toDate();
        int dayOfWeek = date.weekday; // 1 (Monday) to 7 (Sunday)
        dailyData[dayOfWeek] =
            (dailyData[dayOfWeek] ?? 0) + milkInLitres; // Sum milk for each day
      }

      // Convert daily data into chart data
      chartData = [];
      for (int i = 1; i <= 7; i++) {
        double totalForDay = dailyData[i] ?? 0;
        chartData.add(
            FlSpot(i.toDouble(), totalForDay)); // Create FlSpot for each day
      }

      setState(() {
        totalSales = sales; // Update total sales
        totalMilkDistributed = milkDistributed; // Update total milk distributed
      });

      // Debugging statements
      print('Total Sales: $totalSales');
      print('Total Milk Distributed: $totalMilkDistributed');
      print('Chart Data: $chartData');
    }
  }

  void _onSelectPage(String route) {
    Navigator.pushNamed(context, route);
  }

  // Future<void> _loadData() async {
  //   setState(() {
  //     isLoading = true;
  //   });

  //   // Fetch data concurrently
  //   Future.wait([
  //     _dataService.fetchMilkSalesData().then((data) {
  //       setState(() {
  //         fetchedData = data;
  //       });
  //     }),
  //     _dataService.fetchCattleCount().then((count) {
  //       setState(() {
  //         cattleCount = count;
  //       });
  //     }),
  //     _dataService.fetchWorkersCount().then((count) {
  //       setState(() {
  //         workersCount = count;
  //       });
  //     }),
  //     _dataService.fetchCalvesCount().then((count) {
  //       setState(() {
  //         calvesCount = count;
  //       });
  //     }),
  //   ]).whenComplete(() {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   });
  // }

 Future<void> _fetchCounts() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  // Count cattle
  final cattleCount = await FirebaseFirestore.instance
      .collection('cattle')
      .where('userId', isEqualTo: userId)
      .get()
      .then((snapshot) => snapshot.docs.length);

  // Count workers
  final workersCount = await FirebaseFirestore.instance
      .collection('workers')
      .where('userId', isEqualTo: userId)
      .get()
      .then((snapshot) => snapshot.docs.length);

  // Count calves
  final calvesCount = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('calves')
      .get()
      .then((snapshot) => snapshot.docs.length);

  // Check if the widget is still mounted before calling setState
  if (mounted) {
    setState(() {
      _cattleCount = cattleCount; // Update state variables
      _workersCount = workersCount;
      _calvesCount = calvesCount;
    });
  }
}


  Future<void> _fetchWeeklyExpenses() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final now = DateTime.now();
      final startOfWeek = now.subtract(
          Duration(days: now.weekday - 1)); // Monday of the current week
      final endOfWeek =
          startOfWeek.add(Duration(days: 6)); // Sunday of the current week

      // Fetch expenses for the current week
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('feeds')
          .where('userId', isEqualTo: userId) // Filter by userId
          .where('date',
              isGreaterThanOrEqualTo:
                  DateFormat('yyyy-MM-dd').format(startOfWeek))
          .where('date',
              isLessThanOrEqualTo: DateFormat('yyyy-MM-dd').format(endOfWeek))
          .get();

      // Reset daily expenses
      dailyExpenses = List<double>.filled(7, 0.0);

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String dateString = data['date']; // Get the date as a string
        DateTime date =
            DateFormat('yyyy-MM-dd').parse(dateString); // Parse it to DateTime
        double cost = data['cost'] ?? 0.0;

        // Sum costs for each day of the week
        int dayIndex = date.weekday - 1; // 0 = Monday, 6 = Sunday
        dailyExpenses[dayIndex] += cost;
      }

      // Prepare data for the chart
      chartData = List<FlSpot>.generate(
          7, (index) => FlSpot(index.toDouble(), dailyExpenses[index]));

      print('Weekly Expenses: $dailyExpenses'); // Debug print to check expenses
      setState(() {}); // Refresh the widget
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
                children: const [
                  MyCard(
                    balance: 1543.34,
                    cardHeader: 'Total monthly production',
                    cardNumber: 1130000,
                    expiryMonth: 12,
                    expiryYear: 29,
                    color: Color.fromARGB(255, 88, 216, 92),
                    backgroundImage: 'assets/milk_sales.jpeg',
                  ),
                  MyCard(
                    balance: 68274.34,
                    cardHeader: 'Cow Sales',
                    cardNumber: 250000,
                    expiryMonth: 12,
                    expiryYear: 29,
                    color: Color.fromARGB(255, 27, 187, 152),
                    backgroundImage: 'assets/card_background_2.jpg',
                  ),
                  MyCard(
                    balance: 7863.34,
                    cardHeader: 'Cow Feeds Management',
                    cardNumber: -538,
                    expiryMonth: 12,
                    expiryYear: 29,
                    color: Color.fromARGB(255, 18, 99, 161),
                    backgroundImage: 'assets/card_background_3.jpg',
                  ),
                  MyCard(
                    balance: 10982.34,
                    cardHeader: 'Employee Salary management',
                    cardNumber: -120000,
                    expiryMonth: 12,
                    expiryYear: 29,
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
                  Text('Total: $totalMilkDistributed Litres'),
                  // Calculate and display increase percentage if needed
                  // Example: Text('Increase: X%'),
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
                  Text('Total Sales: Kshs$totalSales'),
                  // Calculate and display increase percentage if needed
                  // Example: Text('Increase: Y%'),
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
        // Navigate to MilkDistributionSales page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MilkDistributionSales()),
        );
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
                  height: 200.0,
                  child: LineChart(
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
                                return Text(
                                  [
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                    'Sat',
                                    'Sun'
                                  ][index - 1],
                                  style: const TextStyle(color: Colors.black),
                                );
                              }
                              return const Text(''); // Empty if out of range
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (value, meta) {
                              return Text(value.toInt().toString(),
                                  style: const TextStyle(color: Colors.black));
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
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                      minX: 1,
                      maxX: 7,
                      minY: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0), // Space before the hint
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
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    child: Container(
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage(
              'assets/abstract-light-blue-wide-background-with-radial-blue-gradients-vector.jpg'),
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
                      sideTitles: SideTitles(showTitles: false), // No right titles
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false), // No top titles
                    ),
                  ),
                  borderData: FlBorderData(show: false), // No borders
                  barGroups: List.generate(
                    7,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: dailyExpenses[index],
                          color: Colors.green,
                          width: 20, // Increase bar thickness
                        ),
                      ],
                    ),
                  ),
                  gridData: FlGridData(show: false), // Remove grid lines
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                // Navigate to FeedsPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedsPage()),
                );
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


  List<BarChartGroupData> _createBarChartData() {
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(toY: 5000, color: Colors.blue),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(toY: 2500, color: Colors.blue),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(toY: 10000, color: Colors.blue),
        ],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(toY: 7500, color: Colors.blue),
        ],
      ),
    ];
  }

  List<PieChartSectionData> _createPieChartData() {
    return [
      PieChartSectionData(value: 30, color: Colors.blue, title: '30%'),
      PieChartSectionData(value: 20, color: Colors.red, title: '20%'),
      PieChartSectionData(value: 25, color: Colors.green, title: '25%'),
      PieChartSectionData(value: 25, color: Colors.orange, title: '25%'),
    ];
  }

  List<LineChartBarData> _createLineChartData() {
    return [
      LineChartBarData(
        spots: [
          const FlSpot(0, 5000),
          const FlSpot(1, 2500),
          const FlSpot(2, 10000),
          const FlSpot(3, 7500),
        ],
        isCurved: true,
        color: Colors.blue,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: true),
      ),
    ];
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CattleList(), // Navigate to Cattle List
                ),
              );
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      WorkerListPage(), // Navigate to Workers List
                ),
              );
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CalvingPage(), // Navigate to Calving Page
                ),
              );
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
