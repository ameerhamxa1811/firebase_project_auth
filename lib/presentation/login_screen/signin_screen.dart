import 'dart:ui';
import 'package:firebase_project/presentation/login_screen/provider/signin_provider.dart';
import 'package:firebase_project/presentation/signup_screen/provider/signup_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home_screen.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textformfield.dart';
import '../../widgets/customtextfield.dart';
import '../../widgets/social_button_row.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SignInProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.center,
            colors: [Color(0xFF211326), Color(0xFF140119)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/login_Illustration.png',
              fit: BoxFit.fitWidth,
              width: double.infinity,
              height: 300,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
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
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            text: 'Welcome Back!',
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 35,
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            text: 'Sign in to continue',
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
                            label: 'Password',
                            hintText: '•••••••',
                            iconPath: 'assets/images/password_icon.png',
                            obscureText: true,
                            controller: passwordController,
                          ),
                          const SizedBox(height: 20),
                          // Show loading indicator if login is in progress
                          provider.isLoading
                              ? Center(child: CircularProgressIndicator())
                              : CustomButton(
                            text: 'Sign in',
                            onPressed: () async {
                              // Set loading state to true
                              provider.setLoading(true);
                              // Call the login function when the button is pressed
                              String res = await provider.loginUser(
                                email: emailController.text,
                                password: passwordController.text,
                                context: context,
                              );

                              // Handle the response after login attempt
                              if (res == "Login successful!") {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) => HomeScreen()),
                                );
                              } else {
                                // Show the error message from the login function
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(res)),
                                );
                              }

                              // Set loading state to false
                              provider.setLoading(false);
                            },
                          ),
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
                                'Or sign in with',
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
                              // Handle Google sign-in
                            },
                            onApplePressed: () {
                              // Handle Apple sign-in
                            },
                            onFacebookPressed: () {
                              // Handle Facebook sign-in
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
