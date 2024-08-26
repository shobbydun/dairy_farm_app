import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Overview Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOverviewCard('Total Income', 'This Month', 12000),
                  _buildOverviewCard('Total Expenses', 'This Month', 8000),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOverviewCard('Net Profit/Loss', 'This Month', 4000),
                  _buildOverviewCard('Yearly Income', 'Total', 150000),
                ],
              ),
              const SizedBox(height: 24.0),

              // Charts Section
              _buildChartCard(
                  'Income Analysis (In 1000s)', _buildIncomeChart()),
              _buildChartCard(
                  'Expense Analysis (In 1000s)', _buildExpenseChart()),
              _buildChartCard(
                  'Milk Sales Analysis (In 1000s)', _buildMilkSalesChart()),
              _buildChartCard('Profit/Loss Analysis', _buildProfitLossChart()),
              _buildChartCard('Inventory Cost Analysis (In 1000s)',
                  _buildInventoryCostChart()),
              const SizedBox(height: 24.0),

              // Inventory Section
              _buildInventorySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(String title, String subtitle, int value) {
    return Expanded(
      child: Card(
        color: Colors.white,
        elevation: 6.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              const SizedBox(height: 8.0),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54)),
              const SizedBox(height: 8.0),
              Text('\Kshs:$value',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      color: Colors.white,
      elevation: 6.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 16.0),
            SizedBox(height: 250, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeChart() {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(1, 3),
              FlSpot(2, 6),
              FlSpot(3, 4),
              FlSpot(4, 7),
            ],
            isCurved: true,
            barWidth: 10,
            color: Colors.blue,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        gridData: FlGridData(show: true),
      ),
    );
  }

  Widget _buildExpenseChart() {
    return BarChart(
      BarChartData(
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        barGroups: [
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: 6,
                color: Colors.red,
                width: 35,
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: 7,
                color: Colors.greenAccent,
                width: 35,
              ),
            ],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [
              BarChartRodData(
                toY: 5,
                color: Colors.orange,
                width: 35,
              ),
            ],
          ),
        ],
        gridData: FlGridData(show: true),
      ),
    );
  }

  Widget _buildMilkSalesChart() {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(1, 3),
              FlSpot(2, 5),
              FlSpot(3, 4.5),
              FlSpot(4, 6.5),
            ],
            isCurved: true,
            barWidth: 5,
            color: Colors.orange,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        gridData: FlGridData(show: true),
      ),
    );
  }

  Widget _buildProfitLossChart() {
    return BarChart(
      BarChartData(
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        barGroups: [
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: 6,
                color: Colors.green,
                width: 15,
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: -3,
                color: Colors.red,
                width: 15,
              ),
            ],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [
              BarChartRodData(
                toY: 5,
                color: Colors.green,
                width: 15,
              ),
            ],
          ),
        ],
        gridData: FlGridData(show: true),
      ),
    );
  }

  Widget _buildInventoryCostChart() {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(1, 2),
              FlSpot(2, 3.5),
              FlSpot(3, 4),
              FlSpot(4, 5),
            ],
            isCurved: true,
            barWidth: 6,
            color: Colors.purple,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        gridData: FlGridData(show: true),
        // Removed lineTouchData parameter
      ),
    );
  }

  Widget _buildInventorySection() {
    return Card(
      color: Colors.white,
      elevation: 6.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inventory Status',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 16.0),
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
    );
  }

  Widget _buildInventoryItem(
      String title, String subtitle, IconData icon, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }
}
