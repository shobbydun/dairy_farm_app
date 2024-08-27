import 'package:flutter/material.dart';

class AddMachineryPage extends StatefulWidget {
  const AddMachineryPage({super.key});

  @override
  _AddMachineryPageState createState() => _AddMachineryPageState();
}


class _AddMachineryPageState extends State<AddMachineryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Machinery'),
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
                    // Handle form submission
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Machinery record added')),
                    );
                    Navigator.pop(context); // Go back to the previous screen
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
