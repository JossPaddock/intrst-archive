import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../models/interest.dart';
import '../models/message.dart';
import '../helpers/utilities.dart';

final _firestore = FirebaseFirestore.instance;


class FirebaseApi {
  Future<List<Interest>> getInterestsStream() async {
    List<Interest> interests = [];
    await for ( var snapshot in _firestore.collection('interests').snapshots()) {
      for (var interest in snapshot.docs) {
        Timestamp? timestamp = interest.data()['createdAt'];
        DateTime? createdAt = timestamp != null ? timestamp.toDate() : DateTime.now();
        interests.add(Interest(
          interest: interest.data()['name'],
          id: interest.data()['id'],
          createdAt: createdAt,
        ));
      }
    }
    return interests;
  }


  void deleteUserInterest(loggedInUser, loggedInUserInterests, interestId){
    loggedInUserInterests.removeWhere((e) => e['id'] == interestId);
    updateFirestoreUserInterests(loggedInUser, loggedInUserInterests);
  }


  void addUserInterest(
      user,
      List<Map<String, dynamic>>? userInterests, newInterest) {

    userInterests?.add(newInterest);
    updateFirestoreUserInterests(user, userInterests);
  }


  void updateFirestoreUserInterests(user, userInterests) async {
    print('userInterests @ FIREBASE API: $userInterests');
    List<dynamic> interestPayload = [];
    for (var interest in userInterests) {
      interestPayload.add({
        'name': interest.interest,
        'id': interest.id,
        'description': interest.description,
        'website': interest.website,
        'createdAt': interest.createdAt,
      });
    }
    print('INTRST PAYLOAD @ FIREBASE API: $interestPayload');
    try {
      await _firestore.collection('humans')
          .doc(user!.uid)
          .update({
        'interests': interestPayload,
      });
    } on PlatformException catch (error) {
      String? message = "An error occurred, please try again later.";
      if (error.message != null) {
        message = error.message;
      }
      // showSnackBar(message);
    } catch (error) {
      // showSnackBar(error);
    }
  }


  void addNewPublicInterest(interest) async {
    try {
      await _firestore
          .collection('interests')
          .doc(interest['id'])
          .set({
        'name': interest['name'],
      });
    } on PlatformException catch (error) {
      String? message = "An error occurred, please try again later.";
      if (error.message != null) {
        message = error.message;
      }
      // showSnackBar(message);
    } catch (error) {
      // showSnackBar(error);
    }
  }
}