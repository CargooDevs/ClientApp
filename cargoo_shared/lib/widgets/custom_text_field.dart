import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;

  const CustomTextField({super.key, required this.label, this.hint, this.controller, this.prefixIcon, this.obscureText = false, this.keyboardType, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
      const SizedBox(height: 6),
      TextField(controller: controller, obscureText: obscureText, keyboardType: keyboardType, maxLines: maxLines, decoration: InputDecoration(hintText: hint, prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null)),
    ]);
  }
}
