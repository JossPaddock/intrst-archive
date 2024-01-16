import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final String conversationId;
  final String? userId;
  final String friendId;

  const MessageInput({
    Key? key,
    required this.conversationId,
    required this.userId,
    required this.friendId,
  }) : super(key: key);

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  final _controller = TextEditingController();
  String message = '';

  void sendMessage() async {
    FocusScope.of(context).unfocus();
    FirebaseFirestore.instance
      .collection('chats')
      .doc(widget.conversationId)
      .collection('messages')
      .add({
        'senderId': widget.userId,
        'receiverId': widget.friendId,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      }).then((value) => _controller.clear());
    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.conversationId)
        .update({
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageRead': false,
      'lastMessageReceiverId': widget.friendId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(child: TextField(
            controller: _controller,
            autocorrect: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              labelText: 'Message',
              border: OutlineInputBorder(
                borderSide: BorderSide(width: 0),
                gapPadding: 12,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onChanged: (value) => setState(() {
              message = value;
            }),
          ),),
          const SizedBox(width: 18,),
          GestureDetector(
            onTap: message.trim().isEmpty ? null : sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueGrey,
              ),
              child: const Icon(Icons.send, color: Colors.white,),
            ),
          )
        ],
      ),
    );
  }
}
