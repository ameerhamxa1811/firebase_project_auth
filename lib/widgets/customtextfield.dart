import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String text;
  final String fontFamily;
  final FontWeight fontWeight;
  final Color color;
  final double fontSize;
  final TextAlign textAlign;

  const CustomTextField({
    super.key,
    required this.text,
    required this.fontFamily,
    required this.fontWeight,
    required this.color,
    required this.fontSize,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontFamily: fontFamily,
          fontWeight: fontWeight,
          color: color,
          fontSize: fontSize,
        ),
      ),
    );
  }
}