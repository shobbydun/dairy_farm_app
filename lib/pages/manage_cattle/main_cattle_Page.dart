import 'package:flutter/material.dart';
import 'package:dairy_harbor/pages/manage_cattle/cattle_list_page.dart'; // Make sure this path is correct
import 'cattle_form.dart'; // Ensure this path is correct

class CattlePage extends StatefulWidget {
  const CattlePage({super.key});

  @override
  _CattlePageState createState() => _CattlePageState();
}

class _CattlePageState extends State<CattlePage> {
  bool _showForm = false;

  void _toggleFormVisibility() {
    setState(() {
      _showForm = !_showForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cattle Manager'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _toggleFormVisibility,
              child: Text(_showForm ? 'Close Form' : 'Add Cattle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_showForm)
              CattleForm(), // Display the cattle registration form if _showForm is true
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: CattleList(), // Ensure CattleList widget is properly defined and imported
            ),
          ],
        ),
      ),
    );
  }
}
