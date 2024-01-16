import 'package:flutter/material.dart';
import 'package:intrst/widgets/auth_form.dart';


class AuthScreen extends StatefulWidget {
  static const routeName = '/auth-screen';

  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login/Signup"),
        centerTitle: true,
      ),
      body: Center(
        child: SizedBox(
          width: deviceSize.width > 600 ? 600 : double.infinity,
          child: const AuthForm()
        )
      ),
    );
  }
}
