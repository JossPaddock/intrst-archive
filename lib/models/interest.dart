import '../helpers/utilities.dart';

class Interest {
  final String id;
  final String interest;
  final String description;
  final String website;
  int orderIndex;
  final DateTime? createdAt;

  Interest({
    required this.id,
    required this.interest,
    this.description = "",
    this.website = "",
    this.orderIndex = 1000,
    required this.createdAt,
  });

  Map toJson() => {
    'id': id,
    'interest': interest,
    'website': website,
    'orderIndex': orderIndex,
    'createdAt': Utils.fromDateTimeToJson(createdAt!),
  };
}
