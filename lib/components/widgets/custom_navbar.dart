import 'package:flutter/material.dart';

// ignore: use_key_in_widget_constructors
class CustomNavbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.lightBlueAccent, // bg-navbar-theme equivalent
      elevation: 4.0,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      title: const Text('Dairy Harbor'), // Replace with dynamic value if needed
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // Handle search action
          },
        ),
        PopupMenuButton(
          icon: const CircleAvatar(
            backgroundImage:
                AssetImage('assets/images/logo.png'), // Updated to local asset
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('My Profile'),
                onTap: () {
                  // Handle profile action
                  _showMyProfileModal(context);
                },
              ),
            ),
            PopupMenuItem(
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Edit Profile'),
                onTap: () {
                  // Handle edit profile action
                  _showEditProfileModal(context);
                },
              ),
            ),
            PopupMenuItem(
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Log Out'),
                onTap: () {
                  // Handle logout action
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showMyProfileModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              'My Profile',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100.0, // Add width constraint
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: John Doe', style: TextStyle(fontSize: 18.0)),
                      Text('Farm Name: Green Pastures',
                          style: TextStyle(fontSize: 18.0)),
                      Text('Email: johndoe@example.com',
                          style: TextStyle(fontSize: 18.0)),
                      Text('Location: 1234 Farm St',
                          style: TextStyle(fontSize: 18.0)),
                      Text('Phone Number: +1234567890',
                          style: TextStyle(fontSize: 18.0)),
                      Text('Number Of Cattle: 150',
                          style: TextStyle(fontSize: 18.0)),
                      Text('Number Of Workers: 10',
                          style: TextStyle(fontSize: 18.0)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showEditProfileModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              'Edit Profile',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Current Password (Confirm it is you)',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  initialValue: 'John Doe',
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  initialValue: 'johndoe@example.com',
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  initialValue: '+1234567890',
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  initialValue: '1234 Farm St',
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Handle the profile update logic
                    Navigator.of(context).pop(); // Close the modal after saving
                  },
                  child: const Text('Update Profile'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}