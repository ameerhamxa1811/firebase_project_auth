import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  // Save user details
  Future<void> saveUserDetails(String name, String email, String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
    await prefs.setString('userUid', uid);
  }

  // Retrieve user details
  Future<Map<String, String?>> getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('userName');
    String? email = prefs.getString('userEmail');
    String? uid = prefs.getString('userUid');

    return {
      'name': name,
      'email': email,
      'uid': uid,
    };
  }

  // Clear user details
  Future<void> clearUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userUid');
  }
}
