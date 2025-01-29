import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textformfield.dart';
import '../../widgets/customtextfield.dart';
import '../../widgets/social_button_row.dart';
import '../login_screen/provider/signin_provider.dart';
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

    final provider = Provider.of<SignInProvider>(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Scaffold(
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
                                height: 200.h,
                              ),
                            ],
                          ),
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
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(50.r),
                                topRight: Radius.circular(50.r),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(30.0).w,
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
                                      fontSize: 35.sp,
                                    ),
                                    CustomTextField(
                                      text: 'Free Forever, No Credit Card Needed',
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey,
                                      fontSize: 13.sp,
                                    ),
                                    SizedBox(height: 30.h),
                                    CustomTextFormField(
                                      label: 'Email Address',
                                      hintText: 'example@domain.com',
                                      iconPath: 'assets/images/mail_icon.png',
                                      controller: emailController,
                                    ),
                                    SizedBox(height: 20.h),
                                    CustomTextFormField(
                                      label: 'Your Name',
                                      hintText: 'John Wick',
                                      iconPath: 'assets/images/name_icon.png',
                                      controller: nameController,
                                    ),
                                    SizedBox(height: 20.h),
                                    CustomTextFormField(
                                      label: 'Password',
                                      hintText: '•••••••',
                                      iconPath: 'assets/images/password_icon.png',
                                      obscureText: true,
                                      controller: passwordController,
                                    ),
                                    SizedBox(height: 20.h),
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
                                        padding: const EdgeInsets.only(top: 10.0).r,
                                        child: Text(
                                          errorMessage,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    SizedBox(height: 10.h),
                                    Row(
                                      children: [
                                        const Expanded(
                                          child: Divider(
                                            color: Colors.grey,
                                            thickness: 1,
                                            indent: 25,
                                          ),
                                        ),
                                        SizedBox(width: 10.w),
                                        const Text(
                                          'Or sign up with',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        SizedBox(width: 10.w),
                                        const Expanded(
                                          child: Divider(
                                            color: Colors.grey,
                                            thickness: 1,
                                            endIndent: 25,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),
                                    SocialButtonRow(
                                      onGooglePressed: () {
                                        provider.signInWithGoogle(context);
                                      },
                                      onApplePressed: () {},
                                      onFacebookPressed: () {},
                                    ),
                                    SizedBox(height: 10.h,),
                                    Center(
                                        child: RichText(
                                            text: TextSpan(
                                                text: "Already have an account? ",
                                                style: TextStyle(fontSize: 16.sp, color: Colors.white),
                                                children: [
                                                  TextSpan(
                                                    text: 'Sign in',
                                                    style: TextStyle(fontSize: 16.sp, color: Colors.yellowAccent),
                                                    recognizer: TapGestureRecognizer()
                                                      ..onTap = () {
                                                        // Navigate to the SignupScreen
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(builder: (context) => SignInScreen()),
                                                        );
                                                      },
                                                  )
                                                ]
                                            )
                                        )
                                    )
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
      ),
    );
  }
}
