import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';

class MilkDistributionSales extends StatefulWidget {
  final Future<String?> adminEmailFuture;

  const MilkDistributionSales(
      {super.key, required this.adminEmailFuture, Object? arguments});

  @override
  _MilkDistributionSalesState createState() => _MilkDistributionSalesState();
}

class _MilkDistributionSalesState extends State<MilkDistributionSales> {
  final GlobalKey _chartKey = GlobalKey();
  DateTime? _startDate;
  DateTime? _endDate;
  double totalSales = 0.0;
  double totalMilkDistributed = 0.0;
  List<FlSpot> chartData = [];
  String selectedPeriod = 'weekly';
  String? _adminEmail;

  @override
  void initState() {
    super.initState();
    _setDefaultDateRange();
    _fetchAdminEmail();
  }

  Future<void> _fetchAdminEmail() async {
    _adminEmail = await widget.adminEmailFuture;
    if (_adminEmail != null) {
      await _fetchData(); // Fetch data after getting the admin email
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _setDefaultDateRange() {
    final now = DateTime.now();
    if (selectedPeriod == 'weekly') {
      _startDate =
          now.subtract(Duration(days: now.weekday - 1)); // Start of the week
      _endDate = now.add(Duration(days: 7 - now.weekday)); // End of the week
    } else if (selectedPeriod == 'monthly') {
      _startDate = DateTime(now.year, now.month, 1); // Start of the month
      _endDate = DateTime(now.year, now.month + 1, 0); // End of the month
    }
  }

 Future<void> _fetchData() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null &&
      _startDate != null &&
      _endDate != null &&
      _adminEmail != null) {
    try {
      QuerySnapshot entriesSnapshot = await FirebaseFirestore.instance
          .collection('milk_production')
          .doc(_adminEmail)
          .collection('entries')
          .get();


      double sales = 0.0;
      double milkDistributed = 0.0;
      List<FlSpot> spots = [];

      if (entriesSnapshot.docs.isEmpty) {
        print('No entries found for the selected date range.');
      } else {
        print('Fetched ${entriesSnapshot.docs.length} entries.');

        for (var doc in entriesSnapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          DateTime date = (data['date'] as Timestamp).toDate();

          // Ensure that the entry falls within the selected date range
          if (date.isAfter(_startDate!) && date.isBefore(_endDate!.add(Duration(days: 1)))) {
            double milkInLitres = double.tryParse(data['final_in_litres'].toString()) ?? 0;
            double pricePerLitre = double.tryParse(data['price_per_litre'].toString()) ?? 0;

            sales += milkInLitres * pricePerLitre;
            milkDistributed += milkInLitres;

            print('Current Sales Entry: $milkInLitres * $pricePerLitre = ${milkInLitres * pricePerLitre}');

            if (selectedPeriod == 'weekly') {
              int dayOfWeek = date.weekday;
              spots.add(FlSpot(dayOfWeek.toDouble(), milkInLitres * pricePerLitre));
            } else if (selectedPeriod == 'monthly') {
              int month = date.month;
              spots.add(FlSpot(month.toDouble(), milkInLitres * pricePerLitre));
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          totalSales = sales;
          totalMilkDistributed = milkDistributed;
          chartData = spots.isNotEmpty ? spots : [FlSpot(0, 0)];
        });
      }

      print('Total Sales: $totalSales');
      print('Total Milk Distributed: $totalMilkDistributed');
      print('Chart Data: $chartData');
    } catch (e) {
      print('Error fetching data: $e');
    }
  } else {
    print('User is not authenticated or dates are not set or admin email is null.');
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
    // Capture the chart as an image
    final RenderRepaintBoundary boundary =
        _chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // Create a PDF document
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text('Sales Summary', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.Text('Total Sales: Kshs$totalSales',
                style: pw.TextStyle(fontSize: 18)),
            pw.Text('Total Milk Distributed: $totalMilkDistributed liters',
                style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 20),
            pw.Image(
                pw.MemoryImage(pngBytes)), // Add the captured chart image here
          ],
        ),
      ),
    );

    // Save PDF to bytes
    final pdfBytes = await pdf.save();

    // Upload PDF to Firebase Storage
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String fileName =
          'sales_summary_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      Reference ref =
          FirebaseStorage.instance.ref().child('sales_summaries/$fileName');

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
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
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
                    const DropdownMenuItem(
                        value: 'weekly', child: Text('Weekly')),
                    const DropdownMenuItem(
                        value: 'monthly', child: Text('Monthly')),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sales Summary',
                        style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue)),
                    const SizedBox(height: 12.0),
                    Wrap(
                      spacing: 24.0,
                      runSpacing: 12.0,
                      children: [
                        _buildSummaryItem('Total Sales', 'Kshs$totalSales'),
                        _buildSummaryItem('Total Milk Distributed',
                            '$totalMilkDistributed liters'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // milk Sales Chart
            Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200,
                    blurRadius: 9,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: RepaintBoundary(
                  key: _chartKey,
                  child: SizedBox(
                    height: 300.0,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                if (selectedPeriod == 'weekly') {
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
                                    );
                                  }
                                } else if (selectedPeriod == 'monthly') {
                                  int index = value.toInt();
                                  if (index >= 1 && index <= 12) {
                                    return Text(
                                      [
                                        'Jan',
                                        'Feb',
                                        'Mar',
                                        'Apr',
                                        'May',
                                        'Jun',
                                        'Jul',
                                        'Aug',
                                        'Sep',
                                        'Oct',
                                        'Nov',
                                        'Dec'
                                      ][index - 1],
                                    );
                                  }
                                }
                                return const Text(''); // Empty if out of range
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
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                        minX: selectedPeriod == 'weekly'
                            ? 1
                            : 1, // Ensure correct min X value
                        maxX: selectedPeriod == 'weekly'
                            ? 7
                            : 12, // Ensure correct max X value
                        minY:
                            0, // Set minimum Y value to avoid going below zero
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

  Widget _buildSummaryItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
                const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
        Text(value,
            style: const TextStyle(fontSize: 16.0, color: Colors.black54)),
      ],
    );
  }
}
