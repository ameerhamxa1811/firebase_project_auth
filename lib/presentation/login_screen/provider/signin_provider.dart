import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/local_storage.dart';

class SignInProvider with ChangeNotifier {
  bool _isLoading = false;
  final LocalStorage _localStorage = LocalStorage();

  bool get isLoading => _isLoading;

  // Method to update the loading state
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<String> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    // Input validation
    if (email.isEmpty) {
      return "Email cannot be empty.";
    }
    if (password.isEmpty) {
      return "Password cannot be empty.";
    }
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)) {
      return "Please enter a valid email address.";
    }

    try {
      setLoading(true); // Show loading state

      // Sign in with email and password
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      // Ensure the user document exists in Firestore
      if (!userDoc.exists) {
        return "User data not found. Please contact support.";
      }

      // Save the user details in local storage
      await _localStorage.saveUserDetails(
        userCredential.user!.displayName ?? 'No Name',
        email,
        userCredential.user!.uid,
      );

      // Check if the email is verified
      if (userCredential.user?.emailVerified == true) {
        return "Login successful!";
      } else {
        return "Please verify your email before logging in.";
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase exceptions
      switch (e.code) {
        case 'user-not-found':
          return "No user found for that email.";
        case 'wrong-password':
          return "Wrong password provided for that user.";
        case 'invalid-email':
          return "The email address is not valid.";
        case 'user-disabled':
          return "This user account has been disabled.";
        default:
          return "Error during login: ${e.message}";
      }
    } catch (e) {
      return "An unknown error occurred.";
    } finally {
      setLoading(false); // Hide loading state
    }
  }
}
