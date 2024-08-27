import 'package:flutter/material.dart';

class HeatDetectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heat Detection'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeatDetectionCard(),
              SizedBox(height: 16.0),
              _buildHeatDetectionList(), // Call to _buildHeatDetectionList
            ],
          ),
        ),
      ),
    );
  }

  // Heat Detection Information Card
  Widget _buildHeatDetectionCard() {
    return Card(
      color: Colors.white,
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Image.asset(
                'assets/heat.jpeg',
                height: 350,
                width: double.infinity,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.4),
                colorBlendMode: BlendMode.darken,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'HEAT DETECTION',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Monitor and track heat cycles effectively with our comprehensive tools. Ensure accurate tracking for better management and productivity.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  // Heat Detection List
  Widget _buildHeatDetectionList() {
    return Column(
      children: [
        _buildListTile('Cow #1234 - Detected in Heat', 'Last Detected: 2024-08-25'),
        _buildListTile('Cow #5678 - Detected in Heat', 'Last Detected: 2024-08-23'),
        _buildListTile('Cow #91011 - Not Detected', 'Last Checked: 2024-08-20'),
        // Additional ListTiles can be added here as needed
      ],
    );
  }

  // Helper method to create ListTile with consistent styling
  Widget _buildListTile(String title, String subtitle) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        leading: Icon(Icons.thermostat, color: Colors.blueAccent),
        title: Text(title, style: TextStyle(fontSize: 16)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }
}

