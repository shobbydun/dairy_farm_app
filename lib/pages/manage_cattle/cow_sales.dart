import 'package:flutter/material.dart';

class CowSalesPage extends StatefulWidget {
  final Future<String?> adminEmailFuture;

  const CowSalesPage({Key? key, required this.adminEmailFuture}) : super(key: key);


  @override
  _CowSalesPageState createState() => _CowSalesPageState();
}

class _CowSalesPageState extends State<CowSalesPage> {
  final _formKey = GlobalKey<FormState>();

  // Form fields controllers
  DateTime? _selectedDate;
  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController Controller = TextEditingController();
  final TextEditingController _buyerController = TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String? _selectedCattle;
  String? _adminEmail;

  Future<void> _fetchAdminEmail() async {
    _adminEmail = await widget.adminEmailFuture;
    setState(() {});
  }

  // Data to display in the table
  List<Map<String, String>> _tableData = [];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _tableData.add({
          'Date': _selectedDate?.toLocal().toString().split(' ')[0] ?? '',
          'Serial Number': _serialNumberController.text,
          'Cattle Name': _selectedCattle.toString(),
          'Buyer': _buyerController.text,
          'Selling Price': _sellingPriceController.text,
          'Notes': _notesController.text,
        });

        // Clear form fields
        _selectedDate = null;
        _serialNumberController.clear();
        _buyerController.clear();
        _sellingPriceController.clear();
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
        title: const Text('Cow Sales'),
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
                        'Enter Cow Sales Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDateField(),
                      SizedBox(height: 12),
                      _buildTextField('Serial Number', _serialNumberController, keyboardType: TextInputType.text),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Select Cattle'),
                        value: _selectedCattle,
                        items: [
                          DropdownMenuItem(value: 'Cattle1', child: Text('Cattle1')),
                          DropdownMenuItem(value: 'Cattle2', child: Text('Cattle2')),
                        ],
                        onChanged: (value) {
                          if (mounted) {
                            setState(() {
                              _selectedCattle = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField('Buyer', _buyerController, keyboardType: TextInputType.text),
                      const SizedBox(height: 12),
                      _buildTextField('Selling Price', _sellingPriceController, keyboardType: TextInputType.number),
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
          headingRowColor: WidgetStateColor.resolveWith((states) => Colors.blueAccent.withOpacity(0.1)),
          dataRowColor: WidgetStateColor.resolveWith((states) => Colors.white),
          headingTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
          dataTextStyle: TextStyle(color: Colors.black87),
        ),
      ),
    );
  }

  List<DataColumn> _getTableColumns() {
    return [
      _buildTableColumn('Date'),
      _buildTableColumn('Serial'),
      _buildTableColumn('Cattle Name'),
      _buildTableColumn('Buyer'),
      _buildTableColumn('Price(Ksh)'),
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
              DataCell(Text(data['Serial Number'] ?? '')),
              DataCell(Text(data['Cattle Name'] ?? '')),
              DataCell(Text(data['Buyer'] ?? '')),
              DataCell(Text(data['Selling Price'] ?? '')),
            ],
          ),
        )
        .toList();
  }
}

