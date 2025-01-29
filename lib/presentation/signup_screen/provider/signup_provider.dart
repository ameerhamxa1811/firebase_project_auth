import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/local_storage.dart';
import '../../login_screen/signin_screen.dart';

class SignUpProvider extends ChangeNotifier {
  final LocalStorage _localStorage = LocalStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get photoUrl => "";

  Future<String> signupUser({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    // Edge case validation
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return "Please fill in all fields.";
    }

    // Email format validation
    RegExp emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(email)) {
      return "Please enter a valid email address.";
    }

    // Password length validation (at least 6 characters for example)
    if (password.length < 6) {
      return "Password must be at least 6 characters long.";
    }

    try {
      // Firebase Authentication signup example
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Update the display name
        await currentUser.updateDisplayName(name);

        // Send a verification email
        await currentUser.sendEmailVerification();

        // Store user details in Firestore
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
          'name': name,
          'email': email,
          'uid': currentUser.uid,
          'createdAt': Timestamp.now(),
        });

        // Save the user details in local storage
        await _localStorage.saveUserDetails(name, email, userCredential.user!.uid, photoUrl);

        // Show a snack bar with a message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verification email sent. Please verify your email before logging in.")),
        );

        // Navigate to login screen immediately after sending verification email
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );

        // Start a timer to check the verification status after 60 seconds
        Timer(Duration(seconds: 60), () async {
          // Reload user to get the latest email verification status
          await currentUser.reload();

          // Check if the user has verified their email within 60 seconds
          if (currentUser.emailVerified) {
            // If verified, navigate to the login screen
          } else {
            // If email not verified within 60 seconds, show an expiration message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Verification email expired. Please try again.")),
            );
          }
        });

        return "Verification email sent. Please verify your email before logging in.";
      } else {
        return "Failed to create user.";
      }
    } catch (e) {
      // Handle Firebase-specific errors
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          return "This email is already in use. Please try another one.";
        } else if (e.code == 'weak-password') {
          return "The password is too weak. Please choose a stronger password.";
        } else if (e.code == 'invalid-email') {
          return "The email address is invalid. Please check and try again.";
        } else {
          return "An error occurred: ${e.message}";
        }
      }
      print("Error during signup: $e");
      return e.toString(); // Return the error as a string
    }
  }
}
