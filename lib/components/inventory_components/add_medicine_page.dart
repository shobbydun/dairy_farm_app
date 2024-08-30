import 'package:dairy_harbor/services_functions/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddMedicinePage extends StatefulWidget {
  @override
  _AddMedicinePageState createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _supplierController = TextEditingController();

  late FirestoreServices _firestoreServices;

  @override
  void initState() {
    super.initState();
    _firestoreServices = FirestoreServices(FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _expiryDateController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  Future<void> _addMedicine() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestoreServices.addMedicine(
          _nameController.text,
          _quantityController.text,
          _expiryDateController.text,
          _supplierController.text,
        );
        Navigator.pop(context);
      } catch (e) {
        print('Error adding medicine: $e');
      }
    }
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _expiryDateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Medicine'),
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
                hintText: 'Enter medicine name',
                icon: Icons.medical_services,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the medicine name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _quantityController,
                labelText: 'Quantity',
                hintText: 'Enter quantity',
                icon: Icons.add_box,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _selectExpiryDate,
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: _expiryDateController,
                    labelText: 'Expiry Date',
                    hintText: 'YYYY-MM-DD',
                    icon: Icons.calendar_today,
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the expiry date';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _supplierController,
                labelText: 'Supplier',
                hintText: 'Enter supplier name',
                icon: Icons.business,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the supplier';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _addMedicine,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Add Medicine',
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
