import 'package:flutter/material.dart';


import '../color.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool? readOnly;

  CustomTextField({
    required this.hintText,
    this.isPassword = false,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none, this.readOnly,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = true; // Track password visibility

  @override
  Widget build(BuildContext context) {
    return
      TextFormField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _isObscured : false,
        style: const TextStyle(color: whiteColor),
        validator: widget.validator,
        readOnly: widget.readOnly ?? false,
        keyboardType: widget.keyboardType ?? TextInputType.text,
        textCapitalization: widget.textCapitalization,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: whiteColor54),
          filled: true,
          fillColor: appTextFormColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white70, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white70, width: 1.5),
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
            icon: Icon(
              _isObscured ? Icons.visibility_off : Icons.visibility,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() {
                _isObscured = !_isObscured; // Toggle visibility
              });
            },
          )
              : null, // No suffix icon for non-password fields
        ),
      );
  }
}
