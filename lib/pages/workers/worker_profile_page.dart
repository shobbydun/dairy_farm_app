import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dairy_harbor/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkerProfilePage extends StatefulWidget {
  final String workerId;
  final Future<String?> adminEmailFuture;

  WorkerProfilePage({required this.workerId, required this.adminEmailFuture});

  @override
  _WorkerProfilePageState createState() => _WorkerProfilePageState();
}

class _WorkerProfilePageState extends State<WorkerProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DocumentSnapshot? worker;
  String? adminEmail;

  @override
  void initState() {
    super.initState();
    _fetchAdminEmail();
  }

  Future<void> _fetchAdminEmail() async {
    adminEmail = await widget.adminEmailFuture;
    await _fetchWorker();
  }

  Future<void> _fetchWorker() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      worker = await _firestore
          .collection('workers')
          .doc(adminEmail)
          .collection('entries')
          .doc(widget.workerId)
          .get();

      if (!worker!.exists) {
        _showError('Worker not found.');
        return;
      }

      if (worker?['userId'] == userId) {
        setState(() {});
      } else {
        _showUnauthorizedAccess();
      }
    } catch (error) {
      _showError(error.toString());
    }
  }

  void _showUnauthorizedAccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unauthorized access!')),
    );
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _deleteWorker() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this worker?'),
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

    if (confirmed == true) {
      try {
        await _firestore
            .collection('workers')
            .doc(adminEmail)
            .collection('entries')
            .doc(widget.workerId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Worker deleted successfully!')),
        );

        Navigator.pop(context);
      } catch (error) {
        _showError('Error deleting worker: ${error.toString()}');
      }
    }
  }

  Future<void> _editWorker() async {
    Future<String?> _adminEmailFuture = getAdminEmailFromFirestore();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditWorkerPage(
          workerId: widget.workerId,
          onWorkerUpdated: _fetchWorker,
          adminEmailFuture: _adminEmailFuture,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (worker == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Loading...')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(worker!['name']),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteWorker,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(worker!['photoUrl']),
                      ),
                      SizedBox(height: 20),
                      Text(
                        worker!['name'],
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Email: ${worker!['emailAddress']}',
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Phone: ${worker!['phoneNumber']}',
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Address: ${worker!['address']}',
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Role: ${worker!['role']}',
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _editWorker,
                        child:
                            Text('Edit Worker', style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 16), // Space between card and right section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4.0,
                        spreadRadius: 1.0,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(top: 20),
                  // child: Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Text(
                  //       'Statistics',
                  //       style: TextStyle(
                  //           fontSize: 20, fontWeight: FontWeight.bold),
                  //     ),
                  //     SizedBox(height: 10),
                  //     // Dummy Data
                  //     Text('Total Hours Worked: 150',
                  //         style: TextStyle(fontSize: 16)),
                  //     Text('Projects Completed: 10',
                  //         style: TextStyle(fontSize: 16)),
                  //     Text('Client Rating: 4.5/5',
                  //         style: TextStyle(fontSize: 16)),
                  //   ],
                  // ),
                ),
                SizedBox(height: 20), // Space between sections
                // Contact Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4.0,
                        spreadRadius: 1.0,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final phoneNumber = worker!['phoneNumber'];
                          final url = 'tel:$phoneNumber';
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            _showError('Could not launch phone call.');
                          }
                        },
                        icon: Icon(Icons.phone),
                        label: Text('Call'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final email = worker!['emailAddress'];
                          final url = 'mailto:$email';
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            _showError('Could not launch email client.');
                          }
                        },
                        icon: Icon(Icons.email),
                        label: Text('Email'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditWorkerPage extends StatefulWidget {
  final String workerId;
  final Future<void> Function() onWorkerUpdated;
  final Future<String?> adminEmailFuture;

  EditWorkerPage(
      {required this.workerId,
      required this.onWorkerUpdated,
      required this.adminEmailFuture});

  @override
  _EditWorkerPageState createState() => _EditWorkerPageState();
}

class _EditWorkerPageState extends State<EditWorkerPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  File? _image;
  final _formKey = GlobalKey<FormState>();
  String? name, email, phone, address, role;
  DocumentSnapshot? worker;
  String? adminEmail;

  @override
  void initState() {
    super.initState();
    _fetchAdminEmail();
  }

  Future<void> _fetchAdminEmail() async {
    adminEmail = await widget.adminEmailFuture;
    await _fetchWorker();
  }

  Future<void> _fetchWorker() async {
    try {
      worker = await _firestore
          .collection('workers')
          .doc(adminEmail)
          .collection('entries')
          .doc(widget.workerId)
          .get();

      if (worker!.exists) {
        if (worker!['userId'] == FirebaseAuth.instance.currentUser!.uid) {
          setState(() {
            name = worker!['name'];
            email = worker!['emailAddress'];
            phone = worker!['phoneNumber'];
            address = worker!['address'];
            role = worker!['role'];
          });
        } else {
          _showUnauthorizedAccess();
        }
      } else {
        _showError('Worker not found.');
      }
    } catch (error) {
      _showError(error.toString());
    }
  }

  void _showUnauthorizedAccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unauthorized access!')),
    );
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

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
    return worker!['photoUrl'];
  }

  Future<void> _updateWorker() async {
    if (_formKey.currentState!.validate()) {
      String? photoUrl = await _uploadImage();

      await _firestore
          .collection('workers')
          .doc(adminEmail)
          .collection('entries')
          .doc(widget.workerId)
          .update({
        'name': name,
        'emailAddress': email,
        'phoneNumber': phone,
        'address': address,
        'role': role,
        'photoUrl': photoUrl,
      });

      await widget.onWorkerUpdated();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (worker == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Loading...'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Employee'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        // Make the page scrollable
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : NetworkImage(worker!['photoUrl']),
                  child: _image == null
                      ? Icon(Icons.add_a_photo, size: 30, color: Colors.grey)
                      : null,
                ),
              ),
              SizedBox(height: 20),
              _buildTextFormField('Name', name, (value) => name = value),
              SizedBox(height: 10),
              _buildTextFormField('Email', email, (value) => email = value),
              SizedBox(height: 10),
              _buildTextFormField(
                  'Phone Number', phone, (value) => phone = value),
              SizedBox(height: 10),
              _buildTextFormField(
                  'Address', address, (value) => address = value),
              SizedBox(height: 10),
              _buildTextFormField('Role', role, (value) => role = value),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateWorker,
                child: Text('Update Employee'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
      String label, String? initialValue, ValueChanged<String> onChanged) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      onChanged: onChanged,
      validator: (value) => value!.isEmpty ? 'Please enter a $label' : null,
    );
  }
}
