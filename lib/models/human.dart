import '../models/position.dart';
import '../models/interest.dart';


class Human {
  // final String id;
  String name;
  final String email;
  List<Interest> interests;
  Position position;

  Human({
    // required this.id,
    required this.name,
    required this.email,
    this.interests = const [],
    required this.position,
  });
}