import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SocialButtonRow extends StatelessWidget {
  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;
  final VoidCallback onFacebookPressed;

  const SocialButtonRow({
    Key? key,
    required this.onGooglePressed,
    required this.onApplePressed,
    required this.onFacebookPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SocialButton(
          imagePath: 'assets/images/google_image.png',
          onPressed: onGooglePressed,
        ),
        SizedBox(width: 10.w),
        SocialButton(
          imagePath: 'assets/images/apple_image.png',
          onPressed: onApplePressed,
        ),
        SizedBox(width: 10.w),
        SocialButton(
          imagePath: 'assets/images/facebook_image.png',
          onPressed: onFacebookPressed,
        ),
      ],
    );
  }
}

class SocialButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;

  const SocialButton({super.key, required this.imagePath, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60.w,
        height: 60.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF181419), Color(0xFF2b0a37)],
          ),
          borderRadius: BorderRadius.circular(12).w,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0).w,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.0).w,
              ),
              child: Center(
                child: Image.asset(
                  imagePath,
                  width: 30.w,
                  height: 30.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
