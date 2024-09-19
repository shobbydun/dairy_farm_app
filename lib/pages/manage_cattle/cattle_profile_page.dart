import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CattleProfilePage extends StatelessWidget {
  final String cattleId;
  final int index;

  const CattleProfilePage({
    super.key,
    required this.cattleId,
    required this.index,
  });

  Future<void> _deleteCattle(BuildContext context) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content:
            const Text('Are you sure you want to delete this cattle record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        // Delete cattle record from Firestore
        await FirebaseFirestore.instance
            .collection('cattle')
            .doc(cattleId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cattle record deleted successfully!')),
        );

        Navigator.pop(context);
      } catch (e) {
        print('Error deleting cattle: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete cattle record: $e')),
        );
      }
    }
  }

  Future<void> _editCattle(
      BuildContext context, Map<String, dynamic> cattleData) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCattlePage(
          cattleId: cattleId,
          initialData: cattleData,
        ),
      ),
    );
  }

 @override
Widget build(BuildContext context) {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  return Scaffold(
    appBar: AppBar(
      title: const Text('Cattle Profile'),
      backgroundColor: Colors.blueAccent,
    ),
    body: StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('cattle')
          .doc(cattleId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        var data = snapshot.data?.data();
        if (data == null || data is! Map<String, dynamic> || data['userId'] != currentUserId) {
          return Center(child: Text('No data available or unauthorized access'));
        }

        var cattleData = data as Map<String, dynamic>;
        var createdAt = cattleData['createdAt'] as Timestamp?;
        var timestamp = createdAt != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt.toDate())
            : 'NA';

        return Center(
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  cattleData['imageUrl'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image.network(
                            cattleData['imageUrl'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.pets, size: 100),
                  const SizedBox(height: 20),
                  Text(
                    cattleData['name'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'DOB: ${cattleData['dob'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    'Gender: ${cattleData['gender'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    'Breed: ${cattleData['breed'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    'Father Breed: ${cattleData['fatherBreed'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    'Mother Breed: ${cattleData['motherBreed'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    'Method Bred: ${cattleData['methodBred'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    'Status: ${cattleData['status'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    'Added on: $timestamp',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _editCattle(context, cattleData),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text('Edit', style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        onPressed: () => _deleteCattle(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text('Delete', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

}

class EditCattlePage extends StatefulWidget {
  final String cattleId;
  final Map<String, dynamic> initialData;

  const EditCattlePage({
    super.key,
    required this.cattleId,
    required this.initialData,
  });

  @override
  _EditCattlePageState createState() => _EditCattlePageState();
}

class _EditCattlePageState extends State<EditCattlePage> {
  File? _image;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  late final TextEditingController _nameController;
  late final TextEditingController _dobController;
  late final TextEditingController _genderController;
  late final TextEditingController _breedController;
  late final TextEditingController _fatherBreedController;
  late final TextEditingController _motherBreedController;
  late final TextEditingController _methodBredController;
  late final TextEditingController _statusController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData['name']);
    _dobController = TextEditingController(text: widget.initialData['dob']);
    _genderController = TextEditingController(text: widget.initialData['gender']);
    _breedController = TextEditingController(text: widget.initialData['breed']);
    _fatherBreedController = TextEditingController(text: widget.initialData['fatherBreed']);
    _motherBreedController = TextEditingController(text: widget.initialData['motherBreed']);
    _methodBredController = TextEditingController(text: widget.initialData['methodBred']);
    _statusController = TextEditingController(text: widget.initialData['status']);
  }

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
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null &&
        pickedDate != DateTime.tryParse(_dobController.text)) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _uploadImageAndSaveData() async {
    setState(() {
      _isLoading = true;
    });

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    try {
      String? imageUrl;
      if (_image != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('cattle_images')
            .child('${DateTime.now().toIso8601String()}.jpg');
        await ref.putFile(_image!);
        imageUrl = await ref.getDownloadURL();
      } else {
        imageUrl = widget.initialData['imageUrl'];
      }

      await FirebaseFirestore.instance
          .collection('cattle')
          .doc(widget.cattleId)
          .update({
        'name': _nameController.text,
        'dob': _dobController.text,
        'gender': _genderController.text,
        'breed': _breedController.text,
        'fatherBreed': _fatherBreedController.text,
        'motherBreed': _motherBreedController.text,
        'methodBred': _methodBredController.text,
        'status': _statusController.text,
        'imageUrl': imageUrl,
        'updatedAt': Timestamp.now(),
        'userId': currentUserId, // Ensure userId is updated
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cattle record updated successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error updating cattle: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update cattle record: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildImageDisplay() {
    if (_image != null) {
      return Image.file(
        _image!,
        height: 200,
        width: 200,
        fit: BoxFit.cover,
      );
    } else if (widget.initialData['imageUrl'] != null) {
      return Image.network(
        widget.initialData['imageUrl'],
        height: 200,
        width: 200,
        fit: BoxFit.cover,
      );
    } else {
      return const Text('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Cattle'),
        backgroundColor: Colors.blueAccent,
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
                          'Edit Cattle',
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
                      _buildTextField('Gender', _genderController, Icons.person),
                      _buildTextField('Breed', _breedController, Icons.tag),
                      _buildTextField('Father\'s Breed', _fatherBreedController, Icons.family_restroom),
                      _buildTextField('Mother\'s Breed', _motherBreedController, Icons.family_restroom),
                      _buildTextField('Method Bred', _methodBredController, Icons.science),
                      _buildTextField('Status', _statusController, Icons.health_and_safety),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _uploadImageAndSaveData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 32.0),
                            textStyle: const TextStyle(fontSize: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white),
                                )
                              : const Text('Save Changes', style: TextStyle(color: Colors.white)),
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
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildImageUploadButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _pickImage,
        icon: const Icon(Icons.photo_camera, size: 24, color: Colors.white),
        label: const Text('Upload Photo', style: TextStyle(color: Colors.white)),
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

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
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
}
