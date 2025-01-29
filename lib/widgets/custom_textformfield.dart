import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextFormField extends StatelessWidget {
  final String label;
  final String iconPath;
  final String? hintText;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final TextEditingController controller;  // Added controller parameter

  const CustomTextFormField({
    super.key,
    required this.label,
    required this.iconPath,
    this.hintText,
    this.obscureText = false,
    this.onChanged,
    required this.controller, // Accept the controller
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,  // Use the controller for managing input
      style: const TextStyle(color: Colors.white),
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        label: Padding(
          padding: EdgeInsets.only(bottom: 25).r,
          child: Text(label),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10.0).w,
          child: Image.asset(
            iconPath,
            width: 20.w,
            height: 20.h,
          ),
        ),
        filled: true,
        fillColor: const Color(0x33FFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11.0).w,
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
