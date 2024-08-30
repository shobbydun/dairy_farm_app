import 'package:dairy_harbor/services_functions/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

class FeedsPage extends StatefulWidget {
  const FeedsPage({super.key});

  @override
  _FeedsPageState createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late FirestoreServices _firestoreServices;
  List<Map<String, dynamic>> _feeds = [];

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _firestoreServices = FirestoreServices(userId);
    _fetchFeeds();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchFeeds() async {
    try {
      final feeds = await _firestoreServices.getFeeds();
      if (mounted) {
        setState(() {
          _feeds = feeds;
        });
      }
    } catch (e) {
      print('Error fetching feeds: $e');
    }
  }

  List<Map<String, dynamic>> _filteredFeeds() {
    return _feeds.where((feed) {
      final nameMatches =
          (feed['name'] as String).toLowerCase().contains(_searchQuery);
      return nameMatches;
    }).toList();
  }

  Future<void> _showFeedDialog(
      {Map<String, dynamic>? feed, bool isEditing = false}) async {
    final nameController = TextEditingController(text: feed?['name'] ?? '');
    final supplierController =
        TextEditingController(text: feed?['supplier'] ?? '');
    final quantityController =
        TextEditingController(text: feed?['quantity'] ?? '');
    final dateController = TextEditingController(text: feed?['date'] ?? '');

    final action = isEditing ? 'Update' : 'Add';

    Future<void> _selectDate(BuildContext context) async {
      DateTime initialDate = DateTime.now();
      if (dateController.text.isNotEmpty) {
        try {
          initialDate = DateFormat('yyyy-MM-dd').parse(dateController.text);
        } catch (_) {}
      }

      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (pickedDate != null && pickedDate != initialDate) {
        final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
        setState(() {
          dateController.text = formattedDate;
        });
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$action Feed'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Feed Name'),
                ),
                TextField(
                  controller: supplierController,
                  decoration: InputDecoration(labelText: 'Supplier'),
                ),
                TextField(
                  controller: quantityController,
                  decoration: InputDecoration(labelText: 'Quantity'),
                ),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  readOnly: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text;
                final supplier = supplierController.text;
                final quantity = quantityController.text;
                final date = dateController.text;

                if (isEditing && feed != null) {
                  await _firestoreServices.updateFeed(feed['id'], {
                    'name': name,
                    'supplier': supplier,
                    'quantity': quantity,
                    'date': date,
                  });
                } else {
                  await _firestoreServices.addFeed(
                      name, supplier, quantity, date);
                }

                Navigator.of(context).pop();
                if (mounted) {
                  _fetchFeeds();
                }
              },
              child: Text(action),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Feeds",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showFeedDialog(isEditing: false);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            _buildSearchBar(),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                'Feed Overview:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10,),
            Container(
              height: 320,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage('assets/ttech.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
            // List of feeds
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: _filteredFeeds().map((feed) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(feed['name']!),
                      subtitle: Text(
                          'Supplier: ${feed['supplier']}\nQuantity: ${feed['quantity']}\nDate: ${feed['date']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _showFeedDialog(feed: feed, isEditing: true);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Delete Feed'),
                                    content: Text('Are you sure you want to delete this feed?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirm) {
                                await _firestoreServices.deleteFeed(feed['id']);
                                if (mounted) {
                                  _fetchFeeds();
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // method search bar
  Widget _buildSearchBar() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.lightBlueAccent.withOpacity(0.8),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (query) {
          setState(() {
            _searchQuery = query.toLowerCase();
          });
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search Feed',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }
}
