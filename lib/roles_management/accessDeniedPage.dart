import 'package:flutter/material.dart';

class AccessDeniedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Access Denied')),
      body: Center(
        child: Text('You do not have permission to access this page.'),
      ),
    );
  }
}
