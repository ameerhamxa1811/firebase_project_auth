import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_project/presentation/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Initialize Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        debugPrint("Google Sign-In was cancelled.");
        return;
      }

      // Authenticate with Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Get credentials to sign in with Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        debugPrint("Firebase Sign-In successful!");
        debugPrint("User Email: ${firebaseUser.email}");
        debugPrint("User Name: ${firebaseUser.displayName}");
        debugPrint("User Photo: ${firebaseUser.photoURL}");

        // Check if user exists in Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (!userDoc.exists) {
          // Add new user to Firestore if not present
          await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .set({
            'name': firebaseUser.displayName ?? 'No Name',
            'email': firebaseUser.email,
            'photoUrl': firebaseUser.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
          });
          debugPrint("New user added to Firestore.");
        }

        // Save user details locally
        await _localStorage.saveUserDetails(
          firebaseUser.displayName ?? 'No Name',
          firebaseUser.email ?? 'No Email',
          firebaseUser.uid,
        );

        // Navigate to the Home Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (error) {
      debugPrint("Google Sign-In Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Google Sign-In failed. Please try again.")),
      );
    }
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
