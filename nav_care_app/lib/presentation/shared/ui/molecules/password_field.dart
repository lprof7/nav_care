import 'package:flutter/material.dart';
import '../atoms/app_text_field.dart';

class PasswordField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;

  const PasswordField({
    super.key,
    required this.hintText,
    this.controller,
    this.validator,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      hintText: widget.hintText,
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _obscureText,
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
        ),
        onPressed: _toggleVisibility,
      ),
    );
  }
}
