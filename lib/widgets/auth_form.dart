import 'package:flutter/material.dart';
import '../helpers/utilities.dart';
import '../screens/my_interests.dart';
//firebase: authentication and database
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//platform exceptions
import 'package:flutter/services.dart';


class AuthForm extends StatefulWidget {
  const AuthForm({Key? key}) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _auth = FirebaseAuth.instance;
  //Form and data
  final GlobalKey<FormState> _formKey = GlobalKey();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  bool isHidden = true;
  String userEmail = '';
  String userName = '';
  String userPassword = '';
  var userPosition = {
                        'latitude': 37.43296265331129,
                        'longitude': -122.08832357078792,
                      };
  var _isLoginView = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();

    emailController.addListener(onListen);
    nameController.addListener(onListen);
  }

  @override
  void dispose() {
    emailController.dispose();
    emailController.removeListener(onListen);
    nameController.dispose();
    nameController.removeListener(onListen);
    passwordController.dispose();

    super.dispose();
  }

  void onListen() => setState(() {});

  void togglePasswordVisibility() {
    setState(() {
      isHidden = !isHidden;
    });
  }

  void _submit() async {
    UserCredential authResult;
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    try {
      setState((){
        _isLoading = true;
      });
      if (isValid) {
        _formKey.currentState!.save();
        if (_isLoginView) {
          authResult = await _auth.signInWithEmailAndPassword(
              email: userEmail,
              password: userPassword
          );
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/', (route) => false
          );
        } else {
          authResult = await _auth.createUserWithEmailAndPassword(
              email: userEmail,
              password: userPassword
          );
          await FirebaseFirestore.instance
              .collection('humans')
              .doc(authResult.user!.uid)
              .set({
            'name': userName,
            'email': userEmail,
            'interests': [],
            'position': userPosition,
          }).then((value) => Navigator.of(context)
              .pushNamedAndRemoveUntil(
                MyInterestsScreen.routeName, (route) => false
              ));
        }
      }
    } on PlatformException catch (error) {
      String? message = "An error occurred, please check your credentials.";
      if (error.message != null) {
        message = error.message;
      }
      Utils.showSnackBarMessage(context, message!);
      setState((){
        _isLoading = false;
      });
    } catch (error) {
      // print(error);
      Utils.showSnackBarMessage(context, error.toString());
      setState((){
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextFormField(
              key: const ValueKey('email'),
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.mail),
                suffixIcon: emailController.text.isEmpty
                    ? Container(width: 0,)
                    : IconButton(
                  onPressed: () => emailController.clear(),
                  icon: const Icon(Icons.close),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              validator: (String? value) {
                if (!RegExp(
                    r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                    .hasMatch(value!)) {
                  return 'Please enter a valid email address.';
                }
                return null;
              },
              onSaved: (value) {
                userEmail = value!.toLowerCase().trim();
              },
            ),
            const SizedBox(height: 12,),
            if (!_isLoginView)
              TextFormField(
                key: const ValueKey('name'),
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                  suffixIcon: nameController.text.isEmpty
                      ? Container(width: 0,)
                      : IconButton(
                    onPressed: () => nameController.clear(),
                    icon: const Icon(Icons.close),
                  ),
                ),
                autofocus: true,
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name.';
                  }
                  return null;
                },
                onSaved: (value) {
                  userName = value!.trim();
                },
              ),
            if (!_isLoginView)
              const SizedBox(height: 12,),
            TextFormField(
              key: const ValueKey('password'),
              controller: passwordController,
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
              onSaved: (value) {
                userPassword = value!.trim();
              },
            ),
            const SizedBox(height: 24,),
            if (_isLoading)
              const CircularProgressIndicator(),
            if (!_isLoading)
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: _submit,
                  child: Text(
                      _isLoginView ? 'LOGIN' : 'SIGN UP'
                  )
              ),
            const SizedBox(height: 12,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isLoginView
                    ? 'Don\'t have an account?'
                    : 'Already have an account?'
                ),
                TextButton(
                    onPressed: (){
                      setState((){
                        _isLoginView = !_isLoginView;
                      });
                    },
                    child: Text(_isLoginView ? 'SIGN UP' : 'SIGN IN')
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
