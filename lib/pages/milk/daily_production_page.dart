import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MilkProductionPage extends StatefulWidget {
  @override
  _MilkProductionPageState createState() => _MilkProductionPageState();
}

class _MilkProductionPageState extends State<MilkProductionPage> {
  final _formKey = GlobalKey<FormState>();
  final _milkInLitresController = TextEditingController();
  final _givenToCalvesController = TextEditingController();
  final _spillageController = TextEditingController();
  final _spoiledController = TextEditingController();
  final _consumedByStaffController = TextEditingController();
  final _pricePerLitreController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  bool _isFormVisible = false;
  List<Map<String, dynamic>> _tableData = [];
  String? _selectedDocId;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('milk_production')
          .get();

      setState(() {
        _tableData = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'Date': (data['date'] as Timestamp).toDate(),
            'Milk in Litres': data['milk_in_litres']?.toString() ?? '',
            'Given to Calves': data['given_to_calves']?.toString() ?? '',
            'Spillage': data['spillage']?.toString() ?? '',
            'Spoiled': data['spoiled']?.toString() ?? '',
            'Final Milk Litres': data['final_in_litres']?.toString() ?? '',
            'Price per Litre': data['price_per_litre']?.toString() ?? '',
          };
        }).toList();
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDocId != null) {
        _updateEntry(_selectedDocId!);
      } else {
        _addEntry();
      }
    }
  }
  String _formatDate(DateTime date) {
    final List<String> weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return "${weekdays[date.weekday - 1].substring(0, 3)}, ${date.month} ${date.day}, ${date.year}";
  }
  Future<void> _addEntry() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('milk_production')
          .add({
        'date': _selectedDate,
        'milk_in_litres': double.tryParse(_milkInLitresController.text) ?? 0.0,
        'given_to_calves': double.tryParse(_givenToCalvesController.text) ?? 0.0,
        'spillage': double.tryParse(_spillageController.text) ?? 0.0,
        'spoiled': double.tryParse(_spoiledController.text) ?? 0.0,
        'final_in_litres': double.tryParse(_consumedByStaffController.text) ?? 0.0,
        'price_per_litre': double.tryParse(_pricePerLitreController.text) ?? 0.0,
      });
      _resetForm();
      await _fetchData();
    }
  }

  Future<void> _updateEntry(String docId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('milk_production')
          .doc(docId)
          .update({
        'date': _selectedDate,
        'milk_in_litres': double.tryParse(_milkInLitresController.text) ?? 0.0,
        'given_to_calves': double.tryParse(_givenToCalvesController.text) ?? 0.0,
        'spillage': double.tryParse(_spillageController.text) ?? 0.0,
        'spoiled': double.tryParse(_spoiledController.text) ?? 0.0,
        'final_in_litres': double.tryParse(_consumedByStaffController.text) ?? 0.0,
        'price_per_litre': double.tryParse(_pricePerLitreController.text) ?? 0.0,
      });
      _resetForm();
      await _fetchData();
    }
  }

  Future<void> _deleteEntry(String docId) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this entry?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('milk_production')
            .doc(docId)
            .delete();
        _fetchData();
      }
    }
  }

  void _resetForm() {
    setState(() {
      _selectedDate = null;
      _milkInLitresController.clear();
      _givenToCalvesController.clear();
      _spillageController.clear();
      _spoiledController.clear();
      _consumedByStaffController.clear();
      _pricePerLitreController.clear();
      _notesController.clear();
      _selectedDocId = null;
      _isFormVisible = false;
    });
  }

  void _editEntry(Map<String, dynamic> data) {
    setState(() {
      _selectedDocId = data['id'];
      _selectedDate = data['Date'] as DateTime?;
      _milkInLitresController.text = data['Milk in Litres'] ?? '';
      _givenToCalvesController.text = data['Given to Calves'] ?? '';
      _spillageController.text = data['Spillage'] ?? '';
      _spoiledController.text = data['Spoiled'] ?? '';
      _consumedByStaffController.text = data['Final Milk Litres'] ?? '';
      _pricePerLitreController.text = data['Price per Litre'] ?? '';
      _isFormVisible = true;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Milk Production'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isFormVisible) _buildForm(),
              const SizedBox(height: 24),
              _buildTable(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isFormVisible = !_isFormVisible;
          });
        },
        child: Icon(_isFormVisible ? Icons.close : Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Milk Production Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 16),
            _buildDateField(),
            const SizedBox(height: 12),
            _buildTextField('Milk in Litres', _milkInLitresController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildTextField(
                'Given to Calves (Litres)', _givenToCalvesController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildTextField('Spillage (Litres)', _spillageController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildTextField('Spoiled (Litres)', _spoiledController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildTextField(
                'Final Milk in Litres', _consumedByStaffController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildTextField('Price per Litre', _pricePerLitreController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildTextField('Notes', _notesController),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Submit'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        TextFormField(
          readOnly: true,
          onTap: () => _selectDate(context),
          validator: (value) {
            if (_selectedDate == null) {
              return 'Please select a date';
            }
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            hintText: _selectedDate != null
                ? _formatDate(_selectedDate!)
                : 'Select Date',
            suffixIcon: Icon(Icons.calendar_today, color: Colors.blueAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            hintText: 'Enter $label',
          ),
        ),
      ],
    );
  }

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 16,
          columns: _getTableColumns(),
          rows: _getTableRows(),
          headingRowColor: MaterialStateColor.resolveWith(
              (states) => Colors.blueAccent.withOpacity(0.1)),
          dataRowColor:
              MaterialStateColor.resolveWith((states) => Colors.white),
          headingTextStyle:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
          dataTextStyle: TextStyle(color: Colors.black87),
        ),
      ),
    );
  }

  List<DataColumn> _getTableColumns() {
    return [
      _buildTableColumn('Date'),
      _buildTableColumn('Milk in Litres'),
      _buildTableColumn('Given to Calves'),
      _buildTableColumn('Spillage'),
      _buildTableColumn('Spoiled'),
      _buildTableColumn('Final Milk Litres'),
      _buildTableColumn('Price per Litre'),
      DataColumn(
          label: Text('Actions',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blueAccent))),
    ];
  }

  DataColumn _buildTableColumn(String label) {
    return DataColumn(
      label: Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.blueAccent)),
    );
  }

  List<DataRow> _getTableRows() {
    return _tableData.map((data) {
      return DataRow(
        cells: <DataCell>[
          DataCell(Text(_formatDate(data['Date']))),
          DataCell(Text(data['Milk in Litres'] ?? '')),
          DataCell(Text(data['Given to Calves'] ?? '')),
          DataCell(Text(data['Spillage'] ?? '')),
          DataCell(Text(data['Spoiled'] ?? '')),
          DataCell(Text(data['Final Milk Litres'] ?? '')),
          DataCell(Text(data['Price per Litre'] ?? '')),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blueAccent),
                onPressed: () => _editEntry(data),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteEntry(data['id']),
              ),
            ],
          )),
        ],
      );
    }).toList();
  }
}
