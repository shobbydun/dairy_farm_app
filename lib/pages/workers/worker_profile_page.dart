import 'package:dairy_harbor/pages/workers/worker_list_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerProfilePage extends StatefulWidget {
  final String workerId;

  WorkerProfilePage({required this.workerId});

  @override
  _WorkerProfilePageState createState() => _WorkerProfilePageState();
}

class _WorkerProfilePageState extends State<WorkerProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late DocumentSnapshot worker;

  @override
  void initState() {
    super.initState();
    _fetchWorker();
  }

  Future<void> _fetchWorker() async {
    worker = await _firestore.collection('workers').doc(widget.workerId).get();
    setState(() {});
  }

  Future<void> _deleteWorker() async {
    await _firestore.collection('workers').doc(widget.workerId).delete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(worker['name']),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteWorker,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(worker['photoUrl']),
            ),
            SizedBox(height: 20),
            Text('Email: ${worker['emailAddress']}'),
            Text('Phone: ${worker['phoneNumber']}'),
            Text('Address: ${worker['address']}'),
            Text('Role: ${worker['role']}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddWorkerPage(),
                  ),
                );
              },
              child: Text('Edit Worker'),
            ),
          ],
        ),
      ),
    );
  }
}
