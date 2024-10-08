import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CattleForm extends StatefulWidget {
  final Future<String?> adminEmailFuture;

  const CattleForm({Key? key, required this.adminEmailFuture})
      : super(key: key);

  @override
  _CattleFormState createState() => _CattleFormState();
}

class _CattleFormState extends State<CattleForm> {
  File? _image;
  DateTime? _selectedDate;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  
  String? _selectedGender;
  String? _selectedBreed;
  String? _selectedFatherBreed;
  String? _selectedMotherBreed;
  String? _selectedMethodBred;
  String? _selectedStatus;

  final List<String> breeds = ['Holstein', 'Jersey', 'Guernsey', 'Ayrshire', 'Brown Swiss', 'Milking Shorthorn', 'Normande', 'Piedmontese'];
  final List<String> methods = ['Natural', 'Artificial Insemination'];
  final List<String> statuses = ['Healthy', 'Sick', 'Sold', 'Deceased'];
  final List<String> genders = ['Male', 'Female'];

  bool _isLoading = false;
  String? _adminEmail;

  @override
  void initState() {
    super.initState();
    _fetchAdminEmail();
  }

  Future<void> _fetchAdminEmail() async {
    _adminEmail = await widget.adminEmailFuture;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (mounted) {
          setState(() {
            _image = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _uploadImageAndSaveData() async {
    if (_adminEmail == null) {
      print('Admin email is not available');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl;
      if (_image != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('cattle_images')
            .child('${DateTime.now().toIso8601String()}.jpg');
        await ref.putFile(_image!);
        imageUrl = await ref.getDownloadURL();
      }

      String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';

      await FirebaseFirestore.instance
          .collection('cattle')
          .doc(_adminEmail)
          .collection('entries')
          .add({
        'admin_email': _adminEmail,
        'name': _nameController.text,
        'dob': _dobController.text,
        'gender': _selectedGender,
        'breed': _selectedBreed,
        'father_breed': _selectedFatherBreed,
        'mother_breed': _selectedMotherBreed,
        'method_bred': _selectedMethodBred,
        'status': _selectedStatus,
        'image_url': imageUrl,
        'created_at': Timestamp.fromDate(DateTime.now()),
        'filled_in_by': currentUserEmail,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cattle record added successfully!')),
        );
      }

      _clearForm();
      Navigator.pushNamed(context, '/cattleListPage');
    } catch (e) {
      print('Error saving data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add cattle record: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    setState(() {
      _image = null;
      _dobController.clear();
      _nameController.clear();
      _selectedGender = null;
      _selectedBreed = null;
      _selectedFatherBreed = null;
      _selectedMotherBreed = null;
      _selectedMethodBred = null;
      _selectedStatus = null;
    });
  }

  Widget _buildImageDisplay() {
    return _image == null
        ? const Text('No image selected.')
        : Image.file(_image!, height: 200, width: 200, fit: BoxFit.cover);
  }

  @override
  void dispose() {
    _dobController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register New Cattle'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Center(
            child: Card(
              elevation: 10,
              margin: const EdgeInsets.all(20.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Register New Cattle',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildImageUploadButton(),
                      const SizedBox(height: 20),
                      _buildImageDisplay(),
                      const SizedBox(height: 20),
                      _buildTextField('Cow\'s Name', _nameController, Icons.pets),
                      _buildDatePickerField(),
                      _buildDropdown('Gender', genders, (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      }),
                      _buildDropdown('Breed', breeds, (value) {
                        setState(() {
                          _selectedBreed = value;
                        });
                      }),
                      _buildDropdown('Father\'s Breed', breeds, (value) {
                        setState(() {
                          _selectedFatherBreed = value;
                        });
                      }),
                      _buildDropdown('Mother\'s Breed', breeds, (value) {
                        setState(() {
                          _selectedMotherBreed = value;
                        });
                      }),
                      _buildDropdown('Method Bred', methods, (value) {
                        setState(() {
                          _selectedMethodBred = value;
                        });
                      }),
                      _buildDropdown('Status', statuses, (value) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      }),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _uploadImageAndSaveData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14.0, horizontal: 32.0),
                            textStyle: const TextStyle(fontSize: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.green,
                                  ),
                                )
                              : const Text(
                                  'Add Record',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageUploadButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _pickImage,
        icon: const Icon(
          Icons.photo_camera,
          size: 24,
          color: Colors.white,
        ),
        label: const Text(
          'Upload Photo',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
          textStyle: const TextStyle(fontSize: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        value: null,
        onChanged: onChanged,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: _dobController,
        readOnly: true,
        onTap: () => _selectDate(context),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.blue),
          labelText: 'Date of Birth',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade700, width: 2.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue.shade700),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade700, width: 2.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }
}
