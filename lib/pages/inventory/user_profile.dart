import 'package:dairy_harbor/components/inventory_components/wavy_border.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dairy Farmer Profile'),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Munei Dairy',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        Text(
                          'Dairy Farmer',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Farm Information
              _buildSection(
                title: 'Farm Information',
                content: [
                  'Farm Name: Mune Farm Dairy',
                  'Location: 123 Dairy Lane, Juja',
                  'Farm Size: 80 acres',
                  'Number of Cows: 150',
                ],
              ),
              const SizedBox(height: 20),

              // Dairy Production
              _buildSection(
                title: 'Dairy Production',
                content: [
                  'Daily Milk Production: 300 liters',
                  'Milk Sold: 250 liters/day',
                  'Milk Quality: High',
                ],
              ),
              const SizedBox(height: 20),

              // Contact Information
              _buildSection(
                title: 'Contact Information',
                content: [
                  'Phone: +254 710 7890',
                  'Email: momkuli@example.com',
                  'Website: www.dairy.com',
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildSection({
    required String title,
    required List<String> content,
  }) {
    return CustomPaint(
      painter: WavyBorderPainter(),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin:
            const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.4),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),
            ...content.map((line) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    line,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Image Section
            CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
              },
              child: Text('Change Profile Picture'),
            ),
            const SizedBox(height: 20),

            // Form for editing profile details
            _buildTextField(label: 'Full Name'),
            const SizedBox(height: 20),
            _buildTextField(label: 'Email'),
            const SizedBox(height: 20),
            _buildTextField(label: 'Phone Number'),
            const SizedBox(height: 20),
            _buildTextField(label: 'Farm Name'),
            const SizedBox(height: 20),
            _buildTextField(label: 'Farm Location'),
            const SizedBox(height: 20),
            _buildTextField(label: 'Farm Size'),
            const SizedBox(height: 20),
            _buildTextField(label: 'Number of Cows'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label}) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}
