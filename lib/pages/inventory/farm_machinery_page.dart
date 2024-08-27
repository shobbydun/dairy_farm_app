import 'package:dairy_harbor/components/inventory_components/add_machinery_page.dart';
import 'package:dairy_harbor/components/inventory_components/edit_machinery_page.dart';
import 'package:dairy_harbor/components/inventory_components/machinery_details_page.dart';
import 'package:flutter/material.dart';
 

class FarmMachineryPage extends StatefulWidget {
  const FarmMachineryPage({super.key});

  @override
  _FarmMachineryPageState createState() => _FarmMachineryPageState();
}

class _FarmMachineryPageState extends State<FarmMachineryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';

  List<Map<String, String>> _machineries = [
    {
      'name': 'Tractor',
      'type': 'Agricultural',
      'condition': 'Good',
      'dateAcquired': '2023-01-01',
    },
    {
      'name': 'Combine Harvester',
      'type': 'Agricultural',
      'condition': 'Excellent',
      'dateAcquired': '2022-06-15',
    },
   
  ];

  List<Map<String, String>> _filteredMachineries() {
    return _machineries.where((machinery) {
      final nameMatches = machinery['name']!.toLowerCase().contains(_searchQuery);
      final typeMatches = _selectedFilter == 'All' || machinery['type'] == _selectedFilter;
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
              );
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
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search Machinery',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedFilter,
                  items: <String>['All', 'Agricultural', 'Construction', 'Others']
                      .map<DropdownMenuItem<String>>((String value) {
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
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: _filteredMachineries().map((machinery) {
                return ListTile(
                  leading: Icon(Icons.category, color: Colors.blueAccent),
                  title: Text(machinery['name']!),
                  subtitle: Text('Type: ${machinery['type']}\nCondition: ${machinery['condition']}\nDate Acquired: ${machinery['dateAcquired']}'),
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
                                machineryName: machinery['name']!,
                                machineryType: machinery['type']!,
                                machineryCondition: machinery['condition']!,
                                dateAcquired: machinery['dateAcquired']!,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditMachineryPage(
                                machineryName: machinery['name']!,
                                machineryType: machinery['type']!,
                                machineryCondition: machinery['condition']!,
                                dateAcquired: machinery['dateAcquired']!,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
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
