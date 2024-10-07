import 'package:dairy_harbor/pages/authentication/login_or_register_page.dart';
import 'package:dairy_harbor/pages/dashboard/home_page.dart';
import 'package:dairy_harbor/roles_management/PendingApprovalPage.dart';
import 'package:dairy_harbor/roles_management/dynamic_role_home.dart';
import 'package:dairy_harbor/services_functions/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthPage extends StatelessWidget {
  AuthPage({super.key});

  Future<String?> getAdminEmailFromFirestore() async {
    try {
      final adminSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();

      if (adminSnapshot.docs.isNotEmpty) {
        return adminSnapshot.docs.first['email'];
      }
      print("No admin found");
    } catch (e) {
      print("Error fetching admin email: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            final User? user = snapshot.data;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError) {
                  print("Error fetching user data: ${userSnapshot.error}");
                  return Center(child: Text("Error fetching user data."));
                }

                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  print("User Data: $userData");

                  String role = userData['role'] ?? 'undefined';
                  String status = userData['status'] ?? 'undefined';
                  final adminEmailFuture = getAdminEmailFromFirestore();

                  if (role == 'admin') {
                    print("Admin user detected.");
                    return HomePage(
                      animate: true,
                      firestoreServices: FirestoreServices(user.uid, adminEmailFuture), // Fixed: pass both arguments
                      user: user,
                      userId: user.uid,
                      adminEmailFuture: adminEmailFuture,
                    );
                  } else if (status == 'approved') {
                    print("Approved non-admin user detected.");
                    return DynamicRoleHome();
                  } else {
                    print("User is pending approval.");
                    return PendingApprovalPage();
                  }
                } else {
                  print("User data does not exist, redirecting to login/register.");
                  return LoginOrRegisterPage();
                }
              },
            );
          } else {
            return LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
