import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dairy_harbor/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'worker_profile_page.dart';

class WorkerListPage extends StatefulWidget {
  final Future<String?> adminEmailFuture;

  WorkerListPage({super.key, required this.adminEmailFuture});

  @override
  _WorkerListPageState createState() => _WorkerListPageState();
}

class _WorkerListPageState extends State<WorkerListPage> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  String? _adminEmail;

  @override
  void initState() {
    super.initState();
    _fetchAdminEmail();
  }

  Future<void> _fetchAdminEmail() async {
    _adminEmail = await widget.adminEmailFuture;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Employees'),
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _adminEmail == null
            ? null
            : FirebaseFirestore.instance
                .collection('workers')
                .doc(_adminEmail)
                .collection('entries')
                .where('userId', isEqualTo: userId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final workers = snapshot.data?.docs ?? [];
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 10),
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final worker = workers[index];
              return Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundImage: worker['photoUrl'] != null &&
                            worker['photoUrl'].isNotEmpty
                        ? NetworkImage(worker['photoUrl'])
                        : null, // No background image when using an icon
                    child: worker['photoUrl'] == null ||
                            worker['photoUrl'].isEmpty
                        ? Icon(Icons.person,
                            size:
                                40) // Default icon when photoUrl is not available
                        : null, // No icon if photoUrl is present
                  ),
                  title: Text(
                    worker['name'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    '${worker['role']} - ${worker['phoneNumber']}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  onTap: () {
                    Future<String?> adminEmailFuture =
                        getAdminEmailFromFirestore(); // Your method to fetch admin email

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkerProfilePage(
                          workerId: worker.id,
                          adminEmailFuture: adminEmailFuture,
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
      floatingActionButton: _adminEmail == null
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddWorkerPage(adminEmail: _adminEmail!),
                  ),
                );
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.lightBlueAccent,
            ),
    );
  }
}

class AddWorkerPage extends StatefulWidget {
  final String adminEmail;
  //final Future<String?> adminEmailFuture;
  AddWorkerPage({super.key, required this.adminEmail});
  @override
  _AddWorkerPageState createState() => _AddWorkerPageState();
}

class _AddWorkerPageState extends State<AddWorkerPage> {
  //final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  File? _image;
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String emailAddress = '';
  String phoneNumber = '';
  String address = '';
  String role = '';
  bool _isLoading = false;
  String? _successMessage;
  String? _adminEmail;

  @override
  void initState() {
    super.initState();
    _adminEmail = widget.adminEmail; // Assign it here
  }

  // Future<void> _fetchAdminEmail() async {
  //   _adminEmail = await widget.adminEmailFuture;
  //   setState(() {});
  // }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_image != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('worker_photos/${DateTime.now().toString()}');
      await ref.putFile(_image!);
      return await ref.getDownloadURL();
    }
    return null;
  }

  Future<void> _saveWorker() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _successMessage = null; // Reset success message
      });

      final photoUrl = await _uploadImage();
      final userId = FirebaseAuth.instance.currentUser!.uid;

      if (_adminEmail != null) {
        await FirebaseFirestore.instance
            .collection('workers') // Adjust collection name as necessary
            .doc(_adminEmail) // Use the admin's document
            .collection('entries') // Adjust collection name as necessary
            .add({
          'name': name,
          'emailAddress': emailAddress,
          'phoneNumber': phoneNumber,
          'address': address,
          'role': role,
          'photoUrl': photoUrl ?? '',
          'userId': userId,
        });

        if (mounted) {
          setState(() {
            _isLoading = false;
            _successMessage = 'Employee saved successfully!';
          });
          Navigator.pop(context);
        }
      }
    }
  }

  Future<void> _updateWorker(String docId) async {
    if (_adminEmail != null) {
      await FirebaseFirestore.instance
          .collection('workers') // Adjust collection name as necessary
          .doc(_adminEmail)
          .collection('entries') // Adjust collection name as necessary
          .doc(docId)
          .update({
        'name': name,
        'emailAddress': emailAddress,
        'phoneNumber': phoneNumber,
        'address': address,
        'role': role,
        'photoUrl': await _uploadImage() ?? '',
      });
    }
  }

  Future<void> _deleteWorker(String docId) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this worker?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('workers') // Adjust collection name as necessary
          .doc(_adminEmail)
          .collection('entries') // Adjust collection name as necessary
          .doc(docId)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Employees'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            _image != null ? FileImage(_image!) : null,
                        child: _image == null
                            ? Icon(Icons.add_a_photo,
                                size: 30, color: Colors.grey)
                            : null,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onChanged: (value) => name = value,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter name' : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onChanged: (value) => emailAddress = value,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter email' : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onChanged: (value) => phoneNumber = value,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter phone number' : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onChanged: (value) => address = value,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter address' : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onChanged: (value) => role = value,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter role' : null,
                    ),
                    SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _saveWorker,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text('Save Employee'),
                          ),
                    if (_successMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text(
                          _successMessage!,
                          style: TextStyle(color: Colors.green, fontSize: 16),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
