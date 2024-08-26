import 'package:flutter/material.dart';

class AddWagePage extends StatefulWidget {
  @override
  _AddWagePageState createState() => _AddWagePageState();
}

class _AddWagePageState extends State<AddWagePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _wageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Wage Record"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Employee Name Field
              _buildTextField(
                controller: _nameController,
                labelText: 'Employee Name',
                hintText: 'Enter employee name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the employee name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Department Field
              _buildTextField(
                controller: _departmentController,
                labelText: 'Department',
                hintText: 'Enter department',
                icon: Icons.work,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the department';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date Field
              _buildTextField(
                controller: _dateController,
                labelText: 'Date',
                hintText: 'YYYY-MM-DD',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Wage Field
              _buildTextField(
                controller: _wageController,
                labelText: 'Wage',
                hintText: 'Enter wage amount',
                icon: Icons.monetization_on,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the wage amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Add Wage Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Handle form submission
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Wage record added')),
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
                  'Add Wage',
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
    required FormFieldValidator<String> validator,
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
