import 'package:flutter/material.dart';


class PasswordField extends StatefulWidget {
  final TextEditingController passwordController;

  const PasswordField({
    Key? key,
    required this.passwordController
  }) : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool isHidden = true;

  void togglePasswordVisibility() {
    setState(() {
      isHidden = !isHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.passwordController,
      obscureText: isHidden,
      decoration: InputDecoration(
        hintText: isHidden ? 'Password' : 'Password',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
              isHidden ? Icons.visibility_off : Icons.visibility
          ),
          onPressed: togglePasswordVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
