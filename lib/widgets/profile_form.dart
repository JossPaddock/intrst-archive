import 'package:flutter/material.dart';
import '../helpers/utilities.dart';
import '../screens/my_interests.dart';
//firebase: authentication and database
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//platform exceptions
import 'package:flutter/services.dart';


class ProfileForm extends StatefulWidget {
  const ProfileForm({Key? key}) : super(key: key);

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;

  final GlobalKey<FormState> _formKey = GlobalKey();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isHidden = true;
  String userName = '';
  String userPassword = '';
  var _isLoading = false;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
    nameController.addListener(onListen);
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (error) {
    }
  }

  @override
  void dispose() {
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
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    try {
      if (isValid) {
        setState((){
          _isLoading = true;
        });
        _formKey.currentState!.save();
        if (userPassword != '') {
          loggedInUser!.updatePassword(userPassword).then((_){
            print("Successfully changed password");
          });
        }
        await FirebaseFirestore.instance
            .collection('humans')
            .doc(loggedInUser!.uid)
            .update({
          'name': userName,
        }).then((value) => Navigator.of(context)
            .pushNamedAndRemoveUntil(
            MyInterestsScreen.routeName, (route) => false
        ));
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/', (route) => false
        );
      }
    } on PlatformException catch (error) {
      String? message = "An error occurred.";
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
              key: const ValueKey('name'),
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'New Name',
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
                  return 'Please enter your name update.';
                }
                return null;
              },
              onSaved: (value) {
                userName = value!.trim();
              },
            ),
            const SizedBox(height: 12,),
            TextFormField(
              key: const ValueKey('password'),
              controller: passwordController,
              obscureText: isHidden,
              decoration: InputDecoration(
                hintText: isHidden ? 'New Password' : 'New Password',
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
                if (value!.isNotEmpty) {
                  userPassword = value!.trim();
                }
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
                  child: const Text('UPDATE')
              ),
          ],
        ),
      ),
    );
  }
}
