import 'package:dairy_harbor/services_functions/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditMedicinePage extends StatefulWidget {
  final String medicineId;

  const EditMedicinePage({super.key, required this.medicineId});

  @override
  _EditMedicinePageState createState() => _EditMedicinePageState();
}

class _EditMedicinePageState extends State<EditMedicinePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();

  late FirestoreServices _firestoreServices;

  @override
  void initState() {
    super.initState();
    _firestoreServices = FirestoreServices(FirebaseAuth.instance.currentUser!.uid);
    _fetchMedicineDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _expiryDateController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  Future<void> _fetchMedicineDetails() async {
    try {
      final medicines = await _firestoreServices.getMedicines();
      final medicine = medicines.firstWhere((med) => med['id'] == widget.medicineId);
      _nameController.text = medicine['name'];
      _quantityController.text = medicine['quantity'];
      _expiryDateController.text = medicine['expiryDate'];
      _supplierController.text = medicine['supplier'];
    } catch (e) {
      print('Error fetching medicine details: $e');
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await _firestoreServices.updateMedicine(widget.medicineId, {
          'name': _nameController.text,
          'quantity': _quantityController.text,
          'expiryDate': _expiryDateController.text,
          'supplier': _supplierController.text,
        });
        Navigator.pop(context);
      } catch (e) {
        print('Error saving changes: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Medicine'),
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
              _buildTextField(
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
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Save Changes',
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
