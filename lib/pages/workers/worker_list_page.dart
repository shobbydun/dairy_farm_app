import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'worker_profile_page.dart';

class WorkerListPage extends StatefulWidget {
  @override
  _WorkerListPageState createState() => _WorkerListPageState();
}

class _WorkerListPageState extends State<WorkerListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = 'USER_ID'; // Replace with the authenticated user's ID.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Employees')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('workers').where('userId', isEqualTo: userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final workers = snapshot.data?.docs ?? [];
          return ListView.builder(
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final worker = workers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(worker['photoUrl']),
                ),
                title: Text(worker['name']),
                subtitle: Text('${worker['role']} - ${worker['phoneNumber']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkerProfilePage(workerId: worker.id), // Correctly passing workerId
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddWorkerPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}


class AddWorkerPage extends StatefulWidget {
  @override
  _AddWorkerPageState createState() => _AddWorkerPageState();
}

class _AddWorkerPageState extends State<AddWorkerPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  File? _image;
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String emailAddress = '';
  String phoneNumber = '';
  String address = '';
  String role = '';

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
      return await ref.getDownloadURL(); // Now returns a String
    }
    return null; // Return null if there's no image
  }

  Future<void> _saveWorker() async {
    if (_formKey.currentState!.validate()) {
      final photoUrl = await _uploadImage();
      await _firestore.collection('workers').add({
        'name': name,
        'emailAddress': emailAddress,
        'phoneNumber': phoneNumber,
        'address': address,
        'role': role,
        'photoUrl':
            photoUrl ?? '', // Default to empty string if photoUrl is null
        'userId': 'USER_ID', // Replace with the authenticated user's ID.
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Employee')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null ? Icon(Icons.add_a_photo) : null,
                ),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) => name = value,
                validator: (value) => value!.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email Address'),
                onChanged: (value) => emailAddress = value,
                validator: (value) => value!.isEmpty ? 'Enter email' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                onChanged: (value) => phoneNumber = value,
                validator: (value) =>
                    value!.isEmpty ? 'Enter phone number' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Address'),
                onChanged: (value) => address = value,
                validator: (value) => value!.isEmpty ? 'Enter address' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Role'),
                onChanged: (value) => role = value,
                validator: (value) => value!.isEmpty ? 'Enter role' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveWorker,
                child: Text('Save Worker'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
