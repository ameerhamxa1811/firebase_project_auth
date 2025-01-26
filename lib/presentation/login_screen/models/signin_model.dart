class SignInModel {
  final String email;
  final String password;

  SignInModel({required this.email, required this.password});
  
  bool isValidEmail() {
    return email.contains('@') && email.contains('.');
  }

  bool isValidPassword() {
    return password.length >= 6;
  }
}
