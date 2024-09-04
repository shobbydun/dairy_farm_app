import 'package:dairy_harbor/components/widgets/add_sale_form.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MilkDistributionSales extends StatefulWidget {
  const MilkDistributionSales({super.key});

  @override
  _MilkDistributionSalesState createState() => _MilkDistributionSalesState();
}

class _MilkDistributionSalesState extends State<MilkDistributionSales> {
  List<Sale> _sales = [];

  void _addSale(Sale sale) {
    setState(() {
      _sales.add(sale);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            // Date Selector
            ElevatedButton(
              onPressed: () {
                _showDateRangePicker(context);
              },
              child: const Text('Select Date Range'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Sales Summary
            Card(
              elevation: 6.0,
              margin: const EdgeInsets.only(bottom: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sales Summary',
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const SizedBox(height: 12.0),
                    Wrap(
                      spacing: 24.0,
                      runSpacing: 12.0,
                      children: [
                        _buildSummaryItem('Total Sales', 'Kshs5,000'),
                        _buildSummaryItem('Total Milk Distributed', '1,200 liters'),
                        _buildSummaryItem('Total Revenue', 'Kshs3,000'),
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
                  height: 300.0, // Adjust height as needed
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
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
                          spots: [
                            FlSpot(0, 2000),
                            FlSpot(1, 1500),
                            FlSpot(2, 3000),
                            FlSpot(3, 1000),
                          ],
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

            // Sales List
            ListView.builder(
              itemCount: _sales.length,
              shrinkWrap: true, // Important to make the ListView fit inside the column
              physics: NeverScrollableScrollPhysics(), // Prevents nested scrolling conflicts
              itemBuilder: (context, index) {
                final sale = _sales[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      'Sale ${index + 1}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Milk Distributed: ${sale.milkDistributed} liters'),
                    trailing: Text(
                      'Kshs${sale.saleAmount}',
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () {
                      // Handle tile tap
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddSaleForm(onSave: _addSale),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Sale',
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16.0, color: Colors.black54),
        ),
      ],
    );
  }

  void _showDateRangePicker(BuildContext context) async {
    final DateTime? startDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    final DateTime? endDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (startDate != null && endDate != null && startDate.isBefore(endDate)) {
      // Handle the selected date range
    }
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
            onPressed: () {
              // Implement download functionality here
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class Sale {
  final double saleAmount;
  final double milkDistributed;

  Sale({required this.saleAmount, required this.milkDistributed});
}
