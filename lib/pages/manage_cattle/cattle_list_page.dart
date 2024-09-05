import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'cattle_profile_page.dart';

class CattleList extends StatefulWidget {
  const CattleList({super.key});

  @override
  _CattleListState createState() => _CattleListState();
}

class _CattleListState extends State<CattleList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
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
          stream: FirebaseFirestore.instance
              .collection('cattle')
              .orderBy('createdAt', descending: true) 
              .snapshots(),
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
              return name.contains(_searchQuery) || breed.contains(_searchQuery);
            }).toList();

            return ListView.builder(
              padding: const EdgeInsets.all(8.0), 
              itemCount: filteredCattleDocs.length,
              itemBuilder: (context, index) {
                var cattleData = filteredCattleDocs[index].data() as Map<String, dynamic>;
                var createdAt = cattleData['createdAt'] as Timestamp?;
                var timestamp = createdAt != null
                    ? DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt.toDate())
                    : 'NA'; 

                return Card(
                  elevation: 5, 
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0), 
                    leading: CircleAvatar(
                      backgroundImage: cattleData['imageUrl'] != null
                          ? NetworkImage(cattleData['imageUrl'])
                          : null,
                      child: cattleData['imageUrl'] == null
                          ? const Icon(Icons.pets, size: 40, color: Colors.white)
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
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue), 
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CattleProfilePage(
                            cattleId: filteredCattleDocs[index].id,
                            index: index,
                          ),
                        ),
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
