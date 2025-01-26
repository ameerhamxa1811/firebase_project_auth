import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textformfield.dart';
import '../../widgets/customtextfield.dart';
import '../../widgets/social_button_row.dart';
import '../login_screen/signin_screen.dart';
import '../signup_screen/provider/signup_provider.dart';

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
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final authProvider = Provider.of<SignUpProvider>(context, listen: false);
    String res = await authProvider.signupUser(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      context: context,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Gradient Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.center,
                  colors: [Color(0xFF211326), Color(0xFF140119)],
                ),
              ),
            ),
            // Main Content
            SafeArea(
              child: SingleChildScrollView(
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
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Image.asset(
                              'assets/images/sign_up_ilustration.png',
                              fit: BoxFit.fill,
                              height: 200,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        // Form Container
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
                          child: Padding(
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
                                  const SizedBox(height: 10),
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
                                  isLoading
                                      ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                      : CustomButton(
                                    text: 'Sign up',
                                    onPressed: signupUser,
                                  ),
                                  if (errorMessage.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Text(
                                        errorMessage,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 15),
                                  Row(
                                    children: [
                                      const Expanded(
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
                                      const Expanded(
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
                                    onGooglePressed: () {},
                                    onApplePressed: () {},
                                    onFacebookPressed: () {},
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                   ]
                  )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
