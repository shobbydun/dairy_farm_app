import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dairy_harbor/components/inventory_components/bar_chart_data.dart';
import 'package:dairy_harbor/components/widgets/line_chart.dart';
import 'package:dairy_harbor/components/widgets/my_app_bar.dart';
import 'package:dairy_harbor/components/widgets/my_card.dart';
import 'package:dairy_harbor/components/widgets/side_bar.dart';
import 'package:dairy_harbor/services_functions/data_service.dart';
import 'package:dairy_harbor/services_functions/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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

  final DataService _dataService = DataService();

  List<Map<String, dynamic>> fetchedData = [];
  int cattleCount = 0;
  int workersCount = 0;
  int calvesCount = 0;
  bool isLoading = true;

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
    _loadData();
    if (widget.user != null && widget.userId.isNotEmpty) {
      _fetchFarmName();
    } else {
      print("No user is currently logged in or user ID is empty.");
    }
  }
  void _onSelectPage(String route) {
    Navigator.pushNamed(context, route);
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
                    cardNumber: 56724538,
                    expiryMonth: 12,
                    expiryYear: 29,
                    color: Color.fromARGB(255, 88, 216, 92),
                    backgroundImage: 'assets/milk_sales.jpeg',
                  ),
                  MyCard(
                    balance: 68274.34,
                    cardHeader: 'Cow Sales',
                    cardNumber: 56724538,
                    expiryMonth: 12,
                    expiryYear: 29,
                    color: Color.fromARGB(255, 27, 187, 152),
                    backgroundImage: 'assets/card_background_2.jpg',
                  ),
                  MyCard(
                    balance: 7863.34,
                    cardHeader: 'Cow Feeds Management',
                    cardNumber: 56724538,
                    expiryMonth: 12,
                    expiryYear: 29,
                    color: Color.fromARGB(255, 18, 99, 161),
                    backgroundImage: 'assets/card_background_3.jpg',
                  ),
                  MyCard(
                    balance: 10982.34,
                    cardHeader: 'Employee Salary management',
                    cardNumber: 56724538,
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
            cattleCount: cattleCount,
            workersCount: workersCount,
            calvesCount: calvesCount,
          ),
            _buildStatsCards(context),
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
          image: const AssetImage('assets/abstract-light-blue-wide-background-with-radial-blue-gradients-vector.jpg'),
          fit: BoxFit.cover, // Adjust the image to cover the entire card
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.8), // Optional: Add a color filter for better text visibility
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
  Widget _buildStatsCards(BuildContext context) {
    return const Row(
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
                  Text('Total: 1000 Litres'),
                  Text('Increase: 10%'),
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
                  Text('Total Sales: 5000'),
                  Text('Increase: 15%'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }



Widget _buildOrderStatsCard(BuildContext context) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.all(8.0),
    child: Container(
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/abstract-light-blue-wide-background-with-radial-blue-gradients-vector.jpg'),
          fit: BoxFit.cover, // This will ensure the image covers the entire card
        ),
        borderRadius: BorderRadius.circular(12), // Same border radius as the card
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
                color: Colors.white, // Change text color to contrast with the image
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

Widget _buildExpenseOverviewCard(BuildContext context) {
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
                color: Colors.white, // Set text color for better contrast
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


// void main() {
//   runApp(MaterialApp(
//     home: HomePage(
//       barChartData: _createBarChartData(),
//       pieChartData: _createPieChartData(),
//       lineChartData: _createLineChartData(),
//       animate: true,
//     ),
//   ));
// }

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
      style: const TextStyle(color: Colors.white70), // Slightly lighter subtitle
    ),
  );
}



  Widget _buildInfoCard(String title, String count, IconData icon, Color color) {
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
                        count,
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
    );
  }

 Widget _buildFarmStats({
  required int cattleCount,
  required int workersCount,
  required int calvesCount,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Expanded(
        child: _buildInfoCard(
          'Cows',
          '$cattleCount',
          Icons.pets,
          Colors.brown,
        ),
      ),
      Expanded(
        child: _buildInfoCard(
          'Employees',
          '$workersCount',
          Icons.people,
          Colors.blue,
        ),
      ),
      Expanded(
        child: _buildInfoCard(
          'Calves',
          '$calvesCount',
          Icons.pets,
          Colors.green,
        ),
      ),
    ],
  );
}
}