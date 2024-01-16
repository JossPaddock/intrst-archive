import 'package:flutter/material.dart';
//Authentication
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/auth.dart';
//Screens
import 'package:intrst/screens/my_interests.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    const providerConfigs = [EmailProviderConfiguration()];

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SignInScreen(
            providerConfigs: providerConfigs,
          );
        }
        return const MyInterestsScreen();
      },
    );
  }
}
