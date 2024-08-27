import 'package:flutter/material.dart';

class DewormingPage extends StatefulWidget {
  @override
  _DewormingPageState createState() => _DewormingPageState();
}

class _DewormingPageState extends State<DewormingPage> {
  final _cattleIdController = TextEditingController();
  final _dateOfDewormingController = TextEditingController();
  final _vetNameController = TextEditingController();
  final _methodController = TextEditingController();
  final _diseaseController = TextEditingController();
  final _drugUsedController = TextEditingController();
  final _notesController = TextEditingController();

  List<Map<String, String>> _dewormingList = [];

  void _submitForm() {
    final dateOfDeworming = _dateOfDewormingController.text;
    final cattleId = _cattleIdController.text;
    final vetName = _vetNameController.text;
    final method = _methodController.text;
    final disease = _diseaseController.text;
    final drugUsed = _drugUsedController.text;
    final notes = _notesController.text;

    if (dateOfDeworming.isEmpty ||
        cattleId.isEmpty ||
        vetName.isEmpty ||
        method.isEmpty ||
        disease.isEmpty ||
        drugUsed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() {
      _dewormingList.add({
        'date': dateOfDeworming,
        'cattleId': cattleId,
        'vetName': vetName,
        'method': method,
        'disease': disease,
        'drugUsed': drugUsed,
        'notes': notes,
      });
    });

    _clearForm();
  }

  void _clearForm() {
    _cattleIdController.clear();
    _dateOfDewormingController.clear();
    _vetNameController.clear();
    _methodController.clear();
    _diseaseController.clear();
    _drugUsedController.clear();
    _notesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deworming'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: 16.0),
                    _buildDewormingForm(),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
          ),
      
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              'assets/deworm.jpeg',
              fit: BoxFit.cover,
              height: 300,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Deworming',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlueAccent,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'A detailed summary of your livestock\'s deworming schedules and overall health status.',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDewormingForm() {
    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deworming Form',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            _buildFormField(
              controller: _cattleIdController,
              labelText: 'Select Cattle',
            ),
            _buildFormField(
              controller: _dateOfDewormingController,
              labelText: 'Date Of Deworming',
              inputType: TextInputType.datetime,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  String formattedDate = '${pickedDate.year.toString().padLeft(4, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                  _dateOfDewormingController.text = formattedDate;
                }
              },
            ),
            _buildFormField(
              controller: _vetNameController,
              labelText: 'Veterinary Doctor\'s Name',
            ),
            _buildDropdownField(
              controller: _methodController,
              labelText: 'Method Of Deworming',
              items: ['Pour-On', 'Oral Drench', 'Injectable', 'Feed Additive', 'Bolus', 'Paste'],
            ),
            _buildFormField(
              controller: _diseaseController,
              labelText: 'Name of Disease',
            ),
            _buildFormField(
              controller: _drugUsedController,
              labelText: 'Name of Medicine',
            ),
            _buildFormField(
              controller: _notesController,
              labelText: 'Notes',
              isMultiline: true,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String labelText,
    TextInputType inputType = TextInputType.text,
    bool isMultiline = false,
    void Function()? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        keyboardType: inputType,
        maxLines: isMultiline ? 3 : 1,
        onTap: onTap,
      ),
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String labelText,
    required List<String> items,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: controller.text.isEmpty ? null : controller.text,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            controller.text = value!;
          });
        },
      ),
    );
  }

  Widget _buildDewormingList() {
    
    return ListView.builder(
      itemCount: _dewormingList.length,
      itemBuilder: (context, index) {
        final item = _dewormingList[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text('${item['date']} - ${item['cattleId']}'),
            subtitle: Text(
              'Vet: ${item['vetName']}\n'
              'Method: ${item['method']}\n'
              'Disease: ${item['disease']}\n'
              'Drug: ${item['drugUsed']}\n'
              'Notes: ${item['notes']}',
              style: TextStyle(color: Colors.black54),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  _dewormingList.removeAt(index);
                });
              },
            ),
          ),
        );
      },
    );
  }
}


