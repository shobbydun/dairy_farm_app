import 'package:dairy_harbor/pages/authentication/login_page.dart';
import 'package:dairy_harbor/pages/authentication/register_page.dart';
import 'package:flutter/material.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {

  //initially show login page at satrt
  bool showLoginPage = true;

  //toggle btwn login and register page
  void togglePages(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(showLoginPage){
      return LoginPage(onTap: togglePages);
    } else{
      return RegisterPage(
        onTap: togglePages,
      );
    }
  }
}