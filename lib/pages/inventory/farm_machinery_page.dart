import 'package:dairy_harbor/components/inventory_components/add_machinery_page.dart';
import 'package:dairy_harbor/components/inventory_components/edit_machinery_page.dart';
import 'package:dairy_harbor/components/inventory_components/machinery_details_page.dart';
import 'package:dairy_harbor/main.dart';
import 'package:dairy_harbor/services_functions/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FarmMachineryPage extends StatefulWidget {
  final Future<String?> adminEmailFuture;
  FarmMachineryPage({super.key, required this.adminEmailFuture});

  @override
  _FarmMachineryPageState createState() => _FarmMachineryPageState();
}

class _FarmMachineryPageState extends State<FarmMachineryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  late FirestoreServices _firestoreServices;
  List<Map<String, dynamic>> _machineries = [];
  String? _adminEmail;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final adminEmailFuture =
        getAdminEmailFromFirestore(); // Ensure to get admin email if needed
    _firestoreServices = FirestoreServices(userId, adminEmailFuture);
    _fetchMachineries();
    _fetchAdminEmail();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _fetchAdminEmail() async {
    _adminEmail = await widget.adminEmailFuture;
    print('Admin Email: $_adminEmail');
    _fetchMachineries();
    setState(() {});
  }

  Future<void> _fetchMachineries() async {
    try {
      final machineries = await _firestoreServices.getMachinery();
      setState(() {
        _machineries = machineries;
      });
    } catch (e) {
      print('Error fetching machineries: $e');
    }
  }

  List<Map<String, dynamic>> _filteredMachineries() {
    return _machineries.where((machinery) {
      final nameMatches =
          (machinery['name'] as String).toLowerCase().contains(_searchQuery);
      final typeMatches =
          _selectedFilter == 'All' || machinery['type'] == _selectedFilter;
      return nameMatches && typeMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Farm Machinery'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddMachineryPage()),
              ).then((_) => _fetchMachineries()); // Refresh data after adding
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Machinery',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 150,
                  child: DropdownButtonFormField<String>(
                    value: _selectedFilter,
                    items: <String>[
                      'All',
                      'Agricultural',
                      'Construction',
                      'Others'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFilter = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: _filteredMachineries().map((machinery) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Icon(Icons.category, color: Colors.blueAccent),
                    title: Text(machinery['name']!),
                    subtitle: Text(
                      'Type: ${machinery['type']}\nCondition: ${machinery['condition']}\nDate Acquired: ${machinery['dateAcquired']}\nPurchase Cost: \nKshs ${machinery['buyCost']}\nMaintenance Cost: \nKshs ${machinery['maintenanceCost']}',
                      style: TextStyle(color: Colors.black54),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.info),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MachineryDetailsPage(
                                  machineryId: machinery['id'],
                                  machineryName: machinery['name']!,
                                  machineryType: machinery['type']!,
                                  machineryCondition: machinery['condition']!,
                                  dateAcquired: machinery['dateAcquired']!,
                                  buyCost: machinery['buyCost'],
                                  maintenanceCost: machinery['maintenanceCost'],
                                ),
                              ),
                            ).then((_) =>
                                _fetchMachineries()); // Refresh data after viewing details
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditMachineryPage(
                                  machineryId: machinery['id'],
                                  machineryName: machinery['name']!,
                                  machineryType: machinery['type']!,
                                  machineryCondition: machinery['condition']!,
                                  dateAcquired: machinery['dateAcquired']!,
                                  buyCost: machinery['buyCost'],
                                  maintenanceCost: machinery['maintenanceCost'],
                                ),
                              ),
                            ).then((_) =>
                                _fetchMachineries()); // Refresh data after editing
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
