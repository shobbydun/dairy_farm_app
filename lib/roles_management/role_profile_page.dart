import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RoleProfilePage extends StatefulWidget {
  @override
  _RoleProfilePageState createState() => _RoleProfilePageState();
}

class _RoleProfilePageState extends State<RoleProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  String? userEmail;
  String? userId;
  String? farmName;
  String? role;
  String? profilePictureUrl;
  bool isLoading = true;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        setState(() {
          userEmail = userDoc['email'];
          farmName = userDoc['farmName'];
          role = userDoc['role'];
          _usernameController.text = userDoc['username'] ?? '';
          profilePictureUrl = userDoc['profilePictureUrl'];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateUsername() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'username': _usernameController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Username updated successfully!')));
      fetchUserData();
    } catch (e) {
      print("Error updating username: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating username: $e')));
    }
  }

  Future<void> _updateProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Here, upload the image to your server or Firebase Storage.
      String imageUrl = 'url_of_the_uploaded_image'; // Replace with actual URL after uploading.

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'profilePictureUrl': imageUrl,
      });
      setState(() {
        profilePictureUrl = imageUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile picture updated successfully!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          backgroundColor: Colors.blueAccent,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                if (isEditing) {
                  _updateUsername();
                }
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: profilePictureUrl != null && profilePictureUrl!.isNotEmpty
                              ? NetworkImage(profilePictureUrl!)
                              : null,
                          backgroundColor: Colors.grey[300],
                          child: profilePictureUrl == null || profilePictureUrl!.isEmpty
                              ? Icon(Icons.person, size: 60, color: Colors.white)
                              : null,
                        ),
                        SizedBox(height: 20),
                        Text(userEmail ?? '', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text('Farm Name: ${farmName ?? 'N/A'}', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 10),
                        Text('Role: ${role ?? 'N/A'}', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 20),
                        Text('Username:', style: TextStyle(fontSize: 18)),
                        if (isEditing)
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey[200],
                              hintText: 'Enter your username',
                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            ),
                          )
                        else
                          Text(
                            _usernameController.text.isNotEmpty ? _usernameController.text : ' ',
                            style: TextStyle(fontSize: 18),
                          ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: isEditing ? _updateProfilePicture : null,
                          child: Text('Update Profile Picture'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            backgroundColor: isEditing ? Colors.blueAccent : Colors.grey,
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
