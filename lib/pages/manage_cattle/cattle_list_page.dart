import 'package:flutter/material.dart';

import 'cattle_profile_page.dart';

class CattleList extends StatelessWidget {
  const CattleList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cattle'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: ListView.builder(
          itemCount: 10, 
          itemBuilder: (context, index) {
            return Card(
              elevation: 8,
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(15.0),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: const AssetImage('assets/profile.jpeg'), 
                  backgroundColor: Colors.blue.shade100,
                ),
                title: Text(
                  'Cattle $index', 
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                subtitle: Text(
                  'Breed: Holstein',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue.shade700,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CattleProfile(index: index)),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
