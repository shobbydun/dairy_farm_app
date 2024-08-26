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
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final monthIndex = value.toInt();
                final months = [
                  'Jan',
                  'Feb',
                  'Mar',
                  'Apr'
                ]; // Update with actual months
                if (monthIndex < months.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      months[monthIndex],
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  );
                } else {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: const Text(''),
                  );
                }
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
                    value.toInt() > 0 ? '${value.toInt()}' : '',
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 3000),
              FlSpot(1, 6000),
              FlSpot(2, 4000),
              FlSpot(3, 7000),
            ],
            isCurved: false,
            barWidth: 5,
            color: Colors.blue,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        gridData: FlGridData(show: false),
      ),
    );
  }

  Widget _buildExpenseChart() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4), // Shadow position
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    final categories = [
                      'Jan',
                      'Feb',
                      'Mar',
                      'Apr'
                    ]; // Update with actual categories
                    final index = value.toInt();
                    if (index >= 0 && index < categories.length) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          categories[index],
                          style: const TextStyle(
                              color: Colors.black, fontSize: 12),
                        ),
                      );
                    } else {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: const Text(''),
                      );
                    }
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
                        value.toInt() > 0 ? '${value.toInt()}' : '',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(
              show: false,
            ),
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: 6000,
                    color: Colors.red,
                    width: 30,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: 7000,
                    color: Colors.greenAccent,
                    width: 30,
                    borderRadius: BorderRadius.circular(6), 
                  ),
                ],
              ),
              BarChartGroupData(
                x: 2,
                barRods: [
                  BarChartRodData(
                    toY: 5000,
                    color: Colors.orange,
                    width: 30,
                    borderRadius: BorderRadius.circular(6), 
                  ),
                ],
              ),
            ],
            gridData: FlGridData(show: false),
          ),
        ),
      ),
    );
  }

  Widget _buildMilkSalesChart() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4), // Shadow position
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    final months = ['Jan', 'Feb', 'Mar', 'Apr'];
                    final index = value.toInt();
                    if (index >= 0 && index < months.length) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          months[index],
                          style: const TextStyle(
                              color: Colors.black, fontSize: 12),
                        ),
                      );
                    } else {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: const Text(''),
                      );
                    }
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
                        value.toInt() > 0 ? '${value.toInt()}' : '',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(
              show: false,
            ),
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(0, 2000),
                  FlSpot(1, 3500),
                  FlSpot(2, 3000),
                  FlSpot(3, 4500),
                ],
                isCurved: true,
                barWidth: 5,
                color: Colors.orange,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(show: false),
              ),
            ],
            gridData: FlGridData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(),
              touchSpotThreshold: 8,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfitLossChart() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4), // Shadow position
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    final periods = [
                      'Week 1',
                      'Week 2',
                      'Week 3'
                    ]; // Update with actual periods
                    final index = value.toInt();
                    if (index < periods.length) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          periods[index],
                          style: const TextStyle(
                              color: Colors.black, fontSize: 12),
                        ),
                      );
                    } else {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: const Text(''),
                      );
                    }
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
                        value.toInt() != 0 ? '${value.toInt()}' : '',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(
              show: false,
            ),
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: 6000,
                    color: Colors.green,
                    width: 30,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: -3000,
                    color: Colors.red,
                    width: 30,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ],
              ),
              BarChartGroupData(
                x: 2,
                barRods: [
                  BarChartRodData(
                    toY: 5000,
                    color: Colors.green,
                    width: 30,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ],
              ),
            ],
            gridData: FlGridData(show: false),
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryCostChart() {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final quarters = [
                  'Q1',
                  'Q2',
                  'Q3',
                  'Q4'
                ]; // Update with actual quarters
                if (value.toInt() < quarters.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      quarters[value.toInt()],
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  );
                } else {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: const Text(''),
                  );
                }
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
                    value.toInt() > 0 ? '${value.toInt()}' : '',
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 2000),
              FlSpot(1, 3500),
              FlSpot(2, 4000),
              FlSpot(3, 5000),
            ],
            isCurved: false,
            barWidth: 5,
            color: Colors.purple,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        gridData: FlGridData(show: false),
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
