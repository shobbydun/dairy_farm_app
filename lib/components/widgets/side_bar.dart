import 'package:dairy_harbor/services_functions/auth_service.dart';
import 'package:flutter/material.dart';

class SidebarMenu extends StatefulWidget {
  final Function(String) onSelectPage;

  SidebarMenu({required this.onSelectPage});

  @override
  _SidebarMenuState createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  bool isDashboardExpanded = false;
  bool isCattleExpanded = false;
  bool isInventoryExpanded = false;
  bool isMilkExpanded = false;
  bool isProceduresExpanded = false;
  bool isWorkersExpanded = false;
  bool isAuthExpanded = false; // Add this to manage auth section expansion

  final AuthService _authService = AuthService(); // Initialize AuthService

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/download.png'), // Replace with your image path
              ),
            ),
            const Text(
              'Munei Farm', // Replace with dynamic value
              style: TextStyle(
                fontFamily: 'Times New Roman',
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildExpandableMenuItem(
                    icon: Icons.dashboard,
                    text: 'Dashboard',
                    isExpanded: isDashboardExpanded,
                    onTap: () {
                      setState(() {
                        isDashboardExpanded = !isDashboardExpanded;
                      });
                    },
                    children: [
                      _buildSubMenuItem(
                        text: 'Home',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/home');
                        },
                      ),
                    ],
                  ),
                  _buildExpandableMenuItem(
                    icon: Icons.pets,
                    text: 'Cattle',
                    isExpanded: isCattleExpanded,
                    onTap: () {
                      setState(() {
                        isCattleExpanded = !isCattleExpanded;
                      });
                    },
                    children: [
                      _buildSubMenuItem(
                        text: 'Cattle Profile',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/cattleProfile'); // Ensure you have a route for this
                        },
                      ),
                      _buildSubMenuItem(
                        text: 'Cattle List Page',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/cattleListPage'); // Ensure you have a route for this
                        },
                      ),
                      _buildSubMenuItem(
                        text: 'Cattle Form',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/cattleForm'); // Ensure you have a route for this
                        },
                      ),
                    ],
                  ),
                  // _buildExpandableMenuItem(
                  //   icon: Icons.medical_services,
                  //   text: 'Treatment',
                  //   isExpanded: false,
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //     Navigator.pushNamed(context, '/treatment');
                  //   },
                  // ),
                  _buildExpandableMenuItem(
                    icon: Icons.bar_chart,
                    text: 'Reports',
                    isExpanded: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/reports');
                    },
                  ),
                  _buildExpandableMenuItem(
                    icon: Icons.inventory,
                    text: 'Inventory',
                    isExpanded: isInventoryExpanded,
                    onTap: () {
                      setState(() {
                        isInventoryExpanded = !isInventoryExpanded;
                      });
                    },
                    children: [
                      _buildSubMenuItem(
                        text: 'Admin Wages',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/adminWages');
                        },
                      ),
                      _buildSubMenuItem(
                        text: 'Farm Machinery',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/machinery');
                        },
                      ),
                      _buildSubMenuItem(
                        text: 'Feeds',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/feeds');
                        },
                      ),
                      _buildSubMenuItem(
                        text: 'Inventory Main',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/inventory');
                        },
                      ),
                      _buildSubMenuItem(
                        text: 'Medicine',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/medicine');
                        },
                      ),
                      _buildSubMenuItem(
                        text: 'Notification',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/notification');
                        },
                      ),
                      _buildSubMenuItem(
                        text: 'User Profile',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/userProfile');
                        },
                      ),
                    ],
                  ),
                  _buildExpandableMenuItem(
                    icon: Icons.local_drink,
                    text: 'Milk',
                    isExpanded: isMilkExpanded,
                    onTap: () {
                      setState(() {
                        isMilkExpanded = !isMilkExpanded;
                      });
                    },
                    children: [
                      _buildSubMenuItem(
                        text: 'Daily Production',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/dailyProduction');
                        },
                      ),
                      _buildSubMenuItem(
                        text: 'Milk Distribution with Sales',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/milkDistribution');
                        },
                      ),
                    ],
                  ),
                  _buildExpandableMenuItem(
                    icon: Icons.medical_services,
                    text: 'Procedures',
                    isExpanded: isProceduresExpanded,
                    onTap: () {
                      setState(() {
                        isProceduresExpanded = !isProceduresExpanded;
                      });
                    },
                    children: [
                      _buildSubMenuItem(
                        text: 'Artificial Insemination',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/artificialInsemination');
                        },
                      ),
                      _buildSubMenuItem(
                        text: 'Calving',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/calving');
                        },
                      ),
                      _buildSubMenuItem(
                        text: 'Dehorning',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/dehorning');
                        },
                      ),
                      _buildSubMenuItem(
                        text: 'Deworming',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/deworming');
                        },
                      ),
                      _buildSubMenuItem(
                        text: 'Heat Detection',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/heatDetection');
                        },
                      ),
                      _buildSubMenuItem(
                        text: 'Miscarriage',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/miscarriage');
                        },
                      ),
                      _buildSubMenuItem(
                        text: 'Natural Insemination',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/naturalInsemination');
                        },
                      ),
                      _buildSubMenuItem(
                        text: 'Pest Control',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/pestControl');
                        },
                      ),
                      _buildSubMenuItem(
                        text: 'Pregnancy',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/pregnancy');
                        },
                      ),
                      _buildSubMenuItem(
                        text: 'Treatment',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/treatment');
                        },
                      ),
                      _buildSubMenuItem(
                        text: 'Vaccination',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/vaccination');
                        },
                      ),
                    ],
                  ),
                  _buildExpandableMenuItem(
                    icon: Icons.work,
                    text: 'Workers',
                    isExpanded: isWorkersExpanded,
                    onTap: () {
                      setState(() {
                        isWorkersExpanded = !isWorkersExpanded;
                      });
                    },
                    children: [
                      _buildSubMenuItem(
                        text: 'Worker List',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/workerList');
                        },
                      ),
                      _buildSubMenuItem(
                        text: 'Worker Profile',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/workerProfile');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildAuthSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableMenuItem({
    required IconData icon,
    required String text,
    required bool isExpanded,
    required VoidCallback onTap,
    List<Widget>? children,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              if (children != null && children.isNotEmpty)
                Icon(
                  isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.white,
                ),
            ],
          ),
          onTap: onTap,
        ),
        if (isExpanded && children != null)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              children: children,
            ),
          ),
      ],
    );
  }

  Widget _buildSubMenuItem({
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.normal,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.only(left: 24.0),
    );
  }

  Widget _buildAuthSection() {
    return Column(
      children: [
        const Divider(color: Colors.white54),
        ListTile(
          leading: Icon(Icons.person, color: Colors.white),
          title: Text(
            'Authentication',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          onTap: () {
            setState(() {
              isAuthExpanded = !isAuthExpanded;
            });
          },
        ),
        if (isAuthExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              children: [
                _buildSubMenuItem(
                  text: 'Sign Up',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/loginOrRegister');
                  },
                ),
                _buildSubMenuItem(
                  text: 'Register',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/loginOrRegister');
                  },
                ),
                _buildSubMenuItem(
                  text: 'Logout',
                  onTap: () {
                    _showLogoutConfirmationDialog();
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showLogoutConfirmationDialog() {
    if (!mounted) return; // Check if widget is still mounted

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _logout(); // Implement your logout logic
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    if (!mounted) return; // Check if widget is still mounted

    try {
      await _authService.logout(); // Call the logout function
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/loginOrRegister', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        // Handle any errors that occur during logout
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }
}
