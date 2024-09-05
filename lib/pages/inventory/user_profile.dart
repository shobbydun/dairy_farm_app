import 'dart:io';

import 'package:dairy_harbor/services_functions/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FirestoreServices>(
      builder: (context, firestoreService, child) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: firestoreService.getProfile(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final profile = snapshot.data;
            final profileImageUrl = profile?['profileImage'] as String?;

            return Scaffold(
              appBar: AppBar(
                title: Text('Dairy Farmer Profile'),
                backgroundColor: Colors.lightBlueAccent,
                elevation: 0,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.lightBlueAccent, Colors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      Navigator.pushNamed(context, '/editProfile');
                    },
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header
                      Row(
                        children: [
                          // Profile Image
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 6,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: profileImageUrl != null
                                  ? NetworkImage(profileImageUrl)
                                  : null,
                              child: profileImageUrl == null
                                  ? Icon(Icons.person, size: 60, color: Colors.white)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile?['fullName'] ?? 'No Name',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                Text(
                                  'Dairy Farmer',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Farm Information
                      _buildSection(
                        title: 'Farm Information',
                        content: [
                          'Farm Name: ${profile?['farmName'] ?? 'N/A'}',
                          'Location: ${profile?['farmLocation'] ?? 'N/A'}',
                          'Farm Size: ${profile?['farmSize'] ?? 'N/A'}',
                          'Number of Cows: ${profile?['numberOfCows'] ?? 'N/A'}',
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Dairy Production
                      _buildSection(
                        title: 'Dairy Production',
                        content: [
                          'Daily Milk Production: ${profile?['dailyMilkProduction'] ?? 'N/A'}',
                          'Milk Sold: ${profile?['milkSold'] ?? 'N/A'}',
                          'Milk Quality: ${profile?['milkQuality'] ?? 'N/A'}',
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Contact Information
                      _buildSection(
                        title: 'Contact Information',
                        content: [
                          'Phone: ${profile?['phone'] ?? 'N/A'}',
                          'Email: ${profile?['email'] ?? 'N/A'}',
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSection({required String title, required List<String> content}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 12),
          ...content.map((line) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              line,
              style: TextStyle(fontSize: 16),
            ),
          )).toList(),
        ],
      ),
    );
  }
}




class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _farmNameController;
  late TextEditingController _farmLocationController;
  late TextEditingController _farmSizeController;
  late TextEditingController _numberOfCowsController;
  late TextEditingController _dailyMilkProductionController;
  late TextEditingController _milkSoldController;
  late TextEditingController _milkQualityController;
  File? _profileImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _farmNameController = TextEditingController();
    _farmLocationController = TextEditingController();
    _farmSizeController = TextEditingController();
    _numberOfCowsController = TextEditingController();
    _dailyMilkProductionController = TextEditingController();
    _milkSoldController = TextEditingController();
    _milkQualityController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final firestoreService = Provider.of<FirestoreServices>(context, listen: false);

    try {
      final profile = await firestoreService.getProfile();
      if (mounted) {
        setState(() {
          _fullNameController.text = profile?['fullName'] ?? '';
          _emailController.text = profile?['email'] ?? '';
          _phoneController.text = profile?['phone'] ?? '';
          _farmNameController.text = profile?['farmName'] ?? '';
          _farmLocationController.text = profile?['farmLocation'] ?? '';
          _farmSizeController.text = profile?['farmSize'] ?? '';
          _numberOfCowsController.text = profile?['numberOfCows'] ?? '';
          _dailyMilkProductionController.text = profile?['dailyMilkProduction'] ?? '';
          _milkSoldController.text = profile?['milkSold'] ?? '';
          _milkQualityController.text = profile?['milkQuality'] ?? '';
        });
      }
    } catch (e) {
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (mounted) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreServices>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(controller: _fullNameController, label: 'Full Name'),
              _buildTextField(controller: _emailController, label: 'Email'),
              _buildTextField(controller: _phoneController, label: 'Phone'),
              _buildTextField(controller: _farmNameController, label: 'Farm Name'),
              _buildTextField(controller: _farmLocationController, label: 'Farm Location'),
              _buildTextField(controller: _farmSizeController, label: 'Farm Size'),
              _buildTextField(controller: _numberOfCowsController, label: 'Number of Cows'),
              _buildTextField(controller: _dailyMilkProductionController, label: 'Daily Milk Production'),
              _buildTextField(controller: _milkSoldController, label: 'Milk Sold'),
              _buildTextField(controller: _milkQualityController, label: 'Milk Quality'),
              const SizedBox(height: 20),
              _profileImage != null
                  ? Image.file(_profileImage!)
                  : Icon(Icons.person, size: 100),
              TextButton(
                onPressed: _pickImage,
                child: Text('Change Profile Image'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : () async {
                  setState(() {
                    _isSaving = true; 
                  });

                  try {
                    final profileData = {
                      'fullName': _fullNameController.text,
                      'email': _emailController.text,
                      'phone': _phoneController.text,
                      'farmName': _farmNameController.text,
                      'farmLocation': _farmLocationController.text,
                      'farmSize': _farmSizeController.text,
                      'numberOfCows': _numberOfCowsController.text,
                      'dailyMilkProduction': _dailyMilkProductionController.text,
                      'milkSold': _milkSoldController.text,
                      'milkQuality': _milkQualityController.text,
                    };
                    await firestoreService.updateProfile(profileData);

                    if (_profileImage != null) {
                      final imageUrl = await firestoreService.uploadProfileImage(_profileImage!);
                      if (imageUrl != null) {
                        await firestoreService.updateProfileImageUrl(imageUrl);
                      }
                    }

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Profile saved successfully!')),
                    );
                    
                    // Go back to the previous page
                    Navigator.pop(context);
                  } catch (e) {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error saving profile: $e')),
                    );
                  } finally {
                    // End saving
                    if (mounted) {
                      setState(() {
                        _isSaving = false;
                      });
                    }
                  }
                },
                child: _isSaving
                    ? CircularProgressIndicator() // Show progress indicator while saving
                    : Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _farmNameController.dispose();
    _farmLocationController.dispose();
    _farmSizeController.dispose();
    _numberOfCowsController.dispose();
    _dailyMilkProductionController.dispose();
    _milkSoldController.dispose();
    _milkQualityController.dispose();
    super.dispose();
  }
}
