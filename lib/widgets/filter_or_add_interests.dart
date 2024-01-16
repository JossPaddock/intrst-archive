import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:slugify/slugify.dart';
import '../helpers/firebase.dart';
import '../helpers/utilities.dart';
import '../models/interest.dart';
//chips functionality
import 'package:chips_input/chips_input.dart';


final _firestore = FirebaseFirestore.instance;
final List<String> publicInterests = [];


class FilterOrAddInterests extends StatefulWidget {
  final Function filterHumans;
  final User? user;
  List<Interest>? userInterests;

  FilterOrAddInterests({
    Key? key,
    required this.filterHumans,
    this.user,
    this.userInterests,
  }) : super(key: key);

  @override
  State<FilterOrAddInterests> createState() => _FilterOrAddInterestsState();
}

class _FilterOrAddInterestsState extends State<FilterOrAddInterests> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final selectedInterests = ValueNotifier<List<Interest>>([]);
  Map<String, dynamic> _data = {
    'name': '',
    'id': '',
    'description': '',
    'website': '',
  };
  var _isLoadingButton = false;
  String newInterestText = '';
  List<Interest> interests = [];

  @override
  initState() {
    super.initState();
    interestsStream();
  }

  void interestsStream() async {
    await for (var snapshot in _firestore.collection('interests').snapshots()) {
      for (var interest in snapshot.docs) {
        interests.add(Interest(
          id: slugify(interest.data()['name']),
          interest: interest.data()['name'],
          createdAt: interest.data()['createdAt'] ?? DateTime.now(),
        ),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoadingButton = true;
    });
    widget.userInterests?.removeWhere((e) => e.id == slugify(_data['name']));
    widget.userInterests?.add(Interest(
      id: _data['id'],
      interest: _data['name'],
      description: _data['description'],
      website: _data['website'],
      createdAt: DateTime.now(),
    ));
    FirebaseApi().updateFirestoreUserInterests(widget.user, widget.userInterests);
    FirebaseApi().addNewPublicInterest(_data);
    Utils.showSnackBarMessage(context, "Interest added");
    Navigator.of(context).pop();
    setState(() {
      _isLoadingButton = false;
    });
  }

  Future<void> showFormDialog() async {
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
                            controller,
                            focusNode,
                            onEditingComplete) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            onEditingComplete: onEditingComplete,
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
                            _data['name'] = selection.trim();
                            _data['id'] = slugify(selection.trim());
                          }
                        },
                      ),
                      const SizedBox(height: 12,),
                      TextFormField(
                        minLines: 2,
                        maxLines: 3,
                        controller: _descriptionController,
                        validator: (value) {
                          return value!.isNotEmpty
                              ? null
                              : "Please a description";
                        },
                        decoration: const InputDecoration(
                          hintText: "Interest description",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onSaved: (value) {
                          _data['description'] = value!.trim();
                          _descriptionController.clear();
                        },
                      ),
                      const SizedBox(height: 12,),
                      TextFormField(
                        controller: _websiteController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
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
                  child: const Text('ADD INTEREST'),
                ),
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: deviceSize.width > 600 ? deviceSize.width * 0.4 : double.infinity,
        color: Colors.white,
        height: 42,
        child: Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(0.0, 0, 0, 6.0),
                padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 0),
                child: ChipsInput(
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(0),
                      border: InputBorder.none
                  ),
                  maxChips: deviceSize.width > 600 ? 5 : 2,
                  findSuggestions: (String query) {
                    if (query.isNotEmpty) {
                      var lowercaseQuery = query.toLowerCase();
                      newInterestText = query;
                      final results = interests.where((interest) {
                        return interest.interest
                            .toLowerCase()
                            .contains(query.toLowerCase());
                      }).toList(growable: false)
                        ..sort((a, b) => a.interest
                            .toLowerCase()
                            .indexOf(lowercaseQuery)
                            .compareTo(
                            b.interest.toLowerCase().indexOf(lowercaseQuery)));
                      return results;
                    }
                    return <Interest>[];
                  },
                  onChanged: (List<Interest> data) {
                    selectedInterests.value = data; // new line
                  },
                  chipBuilder: (context, state, Interest interest) {
                    return InputChip(
                      key: ObjectKey(interest),
                      label: Text(interest.interest),
                      onDeleted: () => state.deleteChip(interest),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  },
                  suggestionBuilder: (context, Interest interest) {
                    return Container(
                      width: 100,
                      child: ListTile(
                        key: ObjectKey(interest),
                        title: Text(interest.interest),
                      ),
                    );
                  },
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: selectedInterests,
              builder: (context, List<Interest> value, child) {
                return IconButton(
                  icon: const Icon(
                    Icons.search_rounded,
                    color: Colors.blueGrey,
                  ),
                  onPressed: () async {
                    try {
                      widget.filterHumans(value);
                    } catch (error) {}
                  },
                );
              },
            ),
            if (widget.user != null)
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outlined,
                  color: Colors.blueGrey,
                ),
                onPressed: showFormDialog,
              ),
          ],
        ),
      ),
    );
  }
}
