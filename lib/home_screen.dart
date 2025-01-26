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

  // Method to load user details from local storage
  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the user details
    setState(() {
      userName = prefs.getString('userName') ?? 'No Name';
      userEmail = prefs.getString('userEmail') ?? 'No Email';
      userUid = prefs.getString('userUid') ?? 'No UID';
    });
  }

  // Method to logout the user
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Clear the user details from local storage
    await prefs.clear();

    // Navigate back to the login screen (assuming it's named LoginScreen)
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignInScreen()));
  }

  @override
  void initState() {
    super.initState();
    _loadUserDetails();  // Load user details when the screen is created
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: userName.isEmpty
            ? CircularProgressIndicator()  // Show loading indicator while fetching data
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
