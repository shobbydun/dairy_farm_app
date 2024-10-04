import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'dynamic_role_home.dart'; // Ensure you import your DynamicRoleHome page

class PendingApprovalPage extends StatefulWidget {
  @override
  _PendingApprovalPageState createState() => _PendingApprovalPageState();
}

class _PendingApprovalPageState extends State<PendingApprovalPage>
    with SingleTickerProviderStateMixin {
  bool _isChecking = false; // To track the loading state
  bool _isApproved = false; // To track approval status
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller for the rotating icon
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // Repeat the animation indefinitely
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up the controller
    super.dispose();
  }

  Future<void> _checkUserApproval() async {
    setState(() {
      _isChecking = true; // Start loading
    });

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userSnapshot.exists) {
        var userData = userSnapshot.data() as Map<String, dynamic>;
        _isApproved = userData['status'] == 'approved';
      }
    }

    setState(() {
      _isChecking = false; // End loading
    });

    if (_isApproved) {
      // Navigate to the DynamicRoleHome page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DynamicRoleHome(), // Pass any required parameters
        ),
      );
    } else {
      // Show a message indicating they are still pending
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Your request is still pending. Please wait.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Awaiting Approval"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(
                  '/loginOrRegister'); 
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _controller.value * 2.0 * 3.14159,
                          child: Icon(
                            Icons.pending,
                            size: 50,
                            color: Colors.orange,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Your role request is pending approval.",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Please wait for Admin to review your request.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    _isChecking
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _checkUserApproval,
                            child: Text(
                              "Check Status",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              textStyle: TextStyle(fontSize: 18),
                            ),
                          ),
                    SizedBox(height: 20),
                    if (_isApproved) _buildCelebrationAnimation(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the celebration animation when approved
  Widget _buildCelebrationAnimation() {
    return Column(
      children: [
        Text(
          "Congratulations! Your request has been approved!",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        // Simple celebration animation
        AnimatedContainer(
          duration: Duration(seconds: 5),
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.yellow,
          ),
          child: Icon(
            Icons.star,
            color: Colors.white,
            size: 50,
          ),
        ),
      ],
    );
  }
}
