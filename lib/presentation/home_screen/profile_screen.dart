import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_project/presentation/login_screen/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = '';
  String userEmail = '';
  String userUid = '';
  String userPhotoUrl = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'No Name';
      userEmail = prefs.getString('userEmail') ?? 'No Email';
      userUid = prefs.getString('userUid') ?? 'No UID';
      userPhotoUrl = prefs.getString('userPhotoUrl') ?? '';
    });
    _nameController.text = userName;
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final User? user = _auth.currentUser;
      if (user == null) return;

      // Update Firebase Auth
      await user.updateDisplayName(_nameController.text);

      // Update Firestore
      Map<String, dynamic> updateData = {
        'name': _nameController.text,
      };

      // Upload image only if a new image is selected
      if (_selectedImage != null) {
        String imageUrl = await _uploadImage();
        updateData['photoUrl'] = imageUrl;
      }

      await _firestore.collection('users').doc(user.uid).update(updateData);

      // Update local storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text);
      if (_selectedImage != null) {
        await prefs.setString('userPhotoUrl', await _uploadImage());
      }

      setState(() {
        userName = _nameController.text;
        if (_selectedImage != null) {
          userPhotoUrl = prefs.getString('userPhotoUrl')!;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String> _uploadImage() async {
    try {
      if (_selectedImage == null) {
        throw Exception('No image selected.');
      }

      // Ensure the file exists
      if (!await _selectedImage!.exists()) {
        throw Exception('Selected image file does not exist.');
      }

      // Create a reference to the file in Firebase Storage
      final ref = _storage.ref().child('user_images/$userUid.jpg');

      // Upload the file
      await ref.putFile(_selectedImage!);

      // Get the download URL
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Compress image to reduce size
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    if (_isLoggingOut) return; // Prevent multiple clicks

    setState(() {
      _isLoggingOut = true;
    });

    try {
      // Sign out from Firebase
      await _auth.signOut();

      // Sign out from Google (if using Google Sign-In)
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
        await _googleSignIn.disconnect().catchError((error) {
          // Handle disconnect errors gracefully
          debugPrint('Google Sign-In disconnect error: $error');
        });
      }

      // Clear local preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout successful!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to the login screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    } catch (e) {
      // Show error message if logout fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoggingOut = false;
      });
    }
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : userPhotoUrl.isNotEmpty
                        ? NetworkImage(userPhotoUrl)
                        : null,
                    child: _selectedImage == null && userPhotoUrl.isEmpty
                        ? const Icon(Icons.camera_alt, size: 40)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context);
                _updateProfile();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditProfileDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: userPhotoUrl.isNotEmpty
                  ? NetworkImage(userPhotoUrl)
                  : null,
              child: userPhotoUrl.isEmpty
                  ? const Icon(Icons.person, size: 60)
                  : null,
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Name'),
              subtitle: Text(userName),
              leading: const Icon(Icons.person),
            ),
            ListTile(
              title: const Text('Email'),
              subtitle: Text(userEmail),
              leading: const Icon(Icons.email),
            ),
            ListTile(
              title: const Text('User ID'),
              subtitle: Text(userUid),
              leading: const Icon(Icons.fingerprint),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _isLoggingOut ? null : _logout, // Disable button during logout
              icon: _isLoggingOut
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.logout),
              label: Text(_isLoggingOut ? 'Logging out...' : 'Logout'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}