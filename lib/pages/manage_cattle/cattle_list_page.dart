import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CattleList extends StatefulWidget {
  final Future<String?> adminEmailFuture;

  const CattleList({super.key, required this.adminEmailFuture});

  @override
  _CattleListState createState() => _CattleListState();
}

class _CattleListState extends State<CattleList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _adminEmail;

  @override
  void initState() {
    super.initState();
    _fetchAdminEmail();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

   Future<void> _fetchAdminEmail() async {
    _adminEmail = await widget.adminEmailFuture;
    if (_adminEmail != null) {
      // Fetch counts after getting the admin email
      await _fetchCounts(); // Add this line to fetch counts
    }
    setState(() {});
  }

  Future<void> _fetchCounts() async {
    if (_adminEmail == null) {
      return; // Early exit if adminEmail is null
    }

    try {
      final cattleSnapshot = await FirebaseFirestore.instance
          .collection('cattle')
          .doc(_adminEmail)
          .collection('entries')
          .get();

      print('Cattle entries fetched: ${cattleSnapshot.docs.length}');
      // Handle the fetched data as needed
    } catch (e) {
      print('Error fetching cattle counts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cattle List'),
        backgroundColor: Colors.blueAccent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or breed',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.white,
                filled: true,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        child: StreamBuilder<QuerySnapshot>(
          stream: _adminEmail != null
              ? FirebaseFirestore.instance
                  .collection('cattle')
                  .doc(_adminEmail) // Use adminEmail as the document ID
                  .collection('entries') // Access the 'entries' sub-collection
                  .orderBy('created_at',
                      descending:
                          true) // Use 'created_at' as per your saving structure
                  .snapshots()
              : Stream
                  .empty(), // Handle case where adminEmail is not yet available
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No cattle records found.'));
            }

            final cattleDocs = snapshot.data!.docs;
            final filteredCattleDocs = cattleDocs.where((doc) {
              final cattleData = doc.data() as Map<String, dynamic>;
              final name = cattleData['name']?.toLowerCase() ?? '';
              final breed = cattleData['breed']?.toLowerCase() ?? '';
              return name.contains(_searchQuery) ||
                  breed.contains(_searchQuery);
            }).toList();

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: filteredCattleDocs.length,
              itemBuilder: (context, index) {
                var cattleData =
                    filteredCattleDocs[index].data() as Map<String, dynamic>;
                var createdAt = cattleData['created_at']
                    as Timestamp?; // Match the saved key
                var timestamp = createdAt != null
                    ? DateFormat('yyyy-MM-dd HH:mm:ss')
                        .format(createdAt.toDate())
                    : 'NA';

                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    leading: CircleAvatar(
                      backgroundImage:
                          cattleData['image_url'] != null // Match the saved key
                              ? NetworkImage(cattleData['image_url'])
                              : null,
                      child: cattleData['image_url'] == null
                          ? const Icon(Icons.pets,
                              size: 40, color: Colors.white)
                          : null,
                      backgroundColor: Colors.grey[400],
                    ),
                    title: Text(
                      cattleData['name'] ?? 'No Name',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Breed: ${cattleData['breed']}\nAdded on: $timestamp',
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing:
                        const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                    onTap: () {
                      String cattleId =
                          filteredCattleDocs[index].id; // Get the cattle ID

                      Navigator.pushNamed(
                        context,
                        '/cattleProfile',
                        arguments: {
                          'cattleId': cattleId,
                          'index': index,
                          'adminEmailFuture': widget.adminEmailFuture,
                        },
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
