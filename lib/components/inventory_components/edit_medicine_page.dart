import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditMedicinePage extends StatefulWidget {
  final String medicineId;
  final Future<String?> adminEmailFuture;

  const EditMedicinePage({
    super.key,
    required this.medicineId,
    required this.adminEmailFuture,
  });

  @override
  _EditMedicinePageState createState() => _EditMedicinePageState();
}

class _EditMedicinePageState extends State<EditMedicinePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  Map<String, dynamic>? _medicine;
  String? _adminEmail;

  @override
  void initState() {
    super.initState();
    _fetchAdminEmail();
    _fetchMedicineDetails();
  }

  Future<void> _fetchAdminEmail() async {
    _adminEmail = await widget.adminEmailFuture;
    if (_adminEmail != null) {
      await _fetchMedicineDetails();
    } else {
      print("Admin email is null");
    }
  }

  Future<void> _fetchMedicineDetails() async {
    if (_adminEmail != null) {
      try {
        final medicineDoc = await FirebaseFirestore.instance
            .collection('medicines')
            .doc(_adminEmail)
            .collection('entries')
            .doc(widget.medicineId)
            .get();

        if (medicineDoc.exists) {
          setState(() {
            _medicine = medicineDoc.data();
            _nameController.text = _medicine?['name'] ?? '';
            _quantityController.text = _medicine?['quantity']?.toString() ?? '';
            _expiryDateController.text = _medicine?['expiryDate'] ?? '';
            _supplierController.text = _medicine?['supplier'] ?? '';
            _costController.text =
                (_medicine?['cost']?.toStringAsFixed(2) ?? '0.00');
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Medicine not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('Error fetching medicine details: $e');
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await FirebaseFirestore.instance
            .collection('medicines')
            .doc(_adminEmail)
            .collection('entries')
            .doc(widget.medicineId)
            .update({
          'name': _nameController.text,
          'quantity': int.tryParse(_quantityController.text) ?? 0,
          'expiryDate': _expiryDateController.text,
          'supplier': _supplierController.text,
          'cost': double.tryParse(_costController.text) ?? 0.0,
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
          child: _medicine == null
              ? Center(child: CircularProgressIndicator())
              : Column(
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
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _costController,
                      labelText: 'Cost',
                      hintText: 'Enter cost',
                      icon: Icons.money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the cost';
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
