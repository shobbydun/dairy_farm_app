import 'package:dairy_harbor/pages/authentication/login_or_register_page.dart';
import 'package:dairy_harbor/pages/dashboard/home_page.dart';
import 'package:dairy_harbor/services_functions/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  AuthPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for the auth state to be determined, show a loading spinner
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            final User? user = snapshot.data;
            return HomePage(
              barChartData: _createBarChartData(), 
              pieChartData: _createPieChartData(), 
              lineChartData: _createLineChartData(),
              animate: true,
              firestoreServices: FirestoreServices(user!.uid), // Pass the actual user ID
              user: user, 
              userId: user.uid, 
            );
          } else {
            return LoginOrRegisterPage();
          }
        },
      ),
    );
  }

  // Sample data methods. Replace these with actual data fetching if needed
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
}
