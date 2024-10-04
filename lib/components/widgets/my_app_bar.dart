import 'package:dairy_harbor/pages/inventory/user_profile.dart';
import 'package:dairy_harbor/services_functions/auth_service.dart';
import 'package:flutter/material.dart';

class CustomNavbar extends StatelessWidget implements PreferredSizeWidget {
  final AuthService _authService = AuthService(); // Initializing AuthService

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.lightBlueAccent,
      elevation: 4.0,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      title: const Text('Dashboard'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
        ),
        PopupMenuButton(
          icon: Icon(Icons.person_3),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('My Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfile(),
                    ),
                  );
                },
              ),
            ),
            PopupMenuItem(
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Edit Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(),
                    ),
                  );
                },
              ),
            ),
            PopupMenuItem(
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Log Out'),
                onTap: () async {
                  Navigator.pop(context);

                  final bool? confirmLogout = await showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Log Out'),
                        content:
                            const Text('Are you sure you want to log out?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: const Text('Log Out'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmLogout == true) {
                    try {
                      await _authService.logout();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Logged out successfully'),
                        ),
                      );

                      // Redirect to login page
                      Navigator.of(context)
                          .pushReplacementNamed('/loginOrRegister');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error logging out: $e'),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
