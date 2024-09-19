import 'package:dairy_harbor/services_functions/auth_service.dart';
import 'package:dairy_harbor/services_functions/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  bool isAuthExpanded = false;

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreServices>(context);

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
            FutureBuilder<Map<String, dynamic>?>(
              future: firestoreService.getProfile(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.green,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Error loading profile',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blueAccent,
                    ),
                  );
                }

                final profile = snapshot.data;
                final profileImageUrl = profile?['profileImage'] as String?;
                final fullName = profile?['farmName'] as String? ?? 'User';

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: profileImageUrl != null
                            ? NetworkImage(profileImageUrl)
                            : AssetImage('assets/download.png')
                                as ImageProvider,
                      ),
                    ),
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontFamily: 'Times New Roman',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
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
                        text: 'Cattle List Page',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/cattleListPage');
                        },
                      ),
                      _buildSubMenuItem(
                        text: 'Cattle Form',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/cattleForm');
                        },
                      ),
                    ],
                  ),
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
                        text: 'Inventory Main',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/inventory');
                        },
                      ),
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
                        text: 'Medicine',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/medicine');
                        },
                      ),
                      // _buildSubMenuItem(
                      //   text: 'Notification',
                      //   onTap: () {
                      //     Navigator.pop(context);
                      //     Navigator.pushNamed(context, '/notification');
                      //   },
                      // ),
                      // _buildSubMenuItem(
                      //   text: 'User Profile',
                      //   onTap: () {
                      //     Navigator.pop(context);
                      //     Navigator.pushNamed(context, '/userProfile');
                      //   },
                      // ),
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
                          Navigator.pushNamed(
                              context, '/artificialInsemination');
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
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _logout();
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    if (!mounted) return;

    try {
      await _authService.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/loginOrRegister', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }
}
