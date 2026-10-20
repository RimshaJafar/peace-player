import 'package:flutter/material.dart';
import 'package:ecommerce_app/common/widgets/auth/input_decorations.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool isRequired;

  const AuthTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.validator,
    this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return AuthFieldBox(
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(
          color: Color(0xFF4E5661),
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecorations.authInputDecoration(
          context: context,
          label: label,
          hint: hint,
          prefix: prefixIcon,
          isRequired: isRequired,
        ),
      ),
    );
  }
}
