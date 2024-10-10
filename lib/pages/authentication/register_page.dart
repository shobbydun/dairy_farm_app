import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dairy_harbor/components/my_button.dart';
import 'package:dairy_harbor/components/my_textfield.dart';
import 'package:dairy_harbor/roles_management/PendingApprovalPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;

  RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String selectedRole = 'staff';
  String? selectedFarmName; // Changed from selectedFarmId to selectedFarmName
  List<Map<String, dynamic>> farms = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchFarms();
  }

  Future<void> fetchFarms() async {
    setState(() {
      isLoading = true;
    });
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('farms').get();
      farms = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'farmName': doc['farmName'],
          'adminEmail': doc['adminEmail'],
        };
      }).toList();
    } catch (e) {
      print("Error fetching farms: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUserUp() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (passwordController.text == confirmPasswordController.text) {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        String userId = userCredential.user?.uid ?? '';
        if (userId.isNotEmpty) {
          await FirebaseFirestore.instance.collection('users').doc(userId).set({
            'email': emailController.text,
            'farmName': selectedFarmName,
            'role': selectedRole,
            'status': 'pending',
          }, SetOptions(merge: true));
        }

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PendingApprovalPage(),
            ),
          );
        }
      } else {
        if (mounted) {
          showErrorMessage("Passwords don't match❌");
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        showErrorMessage(e.message ?? 'An error occurred');
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        showErrorMessage('Firestore error: ${e.message}');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showErrorMessage(String message) {
    if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/back1.jpeg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 90),
                      Text(
                        "W E L C O M E",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 35),
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
                      MyTextfield(
                        controller: confirmPasswordController,
                        hintText: "Confirm Password",
                        obscureText: true,
                      ),
                      const SizedBox(height: 25),

                      // Combined Row for Farm and Role Selection
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Select your farm:",
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButton<String>(
                                    dropdownColor: Colors.grey[600],
                                    hint: Text("Select Farm", style: TextStyle(color: Colors.white)),
                                    value: selectedFarmName,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedFarmName = newValue; // Save selected farmName
                                      });
                                    },
                                    items: farms.map<DropdownMenuItem<String>>((Map<String, dynamic> farm) {
                                      return DropdownMenuItem<String>(
                                        value: farm['farmName'], // Use farmName directly
                                        child: Text(
                                          farm['farmName'],
                                          style: TextStyle(color: Colors.white, fontSize: 16), // Text styling
                                        ),
                                      );
                                    }).toList(),
                                    iconEnabledColor: Colors.white, // Icon color
                                    style: TextStyle(color: Colors.white, fontSize: 16), // Text style
                                    underline: Container(
                                      height: 1,
                                      color: Colors.white, // Underline color
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Select your role:",
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButton<String>(
                                    dropdownColor: Colors.grey[600],
                                    value: selectedRole,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedRole = newValue!;
                                      });
                                    },
                                    items: <String>[
                                      'manager', 'staff', 'operator', 'milkman',
                                      'veterinarian', 'maintenance', 'sales', 'hr', 'analyst',
                                    ].map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: TextStyle(color: Colors.white, fontSize: 16), // Text styling
                                        ),
                                      );
                                    }).toList(),
                                    iconEnabledColor: Colors.white, // Icon color
                                    style: TextStyle(color: Colors.white, fontSize: 16), // Text style
                                    underline: Container(
                                      height: 1,
                                      color: Colors.white, // Underline color
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 35),
                      MyButton(
                        text: "Sign up",
                        onTap: signUserUp,
                      ),
                      const SizedBox(height: 50),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      //   child: Row(
                      //     children: [
                      //       Expanded(
                      //         child: Divider(
                      //           thickness: 0.5,
                      //           color: Colors.grey[400],
                      //         ),
                      //       ),
                      //       Padding(
                      //         padding: const EdgeInsets.symmetric(horizontal: 10),
                      //         child: Text(
                      //           "Or continue with, ",
                      //           style: TextStyle(color: Colors.white),
                      //         ),
                      //       ),
                      //       Expanded(
                      //         child: Divider(
                      //           thickness: 0.5,
                      //           color: Colors.grey[400],
                      //         ),
                      //       )
                      //     ],
                      //   ),
                      // ),
                      // const SizedBox(height: 20),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     SquareTile(
                      //       imagePath: 'assets/google.png',
                      //       onTap: () => AuthService().signInWithGoogle(),
                      //     ),
                      //     const SizedBox(width: 25),
                      //     SquareTile(
                      //       imagePath: 'assets/apple.png',
                      //       onTap: () => AuthService().signInWithApple(),
                      //     ),
                      //   ],
                      // ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: const Text(
                              "Login now",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.green),
            ),
        ],
      ),
    );
  }
}
