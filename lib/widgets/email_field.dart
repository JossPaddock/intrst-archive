import 'package:flutter/material.dart';


class EmailField extends StatefulWidget {
  final TextEditingController emailController;
  String userEmail;

  EmailField({
    Key? key,
    required this.emailController,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<EmailField> createState() => _EmailFieldState();
}

class _EmailFieldState extends State<EmailField> {

  @override
  void initState() {
    super.initState();

    widget.emailController.addListener(onListen);
  }

  @override
  void dispose() {
    widget.emailController.removeListener(onListen);
    super.dispose();
  }

  void onListen() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.emailController,
      decoration: InputDecoration(
        hintText: 'Email',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.mail),
        suffixIcon: widget.emailController.text.isEmpty
          ? Container(width: 0,)
          : IconButton(
              onPressed: () => widget.emailController.clear(),
              icon: const Icon(Icons.close),
            ),
      ),
      keyboardType: TextInputType.emailAddress,
      autofocus: true,
      validator: (String? value) {
        if (!RegExp(
            r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
            .hasMatch(value!)) {
          return 'E-mail invalid!';
        }
        return null;
      },
      onSaved: (value) {
        widget.userEmail = value!;
        print(widget.userEmail);
      },
    );
  }
}
