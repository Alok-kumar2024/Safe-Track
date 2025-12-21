import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.hint,
    required this.tec,
    this.keyboard = TextInputType.text,
    this.filled = true,
    this.fillColor = const Color(0xFFF9FAFB),
    this.radius = 12,
  });

  final String hint;
  final TextEditingController tec;
  final TextInputType keyboard;
  final bool filled;
  final Color fillColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: tec,
      keyboardType: keyboard,
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF1F2937),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontWeight: FontWeight.w400,
        ),
        filled: filled,
        fillColor: fillColor,
        isDense: true,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(
            color: Color(0xFF9333EA),
            width: 2,
          ),
        ),
      ),
    );
  }
}
