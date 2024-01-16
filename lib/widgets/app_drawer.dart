import 'package:flutter/material.dart';
import 'package:intrst/screens/conversations.dart';
import 'package:intrst/screens/my_interests_ordered.dart';
import 'package:intrst/screens/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AppDrawer extends StatelessWidget {
  final User? loggedInUser;

  const AppDrawer({Key? key, required this.loggedInUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Center(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Map'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          if (loggedInUser != null)
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('My Interests'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed(MyInterestsScreenOrdered.routeName);
              },
            ),
          // if (loggedInUser != null)
          //   ListTile(
          //     leading: const Icon(Icons.person),
          //     title: const Text('FFUI Profile'),
          //     onTap: () {
          //       Navigator.of(context).pushReplacementNamed('/profile');
          //     },
          //   ),
          if (loggedInUser != null)
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed(ProfileScreen.routeName);
              },
            ),
          if (loggedInUser != null)
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Conversations'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed(ConversationsScreen.routeName);
              },
            ),
          if (loggedInUser == null)
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Sign-in'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/auth-screen');
              },
            ),
          if (loggedInUser != null)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign-out'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false);
              },
            ),
        ],
      ),
    );
  }
}
