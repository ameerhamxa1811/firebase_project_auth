import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../login_screen/signin_screen.dart';
import '../models/home_screen_model.dart';

class HomeScreenProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  UserModel? _user;
  File? _selectedImage;
  bool _isLoggingOut = false;
  bool _isLoading = false;

  UserModel? get user => _user;
  File? get selectedImage => _selectedImage;
  bool get isLoggingOut => _isLoggingOut;
  bool get isLoading => _isLoading;

  void _showMessage(String message, {bool isError = false}) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  /// Load user details from SharedPreferences
  Future<void> loadUserDetails() async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _user = UserModel(
        uid: prefs.getString('userUid') ?? '',
        name: prefs.getString('userName') ?? 'No Name',
        email: prefs.getString('userEmail') ?? 'No Email',
        photoUrl: prefs.getString('userPhotoUrl') ?? '',
      );
    } catch (e) {
      debugPrint('Error loading user details: ${e.toString()}');
    } finally {
      await Future.delayed(const Duration(seconds: 1));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  /// Update profile with a new name and optionally a new image
  Future<void> updateProfile(String newName) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await currentUser.updateDisplayName(newName);

      Map<String, dynamic> updateData = {'name': newName};

      if (_selectedImage != null) {
        String imageUrl = await _uploadImage(currentUser.uid);
        updateData['photoUrl'] = imageUrl;
      }

      await _firestore.collection('users').doc(currentUser.uid).update(updateData);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', newName);
      if (_selectedImage != null) {
        await prefs.setString('userPhotoUrl', updateData['photoUrl'] as String);
      }

      _user = UserModel(
        uid: currentUser.uid,
        name: newName,
        email: currentUser.email ?? '',
        photoUrl: updateData['photoUrl'] ?? _user!.photoUrl,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
        _showMessage("Profile updated successfully!");
      });
    } catch (e) {
      debugPrint('Error updating profile: ${e.toString()}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMessage("Failed to update profile!", isError: true);
      });
    } finally {
      await Future.delayed(const Duration(seconds: 1));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  /// Upload user profile image to Firebase Storage
  Future<String> _uploadImage(String uid) async {
    try {
      if (_selectedImage == null) throw Exception('No image selected.');

      final ref = _storage.ref().child('user_images/$uid.jpg');
      await ref.putFile(_selectedImage!);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Failed to upload image: ${e.toString()}');
      return _user?.photoUrl ?? ''; // Return old image URL if upload fails
    }
  }

  /// Pick an image from gallery
  Future<void> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        _showMessage("Image selected successfully.");
        notifyListeners();
      } else {
        _showMessage("No image selected.", isError: true);
      }
    } catch (e) {
      _showMessage("Failed to pick image: ${e.toString()}", isError: true);
    }
  }

  /// Logout user and clear data
  Future<void> logout(BuildContext context) async {
    if (_isLoggingOut) return; // Prevent multiple clicks

    _isLoggingOut = true;
    notifyListeners();

    try {
      await _auth.signOut();
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
        await _googleSignIn.disconnect().catchError((error) {
          debugPrint('Google Sign-In disconnect error: $error');
        });
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _user = null;
      _selectedImage = null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMessage("Logged out successfully.");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMessage("Logout error: ${e.toString()}", isError: true);
      });
    } finally {
      await Future.delayed(const Duration(seconds: 3)); // Simulate 3 seconds loading
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isLoggingOut = false;
        notifyListeners();
      });
    }
  }
}