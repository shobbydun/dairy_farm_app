import 'package:flutter/material.dart';

class EditMachineryPage extends StatefulWidget {
  final String machineryName;
  final String machineryType;
  final String machineryCondition;
  final String dateAcquired;

  const EditMachineryPage({
    super.key,
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
  late TextEditingController _typeController;
  late TextEditingController _conditionController;
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.machineryName);
    _typeController = TextEditingController(text: widget.machineryType);
    _conditionController = TextEditingController(text: widget.machineryCondition);
    _dateController = TextEditingController(text: widget.dateAcquired);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
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
              // Name Field
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

              // Type Field
              _buildTextField(
                controller: _typeController,
                labelText: 'Type',
                hintText: 'Enter machinery type',
                icon: Icons.category,
              ),
              const SizedBox(height: 16),

              // Condition Field
              _buildTextField(
                controller: _conditionController,
                labelText: 'Condition',
                hintText: 'Enter machinery condition',
                icon: Icons.warning,
              ),
              const SizedBox(height: 16),

              // Date Acquired Field
              _buildTextField(
                controller: _dateController,
                labelText: 'Date Acquired',
                hintText: 'YYYY-MM-DD',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                 
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Machinery details updated')),
                    );
                    Navigator.pop(context); 
                  }
                },
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
}
