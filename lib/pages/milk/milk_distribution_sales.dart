import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';

class MilkDistributionSales extends StatefulWidget {
  const MilkDistributionSales({super.key});

  @override
  _MilkDistributionSalesState createState() => _MilkDistributionSalesState();
}

class _MilkDistributionSalesState extends State<MilkDistributionSales> {
  DateTime? _startDate;
  DateTime? _endDate;
  double totalSales = 0.0;
  double totalMilkDistributed = 0.0;
  List<FlSpot> chartData = [];
  String selectedPeriod = 'weekly';

  @override
  void initState() {
    super.initState();
    _setDefaultDateRange();
    _fetchData();
  }

  void _setDefaultDateRange() {
    final now = DateTime.now();
    if (selectedPeriod == 'weekly') {
      _startDate = now.subtract(Duration(days: now.weekday - 1)); // Start of the week
      _endDate = now.add(Duration(days: 7 - now.weekday)); // End of the week
    } else if (selectedPeriod == 'monthly') {
      _startDate = DateTime(now.year, now.month, 1); // Start of the month
      _endDate = DateTime(now.year, now.month + 1, 0); // End of the month
    }
  }

  void _fetchData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && _startDate != null && _endDate != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('milk_production')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate!))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(_endDate!))
          .get();

      double sales = 0.0;
      double milkDistributed = 0.0;
      List<FlSpot> spots = [];

      if (selectedPeriod == 'weekly') {
        Map<int, double> dailyData = {};
        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          DateTime date = (data['date'] as Timestamp).toDate();
          double milkInLitres = double.tryParse(data['final_in_litres'].toString()) ?? 0;
          double pricePerLitre = double.tryParse(data['price_per_litre'].toString()) ?? 0;

          sales += milkInLitres * pricePerLitre;
          milkDistributed += milkInLitres;

          int dayOfWeek = date.weekday; // 1 (Mon) to 7 (Sun)
          dailyData[dayOfWeek] = (dailyData[dayOfWeek] ?? 0) + milkInLitres;

          // Prepare chart data
          spots.add(FlSpot(dayOfWeek.toDouble(), dailyData[dayOfWeek]! * pricePerLitre));
        }
      } else if (selectedPeriod == 'monthly') {
        Map<int, double> monthlyData = {};
        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          DateTime date = (data['date'] as Timestamp).toDate();
          double milkInLitres = double.tryParse(data['final_in_litres'].toString()) ?? 0;
          double pricePerLitre = double.tryParse(data['price_per_litre'].toString()) ?? 0;

          sales += milkInLitres * pricePerLitre;
          milkDistributed += milkInLitres;

          int month = date.month; // 1 (Jan) to 12 (Dec)
          monthlyData[month] = (monthlyData[month] ?? 0) + milkInLitres;

          // Prepare chart data
          spots.add(FlSpot(month.toDouble(), monthlyData[month]! * pricePerLitre));
        }
      }

      setState(() {
        totalSales = sales;
        totalMilkDistributed = milkDistributed;
        chartData = spots.isNotEmpty ? spots : [FlSpot(0, 0)]; // Ensure chart data has at least one point
      });

      // Debugging statements
      print('Total Sales: $totalSales');
      print('Total Milk Distributed: $totalMilkDistributed');
      print('Chart Data: $chartData');
    }
  }

  void _showDateRangePicker(BuildContext context) async {
    showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((value) {
      if (value != null) {
        setState(() {
          _startDate = value.start;
          _endDate = value.end;
        });
        _fetchData(); // Fetch data for the selected date range
      }
    });
  }

  void _showDownloadConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Summary'),
        content: const Text('Do you want to download the sales summary?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Download'),
            onPressed: () async {
              Navigator.of(context).pop();
              await _downloadSummary();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _downloadSummary() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text('Sales Summary', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.Text('Total Sales: Kshs$totalSales', style: pw.TextStyle(fontSize: 18)),
            pw.Text('Total Milk Distributed: $totalMilkDistributed liters', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 20),
            pw.Text('Sales Chart (See attached graph)', style: pw.TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );

    // Save PDF to bytes
    final pdfBytes = await pdf.save();

    // Upload PDF to Firebase Storage
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String fileName = 'sales_summary_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      Reference ref = FirebaseStorage.instance.ref().child('sales_summaries/$fileName');

      // Upload the file
      await ref.putData(pdfBytes);

      // Get the download URL
      String downloadUrl = await ref.getDownloadURL();

      // Open the URL in a web browser
      if (await canLaunch(downloadUrl)) {
        await launch(downloadUrl);
      } else {
        throw 'Could not launch $downloadUrl';
      }
    }
  }

  void _changePeriod(String? value) {
    setState(() {
      selectedPeriod = value!;
      _setDefaultDateRange(); // Reset the date range based on the selected period
      _fetchData(); // Re-fetch data based on the new selection
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: const Text('Milk Distribution & Sales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              _showDownloadConfirmation(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                _showDateRangePicker(context);
              },
              child: const Text('Select Date Range'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
            const SizedBox(height: 16.0),

            // Period Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Select Period:'),
                DropdownButton<String>(
                  value: selectedPeriod,
                  items: [
                    const DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    const DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  ],
                  onChanged: _changePeriod,
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Sales Summary Card
            Card(
              elevation: 6.0,
              margin: const EdgeInsets.only(bottom: 16.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sales Summary', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 12.0),
                    Wrap(
                      spacing: 24.0,
                      runSpacing: 12.0,
                      children: [
                        _buildSummaryItem('Total Sales', 'Kshs$totalSales'),
                        _buildSummaryItem('Total Milk Distributed', '$totalMilkDistributed liters'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Sales Chart
            Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 300.0,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt() - (selectedPeriod == 'weekly' ? 1 : 1);
                              if (selectedPeriod == 'weekly' && index >= 0 && index < 7) {
                                return Text(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index]);
                              } else if (selectedPeriod == 'monthly' && index >= 0 && index < 12) {
                                return Text(['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][index]);
                              }
                              return const Text(''); // Empty if out of range
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(value.toInt().toString());
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: const Color.fromARGB(255, 9, 136, 240),
                          width: 1,
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: chartData,
                          isCurved: true,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(show: false),
                          color: Colors.blue,
                        ),
                      ],
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

  Widget _buildSummaryItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 16.0, color: Colors.black54)),
      ],
    );
  }
}
