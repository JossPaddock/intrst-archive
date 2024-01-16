import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/interest.dart';
import '../models/human.dart';
import '../models/position.dart';


class Humans with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  List<Human> _humans = [];
  List<Human> get humans {
    return [..._humans];
  }

  Future<void> getHumansStream() async {
    await for (var snapshot in _firestore.collection('humans').snapshots()) {
      for (var human in snapshot.docs) {
        var data = human.data() as Map<String, dynamic>;
        List<dynamic> interestsListData = [];
        interestsListData.addAll(data['interests']);
        List<Interest> interestList = [];
        if (interestsListData.isNotEmpty) {
          interestsListData.forEach((e) {
            Timestamp? timestamp = e['createdAt'];
            DateTime? createdAt = timestamp != null ? timestamp.toDate() : DateTime.now();
            interestList.add(Interest(
                interest: e['name'],
                id: e['id'],
                description: e['description'],
                website: e['website'] ?? '',
                createdAt: createdAt
            ));
          });
        }
        _humans.add(Human(
          interests: interestList,
          email: data['email'],
          name: data['name'],

          position: Position(
              latitude: data['position']['latitude'],
              longitude: data['position']['longitude']
          ),
        ));
      }
      notifyListeners();
    }
    return;
  }
}