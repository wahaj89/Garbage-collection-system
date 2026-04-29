import 'package:flutter/material.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final CustomButton? button; // 👈 make nullable
  final String? Function(String?)? validator;
  final bool? readOnly; // 👈 new property

  const CustomInput({
    super.key,
    required this.label,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.button,
    this.validator, this.readOnly, 
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFD0E5FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),

        // 👇 priority: button > suffixIcon
        suffixIcon: button != null
            ? Padding(
                padding: const EdgeInsets.all(6),
                child: button,
              )
            : suffixIcon,
      ),
    );
  }
}
