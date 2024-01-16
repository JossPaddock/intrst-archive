import 'package:flutter/material.dart' hide ReorderableList;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intrst/helpers/randomize.dart';
import 'package:intrst/helpers/utilities.dart';
import 'package:intrst/widgets/app_drawer.dart';
import 'package:slugify/slugify.dart';


final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
User? loggedInUser;
var loggedInUserInterests = [];
final List<String> publicInterests = [];

class MyInterestsScreenOrdered extends StatefulWidget {
  static const routeName = '/my-interests-ordered';

  const MyInterestsScreenOrdered({Key? key}) : super(key: key);

  @override
  State<MyInterestsScreenOrdered> createState() => _MyInterestsScreenOrderedState();
}

class _MyInterestsScreenOrderedState extends State<MyInterestsScreenOrdered> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  Map<String, dynamic> _data = {
    'name': '',
    'id': '',
    'description': '',
    'website': '',
    'orderIndex': '',
    'createdAt': DateTime.now(),
  };
  var _isLoadingButton = false;


  @override
  initState() {
    super.initState();

    getCurrentUser();
    getCurrentHumanInterests();
    interestsStream();
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

  void interestsStream() async {
    await for (var snapshot in _firestore.collection('interests').snapshots()) {
      for (var interest in snapshot.docs) {
        publicInterests.add(interest.data()['name']);
      }
    }
  }

  void getCurrentHumanInterests() async {
    var humanSnapshot = await _firestore.collection('humans')
        .doc(loggedInUser!.uid).get();
    if (humanSnapshot.exists) {
      Map<String, dynamic>? data = humanSnapshot.data();
      loggedInUserInterests = data?['interests'];
    }
  }

  Future<void> _submit() async {
    !_formKey.currentState!.validate();
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoadingButton = true;
    });

    // Set the orderIndex for the new interest
    _data['orderIndex'] = loggedInUserInterests.length;
    _data['createdAt'] = DateTime.now();

    //add new interest to current user's interests
    loggedInUserInterests.removeWhere((e) => e['id'] == slugify(_data['name']));
    loggedInUserInterests.add(_data);
    updateFirestoreUserInterests();

    //save to public interests unless already available
    addNewPublicInterest();
    Utils.showSnackBarMessage(context, "Interest added");
    Navigator.of(context).pop();
    setState(() {
      _isLoadingButton = false;
    });
  }


  void deleteUserInterest(id){
    loggedInUserInterests.removeWhere((e) => e['id'] == id);
    updateFirestoreUserInterests();
  }

  void addNewPublicInterest() async {
    try {
      await _firestore
          .collection('interests')
          .doc(_data['id'])
          .set({
        'name': _data['name'],
      }).then((value) => setState(() {
        _isLoadingButton = false;
        _data = {
          'name': '',
          'id': '',
          'description': '',
          'website': '',
        };
      }));
    } on PlatformException catch (error) {
      String? message = "An error occurred, please try again later.";
      if (error.message != null) {
        message = error.message;
      }
      showSnackBar(message);
    } catch (error) {
      showSnackBar(error);
    }
  }

  void updateFirestoreUserInterests() async {
    try {
      await _firestore.collection('humans')
          .doc(loggedInUser!.uid)
          .update({
        'interests': loggedInUserInterests,
      });
    } on PlatformException catch (error) {
      String? message = "An error occurred, please try again later.";
      if (error.message != null) {
        message = error.message;
      }
      showSnackBar(message);
    } catch (error) {
      showSnackBar(error);
    }
  }


  showSnackBar(message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> showFormDialog(interestDescription, interestName, interestWebsite) async {
    final _controller2 = TextEditingController(text: interestName);
    if (interestName != null) {
      _data['name'] = interestName.trim();
      _data['id'] = slugify(interestName.trim());
    }
    final _descriptionController2 = TextEditingController(text: interestDescription);
    final _websiteController2 = TextEditingController(text: interestWebsite);
    return await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Interest'),
              content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Autocomplete<String>(
                        fieldViewBuilder: (
                            _,
                            _controller2,
                            focusNode,
                            onEditingComplete) {
                          return TextField(
                            controller: _controller2,
                            focusNode: focusNode,
                            onEditingComplete: onEditingComplete,
                            enabled: (interestDescription != null) ? false : true,
                            decoration: const InputDecoration(
                              hintText: 'Interest',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          );
                        },
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return const Iterable<String>.empty();
                          }
                          _data['name'] = textEditingValue.text.trim();
                          _data['id'] = slugify(textEditingValue.text.trim());
                          return publicInterests.where((option) {
                            return option
                                .toString()
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        onSelected: (selection) {
                          if (selection.isNotEmpty) {
                            print(selection);
                            _data['name'] = selection.trim();
                            _data['id'] = slugify(selection.trim());
                          }
                        },
                      ),
                      const SizedBox(height: 12,),
                      TextFormField(
                        minLines: 2,
                        maxLines: 3,
                        controller: _descriptionController2,
                        validator: (value) {
                          return value!.isNotEmpty
                              ? null
                              : "Please add a description";
                        },
                        decoration: const InputDecoration(
                          hintText: "Interest description",
                          border: OutlineInputBorder(),
                          isDense: true,
                          // helperText: 'Helper Text',
                          // counterText: '0 characters',
                        ),
                        onSaved: (value) {
                          _data['description'] = value!.trim();
                          _descriptionController.clear();
                        },
                      ),
                      const SizedBox(height: 12,),
                      TextFormField(
                        controller: _websiteController2,
                        autovalidateMode: AutovalidateMode.onUserInteraction, // validate only when user has interacted
                        validator: (value) {
                          // check if value is empty or matches a URL pattern
                          return value!.isEmpty || RegExp(r"^https?://[\w\-\.]+(\.[\w\-]+)+(/.*)?$").hasMatch(value)
                              ? null
                              : "Please enter a valid website (https://www.example.com)";
                        },
                        decoration: const InputDecoration(
                          hintText: "https://www.example.com",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onSaved: (value) {
                          _data['website'] = value!.trim();
                          _websiteController.clear();
                        },
                      ),
                    ],
                  )),
              actions: <Widget>[
                _isLoadingButton
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _submit,
                  child: Text(
                    (interestDescription != null)
                        ? 'UPDATE'
                        : 'ADD',
                  ),
                ),
              ],
            );
          });
        });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('My Interests'),
        actions: [
          IconButton(
              onPressed: () {
                showFormDialog(null, null, null);
              },
              icon: const Icon(Icons.add)
          )
        ],
      ),
      drawer: AppDrawer(loggedInUser: loggedInUser),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _firestore.collection('humans')
                    .doc(loggedInUser!.uid)
                    .snapshots(),
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    final humanData = snapshot.data!.data();
                    loggedInUserInterests = (humanData as Map)['interests'] ?? [];
                    return ReorderableListView(
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final item = loggedInUserInterests.removeAt(oldIndex);
                          loggedInUserInterests.insert(newIndex, item);
                        });
                        // Update Firestore with the reordered loggedInUserInterests
                        updateFirestoreUserInterests();
                      },
                      children: loggedInUserInterests.map((interest) {
                        return Column(
                          key: ValueKey(interest['id']),
                          children: [
                            ListTile(
                              subtitle: Text(interest['website']),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(interest['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(interest['description']),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      showFormDialog(interest['description'], interest['name'], interest['website']);
                                    },
                                    icon: const Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      deleteUserInterest(slugify(interest['name']));
                                    },
                                    icon: const Icon(Icons.delete),
                                  ),
                                  const SizedBox(width: 20,),
                                ],
                              ),
                            ),
                            Divider() // This will separate the list items by a line
                          ],
                        );
                      }).toList(),
                    );


                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}