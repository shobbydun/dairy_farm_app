import 'package:dairy_harbor/services_functions/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditMachineryPage extends StatefulWidget {
  final String machineryId;
  final String machineryName;
  final String machineryType;
  final String machineryCondition;
  final String dateAcquired;

  const EditMachineryPage({
    super.key,
    required this.machineryId,
    required this.machineryName,
    required this.machineryType,
    required this.machineryCondition,
    required this.dateAcquired,
  });

  @override
  _EditMachineryPageState createState() => _EditMachineryPageState();
}

class _EditMachineryPageState extends State<EditMachineryPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _conditionController;
  late TextEditingController _dateController;

  String _selectedType = 'Agricultural'; 

  late FirestoreServices _firestoreServices;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _firestoreServices = FirestoreServices(userId);

    _nameController = TextEditingController(text: widget.machineryName);
    _selectedType = widget.machineryType;
    _conditionController = TextEditingController(text: widget.machineryCondition);
    _dateController = TextEditingController(text: widget.dateAcquired);
  }

  Future<void> _updateMachinery() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await _firestoreServices.updateMachinery(
          widget.machineryId,
          {
            'name': _nameController.text,
            'type': _selectedType, 
            'condition': _conditionController.text,
            'dateAcquired': _dateController.text,
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Machinery details updated')),
        );
        Navigator.pop(context);
      } catch (e) {
        print('Error updating machinery: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating machinery')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _conditionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Machinery'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _nameController,
                labelText: 'Name',
                hintText: 'Enter machinery name',
                icon: Icons.build,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the machinery name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                labelText: 'Type',
                value: _selectedType,
                items: <String>['Agricultural', 'Construction', 'Others'],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _conditionController,
                labelText: 'Condition',
                hintText: 'Enter machinery condition',
                icon: Icons.warning,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _dateController,
                labelText: 'Date Acquired',
                hintText: 'YYYY-MM-DD',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateMachinery,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.blueGrey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String labelText,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(Icons.category, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.blueGrey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
