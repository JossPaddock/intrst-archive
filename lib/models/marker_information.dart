
import 'interest.dart';

class MarkerInformation {
  String email;
  String name;
  // List<Map<String, dynamic>> interestList;
  List<Interest> interestList;
  
  MarkerInformation({
    required this.email,
    required this.name,
    required this.interestList,

  });
}