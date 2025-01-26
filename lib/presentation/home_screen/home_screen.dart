import 'package:firebase_project/presentation/login_screen/signin_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';
  String userEmail = '';
  String userUid = '';

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userName = prefs.getString('userName') ?? 'No Name';
      userEmail = prefs.getString('userEmail') ?? 'No Email';
      userUid = prefs.getString('userUid') ?? 'No UID';
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignInScreen()));
  }

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: userName.isEmpty
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome $userName', style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text('Email: $userEmail', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('UID: $userUid', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            // Logout Button
            ElevatedButton(
              onPressed: _logout,
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
