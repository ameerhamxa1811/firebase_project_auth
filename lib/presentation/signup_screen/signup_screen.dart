import 'dart:ui';

import 'package:firebase_project/presentation/login_screen/signin_screen.dart';
import 'package:firebase_project/presentation/signup_screen/provider/signup_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_textformfield.dart';
import '../../widgets/customtextfield.dart';
import '../../widgets/social_button_row.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String errorMessage = '';

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signupUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final authProvider = Provider.of<AuthService>(context, listen: false);
    String res = await authProvider.signupUser(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text, context: context,
    );

    setState(() {
      isLoading = false;
    });

    if (res == "success") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    } else {
      setState(() {
        errorMessage = res;
      });
      print("Error: $res");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.center,
              colors: [Color(0xFF211326), Color(0xFF140119)],
            ),
          ),
          padding: const EdgeInsets.all(5.0),
          child: Center(
            child: Stack(
              children: [
                Positioned(
                  child: Image.asset(
                    'assets/images/bg_image.png',
                    fit: BoxFit.fill,
                  ),
                ),
                Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Image.asset(
                          'assets/images/sign_up_ilustration.png',
                          fit: BoxFit.cover,
                          height: 200,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.99,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.withOpacity(0.4),
                            Colors.blue.withOpacity(0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(35),
                          topRight: Radius.circular(35),
                        ),
                        child: Stack(
                          children: [
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomTextField(
                                      text: 'Get Started Free',
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontSize: 35,
                                    ),
                                    SizedBox(height: 1),
                                    CustomTextField(
                                      text: 'Free Forever, No Credit Card Needed',
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                    const SizedBox(height: 30),
                                    CustomTextFormField(
                                      label: 'Email Address',
                                      hintText: 'example@domain.com',
                                      iconPath: 'assets/images/mail_icon.png',
                                      controller: emailController,
                                    ),
                                    const SizedBox(height: 20),
                                    CustomTextFormField(
                                      label: 'Your Name',
                                      hintText: 'John Wick',
                                      iconPath: 'assets/images/name_icon.png',
                                      controller: nameController,
                                    ),
                                    const SizedBox(height: 20),
                                    CustomTextFormField(
                                      label: 'Password',
                                      hintText: '•••••••',
                                      iconPath: 'assets/images/password_icon.png',
                                      obscureText: true,
                                      controller: passwordController,
                                    ),
                                    const SizedBox(height: 20),
                                    // Show loading or the button
                                    CustomButton(
                                      text: isLoading ? 'Signing Up...' : 'Sign up',
                                      onPressed: signupUser,
                                    ),
                                    if (errorMessage.isNotEmpty) ...[
                                      SizedBox(height: 10),
                                      Text(
                                        errorMessage,
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 15),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Divider(
                                            color: Colors.grey,
                                            thickness: 1,
                                            indent: 25,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          'Or sign up with',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Divider(
                                            color: Colors.grey,
                                            thickness: 1,
                                            endIndent: 25,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    SocialButtonRow(
                                      onGooglePressed: () {
        
                                      },
                                      onApplePressed: () {
        
                                      },
                                      onFacebookPressed: () {
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
