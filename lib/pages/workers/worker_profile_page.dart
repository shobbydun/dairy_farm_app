import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class WorkerProfilePage extends StatefulWidget {
  final String workerId;

  WorkerProfilePage({required this.workerId});

  @override
  _WorkerProfilePageState createState() => _WorkerProfilePageState();
}

class _WorkerProfilePageState extends State<WorkerProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DocumentSnapshot? worker;

  @override
  void initState() {
    super.initState();
    _fetchWorker();
  }

  Future<void> _fetchWorker() async {
    worker = await _firestore.collection('workers').doc(widget.workerId).get();
    if (worker!['userId'] == FirebaseAuth.instance.currentUser!.uid) {
      setState(() {});
    } else {
      Navigator.pop(context); // Handle unauthorized access
    }
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
      await _firestore.collection('workers').doc(widget.workerId).delete();
      Navigator.pop(context);
    }
  }

  Future<void> _editWorker() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditWorkerPage(
          workerId: widget.workerId,
          onWorkerUpdated: _fetchWorker, // Pass the callback
        ),
      ),
    );
    // Refresh worker data after returning
    await _fetchWorker();
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
        title: Text(worker!['name']),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteWorker,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(worker!['photoUrl']),
              ),
              SizedBox(height: 20),
              Text('Email: ${worker!['emailAddress']}', style: TextStyle(fontSize: 20)),
              Text('Phone: ${worker!['phoneNumber']}', style: TextStyle(fontSize: 20)),
              Text('Address: ${worker!['address']}', style: TextStyle(fontSize: 20)),
              Text('Role: ${worker!['role']}', style: TextStyle(fontSize: 20)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _editWorker,
                child: Text('Edit Worker'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class EditWorkerPage extends StatefulWidget {
  final String workerId;
  final Future<void> Function() onWorkerUpdated; // Add the callback

  EditWorkerPage({required this.workerId, required this.onWorkerUpdated}); // Modify constructor

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

  @override
  void initState() {
    super.initState();
    _fetchWorker();
  }

  Future<void> _fetchWorker() async {
    worker = await _firestore.collection('workers').doc(widget.workerId).get();
    if (worker!['userId'] == FirebaseAuth.instance.currentUser!.uid) {
      setState(() {
        name = worker!['name'];
        email = worker!['emailAddress'];
        phone = worker!['phoneNumber'];
        address = worker!['address'];
        role = worker!['role'];
      });
    } else {
      Navigator.pop(context); // Handle unauthorized access
    }
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
    return null; // Return null if no new image was picked
  }

  Future<void> _updateWorker() async {
    if (_formKey.currentState!.validate()) {
      String? photoUrl = await _uploadImage(); // Upload the new image if it exists

      await _firestore.collection('workers').doc(widget.workerId).update({
        'name': name,
        'emailAddress': email,
        'phoneNumber': phone,
        'address': address,
        'role': role,
        'photoUrl': photoUrl ?? worker!['photoUrl'],
      });

      await widget.onWorkerUpdated(); // Call the update callback
      Navigator.pop(context);
    }
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
      appBar: AppBar(title: Text('Edit Employee')),
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
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : NetworkImage(worker!['photoUrl']),
                  child: _image == null
                      ? Icon(Icons.add_a_photo, size: 30, color: Colors.grey)
                      : null,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) => name = value,
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                initialValue: email,
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (value) => email = value,
                validator: (value) => value!.isEmpty ? 'Please enter an email' : null,
              ),
              TextFormField(
                initialValue: phone,
                decoration: InputDecoration(labelText: 'Phone Number'),
                onChanged: (value) => phone = value,
                validator: (value) => value!.isEmpty ? 'Please enter a phone number' : null,
              ),
              TextFormField(
                initialValue: address,
                decoration: InputDecoration(labelText: 'Address'),
                onChanged: (value) => address = value,
                validator: (value) => value!.isEmpty ? 'Please enter an address' : null,
              ),
              TextFormField(
                initialValue: role,
                decoration: InputDecoration(labelText: 'Role'),
                onChanged: (value) => role = value,
                validator: (value) => value!.isEmpty ? 'Please enter a role' : null,
              ),
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
}