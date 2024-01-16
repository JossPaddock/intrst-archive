import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:slugify/slugify.dart';
import '../models/interest.dart';


class Interests with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  List<Interest> _interests = [];
  List<Interest> get interests {
    print('PRINTING FROM INSIDE THE PROVIDER: $_interests');
    return [..._interests];
  }

  Future<void> getInterestsStream() async {
    await for ( var snapshot in _firestore.collection('interests').snapshots()) {
      for (var interest in snapshot.docs) {
        // print(interest);
        _interests.add(Interest(
          interest: interest.data()['name'],
          id: slugify(interest.data()['id']),
          // description: interest.data()['description']
          createdAt: interest.data()['createdAt'] ?? FieldValue.serverTimestamp(),
        ));
      }
      print(_interests);
    }
    notifyListeners();
  }
}