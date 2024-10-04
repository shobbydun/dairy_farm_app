import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const Map<String, List<String>> rolePermissions = {
  '/milkSales': ['admin', 'manager', 'sales'],
  '/dailyProduction': ['admin', 'manager', 'staff', 'operator', 'milkman'],
  '/cattleListPage': ['admin', 'manager', 'staff'],
  '/reports': ['admin', 'manager', 'analyst'],
  '/adminWages': ['admin', 'manager'],
  '/machinery': ['admin', 'manager', 'maintenance'],
  '/feeds': ['admin', 'manager', 'staff'],
  '/inventory': ['admin', 'manager', 'staff'],
  '/medicine': ['admin', 'manager', 'veterinarian'],
  '/notification': ['admin', 'manager', 'staff'],
  '/userProfile': ['admin', 'manager', 'staff'],
  '/workerList': ['admin', 'manager'],
  '/workerProfile': ['admin', 'manager', 'hr'],
  '/cattleProfile': ['admin', 'manager', 'staff'],
  '/cattleForm': ['admin', 'manager', 'staff'],
};

List<String> getAllRoles() {
  return [
    'admin',
    'manager',
    'staff',
    'operator',
    'milkman',
    'sales',
    'analyst',
    'maintenance',
    'veterinarian',
    'hr',
    'employee',
    'owner',
  ];
}

class AdminDashboardPage extends StatefulWidget {
  static String? adminEmail;
  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<Map<String, dynamic>> users = [];
  Map<String, dynamic>? currentAdmin;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final adminSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();

      if (adminSnapshot.docs.isNotEmpty) {
        currentAdmin = {
          'id': adminSnapshot.docs.first.id,
          ...adminSnapshot.docs.first.data() as Map<String, dynamic>
        };
        String farmName = currentAdmin!['farmName'];
        AdminDashboardPage.adminEmail = currentAdmin!['email'];

        final userCollection = await FirebaseFirestore.instance
            .collection('users')
            .where('farmName', isEqualTo: farmName)
            .get();

        if (mounted) {
          setState(() {
            users = userCollection.docs.map((doc) {
              return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
            }).toList();
            users.removeWhere((user) => user['id'] == currentAdmin!['id']);
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print("Error fetching users: $e");
    }
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'role': newRole,
      });

      // Update the role locally without fetching users again
      setState(() {
        final userIndex = users.indexWhere((user) => user['id'] == userId);
        if (userIndex != -1) {
          users[userIndex]['role'] = newRole; // Update the role in the list
        }
      });
    } catch (e) {
      print("Error updating role: $e");
    }
  }

  Future<void> approveUser(String userId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'status': 'approved',
        'adminEmail': currentAdmin!['email'],
      });

      // Update the user's status locally without fetching users again
      setState(() {
        final userIndex = users.indexWhere((user) => user['id'] == userId);
        if (userIndex != -1) {
          users[userIndex]['status'] = 'approved'; // Update status in the list
        }
      });

      notifyUser(context);
    } catch (e) {
      print("Error approving user: $e");
    }
  }

  void notifyUser(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("User has been approved!")),
    );
  }

  Future<void> denyUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'status': 'denied',
      });

      // Update the user's status locally without fetching users again
      setState(() {
        final userIndex = users.indexWhere((user) => user['id'] == userId);
        if (userIndex != -1) {
          users[userIndex]['status'] = 'denied'; // Update status in the list
        }
      });
    } catch (e) {
      print("Error denying user: $e");
    }
  }

  void showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user['email']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Farm Name: ${user['farmName']}"),
              Text("Role: ${user['role']}"),
              Text("Status: ${user['status']}"),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: user['status'] == 'pending' ||
                            user['status'] == 'denied'
                        ? () {
                            approveUser(user['id'], context);
                            Navigator.of(context).pop();
                          }
                        : null,
                    child: Text("Approve"),
                  ),
                  ElevatedButton(
                    onPressed: user['status'] == 'approved'
                        ? () {
                            denyUser(user['id']);
                            Navigator.of(context).pop();
                          }
                        : null,
                    child: Text("Deny"),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text('Admin Dashboard'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade200, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (currentAdmin != null) ...[
                      Card(
                        color: Colors.lightBlue.shade100,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Admin:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              SizedBox(height: 8),
                              Text("Email: ${currentAdmin!['email']}",
                                  style: TextStyle(fontSize: 16)),
                              Text("Farm: ${currentAdmin!['farmName']}",
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                    Expanded(
                      child: ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user['email'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  SizedBox(height: 4),
                                  Text("Role: ${user['role']}",
                                      style: TextStyle(fontSize: 14)),
                                  Text("Status: ${user['status']}",
                                      style: TextStyle(fontSize: 14)),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.info),
                                        onPressed: () => showUserDetails(user),
                                      ),
                                      DropdownButton<String>(
                                        value: user['role'],
                                        items: getAllRoles()
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            updateUserRole(
                                                user['id'], newValue);
                                          }
                                        },
                                        icon: Icon(Icons.arrow_drop_down),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
