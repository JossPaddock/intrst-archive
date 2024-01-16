import '../helpers/utilities.dart';

class MessageField {
  static final String createdAt = 'createdAt';
  static final String read = 'read';
}

class Message {
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime? createdAt;
  final bool read;

  const Message({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.createdAt,
    this.read = false,
  });

  static Message fromJson(Map<String, dynamic> json) => Message(
    senderId: json['senderId'],
    receiverId: json['receiverId'],
    message: json['message'],
    createdAt: Utils.toDateTime(json['createdAt']),
    read: json[MessageField.read] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'senderId': senderId,
    'receiverId': receiverId,
    'message': message,
    'createdAt': Utils.fromDateTimeToJson(createdAt!),
    MessageField.read: read,
  };
}
