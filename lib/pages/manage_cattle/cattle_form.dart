import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // For date formatting

class CattleForm extends StatefulWidget {
  const CattleForm({super.key});

  @override
  _CattleFormState createState() => _CattleFormState();
}

class _CattleFormState extends State<CattleForm> {
  File? _image;
  DateTime? _selectedDate;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _dobController = TextEditingController();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      // Optionally, show a user-friendly message
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

  Widget _buildImageDisplay() {
    return _image == null
      ? const Text('No image selected.')
      : Image.file(_image!, height: 200, width: 200, fit: BoxFit.cover);
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
      body: Center(
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
                  _buildTextField('Cow\'s Name', Icons.pets),
                  _buildDatePickerField(),
                  _buildTextField('Gender', Icons.person),
                  _buildTextField('Breed', Icons.tag),
                  _buildTextField('Father\'s Breed', Icons.family_restroom),
                  _buildTextField('Mother\'s Breed', Icons.family_restroom),
                  _buildTextField('Method Bred', Icons.science),
                  _buildTextField('Status', Icons.health_and_safety),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Add logic to save cattle record
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 32.0),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text('Add Record'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _pickImage,
        icon: const Icon(Icons.photo_camera, size: 24),
        label: const Text('Upload Photo'),
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

  Widget _buildTextField(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue.shade700),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        ),
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: _dobController,
        readOnly: true,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.calendar_today, color: Colors.blue.shade700),
          labelText: 'Date of Birth',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        ),
        onTap: () => _selectDate(context),
      ),
    );
  }
}
