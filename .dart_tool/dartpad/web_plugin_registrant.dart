// Flutter web plugin registrant file.
//
// Generated file. Do not edit.
//

// @dart = 2.13
// ignore_for_file: type=lint

import 'package:cloud_firestore_web/cloud_firestore_web.dart';
import 'package:desktop_webview_auth/desktop_webview_auth_web.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_database_web/firebase_database_web.dart';
import 'package:flutter_facebook_auth_web/flutter_facebook_auth_web.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';
import 'package:location_web/location_web.dart';
import 'package:sign_in_with_apple_web/sign_in_with_apple_web.dart';
import 'package:url_launcher_web/url_launcher_web.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void registerPlugins([final Registrar? pluginRegistrar]) {
  final Registrar registrar = pluginRegistrar ?? webPluginRegistrar;
  FirebaseFirestoreWeb.registerWith(registrar);
  DesktopWebviewAuthWeb.registerWith(registrar);
  FirebaseAuthWeb.registerWith(registrar);
  FirebaseCoreWeb.registerWith(registrar);
  FirebaseDatabaseWeb.registerWith(registrar);
  FlutterFacebookAuthPlugin.registerWith(registrar);
  GoogleMapsPlugin.registerWith(registrar);
  GoogleSignInPlugin.registerWith(registrar);
  LocationWebPlugin.registerWith(registrar);
  SignInWithApplePlugin.registerWith(registrar);
  UrlLauncherPlugin.registerWith(registrar);
  registrar.registerMessageHandler();
}
