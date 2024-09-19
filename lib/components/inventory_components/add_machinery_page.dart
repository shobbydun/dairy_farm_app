import 'package:dairy_harbor/services_functions/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddMachineryPage extends StatefulWidget {
  const AddMachineryPage({super.key});

  @override
  _AddMachineryPageState createState() => _AddMachineryPageState();
}

class _AddMachineryPageState extends State<AddMachineryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _buyCostController = TextEditingController();
  final TextEditingController _maintenanceCostController = TextEditingController();
  
  String _selectedType = 'Agricultural'; // Default value for dropdown

  late FirestoreServices _firestoreServices;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _firestoreServices = FirestoreServices(userId);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      // selected date
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      final String formattedDate = formatter.format(selectedDate);

      setState(() {
        _dateController.text = formattedDate;
      });
    }
  }

  Future<void> _addMachinery() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await _firestoreServices.addMachinery(
          _nameController.text,
          _selectedType, 
          _conditionController.text,
          _dateController.text,
          double.tryParse(_buyCostController.text) ?? 0.0,
          double.tryParse(_maintenanceCostController.text) ?? 0.0,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Machinery record added')),
        );
        Navigator.pop(context); 
      } catch (e) {
        print('Error adding machinery: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding machinery')),
        );
      }
    }
  }

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
              GestureDetector(
                onTap: () => _selectDate(context), 
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: _dateController,
                    labelText: 'Date Acquired',
                    hintText: 'YYYY-MM-DD',
                    icon: Icons.calendar_today,
                    keyboardType: TextInputType.datetime,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _buyCostController,
                labelText: 'Buy Cost',
                hintText: 'Enter buy cost',
                icon: Icons.monetization_on,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the buy cost';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _maintenanceCostController,
                labelText: 'Maintenance Cost per Month',
                hintText: 'Enter maintenance cost',
                icon: Icons.attach_money,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the maintenance cost';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _addMachinery,
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
