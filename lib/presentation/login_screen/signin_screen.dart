import 'dart:ui';
import 'package:firebase_project/presentation/login_screen/provider/signin_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../home_screen/profile_screen.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textformfield.dart';
import '../../widgets/customtextfield.dart';
import '../../widgets/social_button_row.dart';
import '../signup_screen/signup_screen.dart';

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
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.center,
                    colors: [Color(0xFF211326), Color(0xFF140119)],
                  ),
                ),
              ),
              // Main content
              SafeArea(
                child: SingleChildScrollView(
                  child: IntrinsicHeight(
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
                                'assets/images/login_Illustration.png',
                                fit: BoxFit.fill,
                                // width: double.infinity,
                                height: 200.h,
                              ),
                            ],
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              height: 550.h,
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
                                  topRight: Radius.circular(50.r)
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(30.0).w,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomTextField(
                                      text: 'Welcome Back!',
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontSize: 35.sp,
                                    ),
                                    SizedBox(height: 1.h),
                                    CustomTextField(
                                      text: 'Sign in to continue',
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
                                      label: 'Password',
                                      hintText: '•••••••',
                                      iconPath: 'assets/images/password_icon.png',
                                      obscureText: true,
                                      controller: passwordController,
                                    ),
                                    SizedBox(height: 20.h),
                                    provider.isLoading
                                        ? const Center(
                                        child: CircularProgressIndicator())
                                        : CustomButton(
                                      text: 'Sign in',
                                      onPressed: () async {
                                        provider.setLoading(true);
                                        String res = await provider.loginUser(
                                          email: emailController.text,
                                          password: passwordController.text,
                                          context: context,
                                        );

                                        if (res == "Login successful!") {
                                          Navigator.of(context)
                                              .pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  HomeScreen(),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(content: Text(res)),
                                          );
                                        }

                                        provider.setLoading(false);
                                      },
                                    ),
                                    SizedBox(height: 15.h),
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
                                          'Or sign in with',
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
                                      onApplePressed: () {
                                        // Handle Apple sign-in
                                      },
                                      onFacebookPressed: () {
                                        // Handle Facebook sign-in
                                      },
                                    ),
                                SizedBox(height: 15.h,),
                                Center(
                                  child: RichText(
                                    text: TextSpan(
                                      text: "Don't have an account? ",
                                      style: TextStyle(fontSize: 16.sp, color: Colors.white),
                                      children: [
                                      TextSpan(
                                      text: 'Sign Up',
                                      style: TextStyle(fontSize: 16.sp, color: Colors.yellowAccent),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          // Navigate to the SignupScreen
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => SignupScreen()),
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
                    ),
                  ),
                ),
              ),
            ],
          ),
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
