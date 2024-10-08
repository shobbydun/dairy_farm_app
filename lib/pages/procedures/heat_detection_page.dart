import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HeatDetectionPage extends StatefulWidget {
  final Future<String?> adminEmailFuture;

  HeatDetectionPage({required this.adminEmailFuture});
  @override
  _HeatDetectionPageState createState() => _HeatDetectionPageState();
}

class _HeatDetectionPageState extends State<HeatDetectionPage> {
  final TextEditingController _cowNameController = TextEditingController();
  final TextEditingController _tagNumberController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  double _certainty = 0;
  String? _adminEmail;
  List<String> _cattleNames = [];
  String? _selectedCowName;
  String? _selectedBreed;

  // List of signs and their importance rating
  final Map<String, int> _signs = {
    'Mounting Behavior': 10,
    'Standing to be Mounted': 10,
    'Mucus Discharge': 9,
    'Restlessness': 8,
    'Tail Raising': 7,
    'Sniffing Other Cows\' Genitals': 7,
    'Vulva Swelling': 6,
    'Vocalization': 6,
    'Chin Resting': 6,
  };

  final List<String> _dairyBreeds = [
    'Holstein',
    'Jersey',
    'Guernsey',
    'Ayrshire',
    'Brown Swiss',
    'Milking Shorthorn',
    'Dexter',
    'Piedmontese',
  ];

  // Store selected signs
  Map<String, bool> _selectedSigns = {};

  @override
  void initState() {
    super.initState();
    _signs.forEach((sign, _) {
      _selectedSigns[sign] = false;
    });
    _fetchAdminEmail();
  }

  Future<void> _fetchAdminEmail() async {
    _adminEmail = await widget.adminEmailFuture;
    await _fetchCattleNames();
    await _fetchRecords();
    setState(() {});
  }

  Future<void> _fetchCattleNames() async {
    if (_adminEmail != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('cattle')
          .doc(_adminEmail)
          .collection('entries')
          .get();

      _cattleNames = snapshot.docs.map((doc) => doc['name'] as String).toList();
      setState(() {});
    }
  }

  // Function to calculate heat detection certainty based on selected signs
  void _calculateCertainty() {
    int totalImportance =
        _signs.values.reduce((a, b) => a + b); // Total importance (70)
    int selectedImportance = 0;

    _selectedSigns.forEach((sign, isSelected) {
      if (isSelected) {
        selectedImportance += _signs[sign]!;
      }
    });

    setState(() {
      _certainty = (selectedImportance / totalImportance) * 100;
      if (_certainty > 100) _certainty = 100; // Cap certainty at 100%
    });
  }

  // Function to store data to Firestore
  Future<void> _storeHeatDetectionData() async {
    if (_selectedCowName == null ||
        _tagNumberController.text.isEmpty ||
        _selectedBreed == null) {
      // Check for selected breed
      _showSnackbar('Please fill all fields');
      return;
    }

    try {
      if (_adminEmail != null) {
        await FirebaseFirestore.instance
            .collection('heat_detection')
            .doc(_adminEmail)
            .collection('records')
            .add({
          'cow_name': _selectedCowName,
          'tag_number': _tagNumberController.text,
          'breed': _selectedBreed, // Use selected breed
          'signs': _selectedSigns.keys
              .where((sign) => _selectedSigns[sign] == true)
              .toList(),
          'certainty': _certainty,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _showSnackbar('Data successfully recorded');
        _clearFields();
      }
    } catch (e) {
      _showSnackbar('Failed to record data: $e');
    }
  }

  // Function to show Snackbar
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  // Function to clear input fields
  void _clearFields() {
    _cowNameController.clear();
    _tagNumberController.clear();
    _breedController.clear();
    setState(() {
      _certainty = 0;
      _selectedSigns.updateAll((key, value) => false);
    });
  }

  // Function to fetch heat detection records from Firestore
  Stream<List<HeatDetectionRecord>> _fetchRecords() {
    if (_adminEmail != null) {
      return FirebaseFirestore.instance
          .collection('heat_detection')
          .doc(_adminEmail)
          .collection('records')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => HeatDetectionRecord.fromDocument(doc))
              .toList());
    } else {
      // Return an empty list if _adminEmail is null
      return Stream.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heat Detection'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeatDetectionCard(),
              SizedBox(height: 16.0),
              _buildInputFields(),
              SizedBox(height: 16.0),
              _buildSignsList(),
              SizedBox(height: 16.0),
              _buildProgressBar(),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _storeHeatDetectionData,
                child: Text('Submit Heat Detection',
                style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Previous Heat Detection Records',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              _buildRecordsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeatDetectionCard() {
    return Card(
      color: Colors.white,
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Image.asset(
                'assets/heat.jpeg',
                height: MediaQuery.of(context).size.height * 0.4,
                width: double.infinity,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.4),
                colorBlendMode: BlendMode.darken,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'HEAT DETECTION',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Monitor and track heat cycles effectively with our comprehensive tools. Ensure accurate tracking for better management and productivity.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  // Input form for cow details
  Widget _buildInputFields() {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCowName,
              hint: Text('Select Cow Name'),
              items: _cattleNames.map((String name) {
                return DropdownMenuItem<String>(
                  value: name,
                  child: Text(name),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCowName = newValue;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _tagNumberController,
              decoration: InputDecoration(
                labelText: 'Tag Number',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedBreed,
              hint: Text('Select Breed'),
              items: _dairyBreeds.map((String breed) {
                return DropdownMenuItem<String>(
                  value: breed,
                  child: Text(breed),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBreed = newValue;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Signs list with tick boxes
  Widget _buildSignsList() {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _signs.keys.map((sign) {
            return CheckboxListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sign,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    _getSignDescription(sign),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              value: _selectedSigns[sign],
              onChanged: (bool? value) {
                setState(() {
                  _selectedSigns[sign] = value ?? false;
                  _calculateCertainty();
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // Function to return the description of each symptom
  String _getSignDescription(String sign) {
    switch (sign) {
      case 'Mounting Behavior':
        return 'Cows attempting to mount other cows.';
      case 'Standing to be Mounted':
        return 'Cows that stand still when mounted by others.';
      case 'Mucus Discharge':
        return 'Clear or cloudy discharge from the vulva.';
      case 'Restlessness':
        return 'Increased movement and agitation in cows.';
      case 'Tail Raising':
        return 'Cows raising their tails indicating readiness.';
      case 'Sniffing Other Cows\' Genitals':
        return 'Cows sniffing or investigating others.';
      case 'Vulva Swelling':
        return 'Swelling of the vulva area.';
      case 'Vocalization':
        return 'Increased vocal sounds from cows.';
      case 'Chin Resting':
        return 'Cows resting their chin on others.';
      default:
        return '';
    }
  }

  // Progress bar to show certainty
  Widget _buildProgressBar() {
    return Column(
      children: [
        Text(
          'Certainty: ${_certainty.toStringAsFixed(2)}%',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.0),
        LinearProgressIndicator(
          value: _certainty / 100,
          backgroundColor: Colors.grey[300],
          color: Colors.blueAccent,
        ),
      ],
    );
  }

  // Build records list
  Widget _buildRecordsList() {
    return StreamBuilder<List<HeatDetectionRecord>>(
      stream: _fetchRecords(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No records found'));
        }

        final records = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin: const EdgeInsets.only(bottom: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cow Name: ${record.cowName}',
                        style: TextStyle(fontSize: 16)),
                    Text('Tag Number: ${record.tagNumber}',
                        style: TextStyle(fontSize: 16)),
                    Text('Breed: ${record.breed}',
                        style: TextStyle(fontSize: 16)),
                    Text('Certainty: ${record.certainty.toStringAsFixed(2)}%',
                        style: TextStyle(fontSize: 16)),
                    Text('Signs Detected: ${record.signs.join(', ')}',
                        style: TextStyle(fontSize: 16)),
                    Text(
                        'Date: ${record.timestamp.toDate().toString().substring(0, 19)}',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Model for heat detection record
class HeatDetectionRecord {
  final String cowName;
  final String tagNumber;
  final String breed;
  final double certainty;
  final List<String> signs;
  final Timestamp timestamp;

  HeatDetectionRecord({
    required this.cowName,
    required this.tagNumber,
    required this.breed,
    required this.certainty,
    required this.signs,
    required this.timestamp,
  });

  factory HeatDetectionRecord.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HeatDetectionRecord(
      cowName: data['cow_name'] ?? '',
      tagNumber: data['tag_number'] ?? '',
      breed: data['breed'] ?? '',
      certainty: (data['certainty'] ?? 0).toDouble(),
      signs: List<String>.from(data['signs'] ?? []),
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}
