import 'package:dairy_harbor/services_functions/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditWagePage extends StatefulWidget {
  final String docId;
  final String employeeName;
  final String department;
  final String date;
  final String wage;

  const EditWagePage({
    super.key,
    required this.docId,
    required this.employeeName,
    required this.department,
    required this.date,
    required this.wage,
  });

  @override
  _EditWagePageState createState() => _EditWagePageState();
}

class _EditWagePageState extends State<EditWagePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _departmentController;
  late TextEditingController _dateController;
  late TextEditingController _wageController;
  late FirestoreServices _firestoreServices;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _firestoreServices = FirestoreServices(userId); 
    _nameController = TextEditingController(text: widget.employeeName);
    _departmentController = TextEditingController(text: widget.department);
    _dateController = TextEditingController(text: widget.date);
    _wageController = TextEditingController(text: widget.wage);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    _dateController.dispose();
    _wageController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final updatedWage = {
        'employeeName': _nameController.text,
        'department': _departmentController.text,
        'date': _dateController.text,
        'wage': _wageController.text,
      };

      try {
        await _firestoreServices.updateWage(widget.docId, updatedWage);
        
        // success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Wage record updated successfully.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        Navigator.pop(context);
      } catch (e) {
        print('Error updating wage record: $e');
        
        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update wage record. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Wage'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Employee Name
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Employee Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the employee name';
                      }
                      return null;
                    },
                  ),
                ),
                // Department
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _departmentController,
                    decoration: InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the department';
                      }
                      return null;
                    },
                  ),
                ),
                // Date
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the date';
                      }
                      return null;
                    },
                  ),
                ),
                // Wage
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: TextFormField(
                    controller: _wageController,
                    decoration: InputDecoration(
                      labelText: 'Wage',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the wage amount';
                      }
                      return null;
                    },
                  ),
                ),
                // Save Button
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
