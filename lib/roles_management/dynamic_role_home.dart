import 'package:dairy_harbor/roles_management/roleAuthService.dart';
import 'package:dairy_harbor/roles_management/rolePermissions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DynamicRoleHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String userEmail = FirebaseAuth.instance.currentUser!.email ?? 'user@example.com';

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: RoleAuthService().getUserRole(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error retrieving role: ${snapshot.error}'));
          }

          String userRole = snapshot.data ?? 'guest';
          String initials = _getInitials(userEmail);
          String greeting = _getGreeting();

          return _buildRoleFeatures(userRole, context, initials, greeting);
        },
      ),
    );
  }

  String _getInitials(String email) {
    List<String> parts = email.split('@')[0].split('.');
    return parts.map((part) => part[0].toUpperCase()).join();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Widget _buildRoleFeatures(String role, BuildContext context, String initials, String greeting) {
    List<Widget> features = _getFeaturesForRole(role, context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, $initials!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
          SizedBox(height: 16),
          Text(
            'You are logged in as: $role',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 16),
          Text(
            'Select an action below:',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: features,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getFeaturesForRole(String role, BuildContext context) {
    List<Widget> features = [];

    rolePermissions.forEach((route, allowedRoles) {
      if (allowedRoles.contains(role)) {
        features.add(
          Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                route.replaceFirst('/', '').replaceAll('/', ' '),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              trailing: Icon(Icons.arrow_forward),
              onTap: () => _navigateToRoute(context, route),
            ),
          ),
        );
      }
    });

    if (features.isEmpty) {
      features.add(Center(child: Text('No features available for your role.')));
    }

    return features;
  }

  Future<void> _navigateToRoute(BuildContext context, String route) async {
    try {
      await Navigator.pushNamed(context, route);
    } catch (error) {
      print("Navigation error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error navigating: $error')),
      );
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () async {
                await _logout(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully logged out.')),
      );
      Navigator.of(context).pushReplacementNamed('/loginOrRegister'); // Adjust as needed
    } catch (error) {
      print("Logout error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $error')),
      );
    }
  }
}
