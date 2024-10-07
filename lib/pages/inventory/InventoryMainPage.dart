import 'package:dairy_harbor/services_functions/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class InventoryMainPage extends StatefulWidget {
  final Future<String?> adminEmailFuture;
  InventoryMainPage({super.key, required this.adminEmailFuture});

  @override
  State<InventoryMainPage> createState() => _InventoryMainPageState();
}

class _InventoryMainPageState extends State<InventoryMainPage> {
  String? _adminEmail;
  bool isLoading = true;
  List<FlSpot> chartData = [];

  @override
  void initState() {
    super.initState();
    _fetchAdminEmail().then((_) {});
  }

  Future<double> _fetchTotalWages() async {
    final firestoreService =
        Provider.of<FirestoreServices>(context, listen: false);
    return await firestoreService.getTotalWages();
  }

  Future<void> _fetchAdminEmail() async {
    _adminEmail = await widget.adminEmailFuture;
    print('Admin Email: $_adminEmail');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return ChangeNotifierProvider<FirestoreServices>(
      create: (context) =>
          FirestoreServices(userId, getAdminEmailFromFirestore()),
      child: Consumer<FirestoreServices>(
        builder: (context, firestoreService, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.lightBlueAccent,
              elevation: 0,
            ),
            body: FutureBuilder<Map<String, dynamic>>(
              future: Future.wait([
                firestoreService.getWages(),
                firestoreService.getFeeds(),
                firestoreService.getMachinery(),
                firestoreService.getMedicines('specificMedicineId'),
                firestoreService.getTotalWages(),
              ]).then((results) {
                return {
                  'wages': results[0],
                  'medicine': results[1],
                  'feeds': results[2],
                  'machinery': results[3],
                  'totalWages': results[4],
                };
              }),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!;
                final medicine = data['medicine'];
                final feeds = data['feeds'];
                //final machinery = data['machinery'];
                final totalWages = data['totalWages'] as double;

                final wageCost = totalWages.toStringAsFixed(2);

                final medicineCount = medicine.length.toString();
                final feedStock = feeds.length.toString();
                //final machineryCount =(machinery is List) ? machinery.length.toString() : '0';

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 13),
                        const Text(
                          'Inventory Overview:',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          height: 200,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildStatCard(
                                  'Wages',
                                  'Kshs$wageCost',
                                  Icons.wallet,
                                  () {
                                    Navigator.pushNamed(context, '/adminWages');
                                  },
                                ),
                                _buildStatCard(
                                  'Medicine',
                                  medicineCount,
                                  Icons.medical_information,
                                  () {
                                    Navigator.pushNamed(context, '/medicine');
                                  },
                                ),
                                _buildStatCard(
                                  'Feed Stock',
                                  '$feedStock Bags',
                                  Icons.food_bank,
                                  () {
                                    Navigator.pushNamed(context, '/feeds');
                                  },
                                ),
                                // _buildStatCard(
                                //   'Machinery Status',
                                //   machineryCount,
                                //   Icons.build,
                                //   () {
                                //     Navigator.pushNamed(context, '/machinery');
                                //   },
                                // ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        SizedBox(height: 16),

                        // Navigation buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildNavigationButton(
                              'Feeds Overview',
                              Icons.food_bank,
                              () {
                                Navigator.pushNamed(context, '/feeds');
                              },
                            ),
                            _buildNavigationButton(
                              'Machinery Overview',
                              Icons.build,
                              () {
                                Navigator.pushNamed(context, '/machinery');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Helper method to build a statistic card with navigation
  Widget _buildStatCard(
      String title, String value, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build a navigation button
  Widget _buildNavigationButton(
      String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
