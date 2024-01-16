import 'package:flutter/material.dart';
//Firebase (excl. auth)
import 'package:intrst/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intrst/providers/humans.dart';
//Authentication
import 'package:intrst/screens/auth.dart';
import 'package:flutterfire_ui/auth.dart' as ffui;
import 'package:intrst/screens/conversations.dart';
//Screens
import 'package:intrst/screens/map.dart';
import 'package:intrst/screens/my_interests.dart';
import 'package:intrst/screens/my_interests_ordered.dart';
import 'package:intrst/screens/profile.dart';
import 'package:provider/provider.dart';
import 'package:intrst/providers/interests.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

Map<int, Color> color  = {
  50:Color.fromRGBO(2,63,88, .1),
  100:Color.fromRGBO(2,63,88, .2),
  200:Color.fromRGBO(2,63,88, .3),
  300:Color.fromRGBO(2,63,88, .4),
  400:Color.fromRGBO(2,63,88, .5),
  500:Color.fromRGBO(2,63,88, .6),
  600:Color.fromRGBO(2,63,88, .7),
  700:Color.fromRGBO(2,63,88, .8),
  800:Color.fromRGBO(2,63,88, .9),
  900:Color.fromRGBO(2,63,88, 1),
};

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  MaterialColor cPrimary = MaterialColor(0xFF023F58, color);

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Interests(),),
        ChangeNotifierProvider(create: (ctx) => Humans(),),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'intrst',
        theme: ThemeData(
          primarySwatch: cPrimary,
        ),
        initialRoute: '/',
        routes: {
          '/': (ctx) => const MapScreen(),
          '/profile': (context) {
              return ffui.ProfileScreen(
                actions: [
                  ffui.SignedOutAction((context) {
                    Navigator.pushReplacementNamed(context, '/');
                  }),
                ],
                // actionCodeSettings: actionCodeSettings,
              );
          },
          ProfileScreen.routeName: (ctx) => const ProfileScreen(),
          MyInterestsScreen.routeName: (ctx) => const MyInterestsScreen(),
          MyInterestsScreenOrdered.routeName: (ctx) => const MyInterestsScreenOrdered(),
          AuthScreen.routeName: (ctx) => const AuthScreen(),
          ConversationsScreen.routeName: (ctx) => ConversationsScreen(),
        },
        // home: const AuthGate(),
      ),
    );
  }
}