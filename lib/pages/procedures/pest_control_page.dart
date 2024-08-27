import 'package:dairy_harbor/pages/inventory/notification_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PestControlPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pest Control Management'),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to Notifications Page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // Dashboard Section
              _buildDashboard(),

              // Pest Control Records Section
              _buildRecordSection(
                'Pest Control Records',
                _buildPestControlRecordsList(),
              ),

              // Add New Pest Control Section
              _buildAddNewPestControlSection(context),

              // Help and Support Section
              _buildHelpAndSupportSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return Card(
      color: Colors.lightBlue[50],
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlueAccent,
                  ),
                ),
                Icon(Icons.dashboard, color: Colors.lightBlueAccent, size: 28),
              ],
            ),
            const SizedBox(height: 16.0),

            // Overview Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOverviewCard('Total Pest Controls', 10, Icons.security),
                _buildOverviewCard('Total Expenses', 5000, Icons.attach_money),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOverviewCard('Pest Controls Today', 2, Icons.today),
                _buildOverviewCard(
                    'Pest Controls This Month', 15, Icons.calendar_today),
              ],
            ),

            const SizedBox(height: 16.0),

            // Graphs and Charts
            _buildCharts(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(String title, int value, IconData icon) {
    return Expanded(
      child: Card(
        color: Colors.white,
        elevation: 6.0,
        margin: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.lightBlueAccent),
              const SizedBox(height: 8.0),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4.0),
              Text(
                '$value',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharts() {
    return Column(
      children: [
        Text(
          'Pest Trends',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.lightBlueAccent,
          ),
        ),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barGroups: _createSampleData(),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      const style = TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      );
                      String text;
                      switch (value.toInt()) {
                        case 0:
                          text = 'Jan';
                          break;
                        case 1:
                          text = 'Feb';
                          break;
                        case 2:
                          text = 'Mar';
                          break;
                        default:
                          text = '';
                      }
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(text, style: style),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _createSampleData() {
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: 5,
            color: Colors.blue,
            width: 22,
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: 10,
            color: Colors.blue,
            width: 22,
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: 15,
            color: Colors.blue,
            width: 22,
          ),
        ],
      ),
    ];
  }

  Widget _buildRecordSection(String title, Widget records) {
    return Card(
      color: Colors.white,
      elevation: 6.0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlueAccent,
              ),
            ),
            const SizedBox(height: 16.0),
            records,
          ],
        ),
      ),
    );
  }

  Widget _buildPestControlRecordsList() {
    return Column(
      children: [
        _buildRecordTile(
          'Date: 2024-08-01',
          'Pest Type: Aphid, Treatment: Spraying, Status: Completed',
        ),
        _buildRecordTile(
          'Date: 2024-08-10',
          'Pest Type: Beetle, Treatment: Dipping, Status: Pending',
        ),
      ],
    );
  }

  Widget _buildRecordTile(String date, String details) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
      title: Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(details),
      leading: Icon(Icons.description, color: Colors.lightBlueAccent),
      trailing: Icon(Icons.more_vert, color: Colors.grey),
      onTap: () {
        // Handle record tap
      },
    );
  }

  Widget _buildAddNewPestControlSection(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 6.0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Pest Control',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlueAccent,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Pest Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Treatment',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Handle Save
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpAndSupportSection() {
    return Card(
      color: Colors.white,
      elevation: 6.0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Help & Support',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlueAccent,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'For any issues or support, contact our helpdesk at support@pestcontrol.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
