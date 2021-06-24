import 'package:flutter/material.dart';

import 'package:fipro/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import 'package:fipro/config/strings.dart' as strings;

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void logout() async {
    AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('Home'),
            ElevatedButton(
              child: Text(strings.logout, style: TextStyle(fontSize: 20.0)),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0))),
              ),
              onPressed: logout,
            ),
          ],
        ),
      ),
    );
  }
}
