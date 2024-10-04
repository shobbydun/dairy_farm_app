import 'package:flutter/material.dart';

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
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/cattleForm');
                },
                child: const Text('Go to Cattle Form'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/cattleList');
              },
              child: const Text('Go to Cattle List'),
            ),
            const SizedBox(height: 20),
            // Optional: Directly include a button to go back if you're navigating away from CattlePage
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to the previous screen
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
