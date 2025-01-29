import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_project/presentation/home_screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      setLoading(true);

      // Initialize Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Google Sign-In was cancelled."),
            backgroundColor: Colors.orange,
          ),
        );
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
        }

        // Save user details locally
        await _localStorage.saveUserDetails(
          firebaseUser.displayName ?? 'No Name',
          firebaseUser.email ?? 'No Email',
          firebaseUser.uid,
          firebaseUser.photoURL ?? '',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Sign-In successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to the Profile Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
      }
    } catch (error) {
      debugPrint("Google Sign-In Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Google Sign-In failed: ${error.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setLoading(false);
    }
  }

  Future<String> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    // Input validation
    if (email.isEmpty || password.isEmpty) {
      return "Please fill in all fields.";
    }

    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)) {
      return "Please enter a valid email address.";
    }

    if (password.length < 6) {
      return "Password must be at least 6 characters.";
    }

    try {
      setLoading(true);

      // Sign in with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        return "User data not found. Please contact support.";
      }

      // Save the user details in local storage
      await _localStorage.saveUserDetails(
        userCredential.user!.displayName ?? 'No Name',
        email,
        userCredential.user!.uid,
        userCredential.user!.photoURL ?? '',
      );

      // Check email verification
      if (!userCredential.user!.emailVerified) {
        return "Please verify your email before logging in.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to profile screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );

      return "Login successful!";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return "No user found for this email.";
        case 'wrong-password':
          return "Incorrect password.";
        case 'invalid-email':
          return "Invalid email format.";
        case 'user-disabled':
          return "This account has been disabled.";
        case 'too-many-requests':
          return "Too many attempts. Try again later.";
        default:
          return "Login failed: ${e.message}";
      }
    } catch (e) {
      return "An unexpected error occurred: ${e.toString()}";
    } finally {
      setLoading(false);
    }
  }
}