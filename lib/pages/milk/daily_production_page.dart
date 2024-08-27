import 'package:flutter/material.dart';

class MilkProductionPage extends StatefulWidget {
  @override
  _MilkProductionPageState createState() => _MilkProductionPageState();
}

class _MilkProductionPageState extends State<MilkProductionPage> {
  final _formKey = GlobalKey<FormState>();

  // Form fields controllers
  DateTime? _selectedDate;
  final TextEditingController _milkInLitresController = TextEditingController();
  final TextEditingController _consumedByStaffController = TextEditingController();
  final TextEditingController _givenToCalvesController = TextEditingController();
  final TextEditingController _spillageController = TextEditingController();
  final TextEditingController _spoiledController = TextEditingController();
  final TextEditingController _pricePerLitreController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Data to display in the table
  List<Map<String, String>> _tableData = [];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _tableData.add({
          'Date': _selectedDate?.toLocal().toString().split(' ')[0] ?? '',
          'Milk in Litres': _milkInLitresController.text,
          'Consumed by Staff': _consumedByStaffController.text,
          'Given to Calves': _givenToCalvesController.text,
          'Spillage': _spillageController.text,
          'Spoiled': _spoiledController.text,
          'Price per Litre': _pricePerLitreController.text,
        });

        // Clear form fields
        _selectedDate = null;
        _milkInLitresController.clear();
        _consumedByStaffController.clear();
        _givenToCalvesController.clear();
        _spillageController.clear();
        _spoiledController.clear();
        _pricePerLitreController.clear();
        _notesController.clear();
      });
    }
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
              // Form container
              Container(
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
                      _buildTextField('Milk in Litres', _milkInLitresController, keyboardType: TextInputType.number),
                      const SizedBox(height: 12),
                      _buildTextField('Consumed by Staff (Litres)', _consumedByStaffController, keyboardType: TextInputType.number),
                      const SizedBox(height: 12),
                      _buildTextField('Given to Calves (Litres)', _givenToCalvesController, keyboardType: TextInputType.number),
                      const SizedBox(height: 12),
                      _buildTextField('Spillage (Litres)', _spillageController, keyboardType: TextInputType.number),
                      const SizedBox(height: 12),
                      _buildTextField('Spoiled (Litres)', _spoiledController, keyboardType: TextInputType.number),
                      const SizedBox(height: 12),
                      _buildTextField('Price per Litre', _pricePerLitreController, keyboardType: TextInputType.number),
                      const SizedBox(height: 12),
                      _buildTextField('Notes', _notesController),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, 
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(fontSize: 16),
        ),
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
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            hintText: _selectedDate != null ? _selectedDate!.toLocal().toString().split(' ')[0] : 'Select Date',
            suffixIcon: Icon(Icons.calendar_today, color: Colors.blueAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
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
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
          headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blueAccent.withOpacity(0.1)),
          dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
          headingTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
          dataTextStyle: TextStyle(color: Colors.black87),
        ),
      ),
    );
  }

  List<DataColumn> _getTableColumns() {
    return [
      _buildTableColumn('Date'),
      _buildTableColumn('Milk in Litres'),
      _buildTableColumn('Consumed by Staff'),
      _buildTableColumn('Given to Calves'),
      _buildTableColumn('Spoiled'),
      _buildTableColumn('Spillage'),
      _buildTableColumn('Price per Litre'),
    ];
  }

  DataColumn _buildTableColumn(String label) {
    return DataColumn(
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  List<DataRow> _getTableRows() {
    return _tableData
        .map(
          (data) => DataRow(
            cells: <DataCell>[
              DataCell(Text(data['Date'] ?? '')),
              DataCell(Text(data['Milk in Litres'] ?? '')),
              DataCell(Text(data['Consumed by Staff'] ?? '')),
              DataCell(Text(data['Given to Calves'] ?? '')),
              DataCell(Text(data['Spoiled'] ?? '')),
              DataCell(Text(data['Spillage'] ?? '')),
              DataCell(Text(data['Price per Litre'] ?? '')),
            ],
          ),
        )
        .toList();
  }
}

