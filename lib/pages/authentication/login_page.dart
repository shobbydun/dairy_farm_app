import 'dart:ui';
import 'package:dairy_harbor/components/my_button.dart';
import 'package:dairy_harbor/components/my_textfield.dart';
import 'package:dairy_harbor/components/square_tile.dart';
import 'package:dairy_harbor/services_functions/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? onTap;

  LoginPage({super.key, this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String _errorMessage = "";

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signUserIn() async {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.green,
          ),
        );
      },
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      final user = userCredential.user;

      if (user != null && mounted) {
        // Fetch user role from Firestore
        final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userSnapshot.exists) {
          String role = userSnapshot['role']; // Get user role
          Navigator.pop(context); // Close loading dialog

          if (role == 'admin') {
            Navigator.pushReplacementNamed(context, '/home'); // Redirect admin to home
          } else {
            Navigator.pushReplacementNamed(context, '/dynamic_role_home'); // Redirect non-admin users
          }
        } else {
          Navigator.pop(context);
          showErrorMessage("User not found in database.");
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showErrorMessage(e.message ?? "An error occurred");
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showErrorMessage("Failed to retrieve user role: ${e.toString()}");
      }
    }
  }

  void forgotPassword() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[300],
          title: const Text("Reset Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter your email address and we'll send you a link to reset your password."),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: "Enter email",
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final email = emailController.text;
                if (email.isEmpty) {
                  if (mounted) {
                    setState(() {
                      _errorMessage = "Email cannot be empty.";
                      emailController.clear();
                    });
                  }
                } else if (!_isValidEmail(email)) {
                  if (mounted) {
                    setState(() {
                      _errorMessage = "Invalid email address.";
                      emailController.clear();
                    });
                  }
                } else {
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                    if (mounted) {
                      Navigator.of(context).pop();
                      showSuccessMessage("Password reset email sent!");
                    }
                  } on FirebaseAuthException catch (e) {
                    if (mounted) {
                      setState(() {
                        _errorMessage = e.message ?? "An error occurred";
                      });
                    }
                  }
                }
              },
              child: const Text("Send"),
            ),
          ],
        );
      },
    );
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return regex.hasMatch(email);
  }

  void showErrorMessage(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 247, 112, 112),
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  void showSuccessMessage(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.green,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/back1.jpeg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Blur effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 120),
                    const SizedBox(height: 20),
                    Text(
                      "Welcome Back🎉\n    Dairy Harbor",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 25),
                    MyTextfield(
                      controller: emailController,
                      hintText: "Email",
                      obscureText: false,
                    ),
                    const SizedBox(height: 10),
                    MyTextfield(
                      controller: passwordController,
                      hintText: "Password",
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: forgotPassword,
                            child: Text(
                              "Forgot password?",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    MyButton(
                      text: "Sign in",
                      onTap: signUserIn,
                    ),
                    const SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey[400],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "Or continue with, ",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey[400],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SquareTile(
                          imagePath: 'assets/google.png',
                          onTap: () => AuthService().signInWithGoogle(),
                        ),
                        const SizedBox(width: 25),
                        SquareTile(
                          imagePath: 'assets/apple.png',
                          onTap: () => AuthService().signInWithApple(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Not a member?",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            "Register now",
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
