import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/message_input.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = 'chat';
  final String friendId;
  final String friendName;
  final String currentHumanId; // Add this
  final String currentHumanName; // Add this

  const ChatScreen({
    Key? key,
    required this.friendId,
    required this.friendName,
    required this.currentHumanId,
    required this.currentHumanName,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState(
      friendId, friendName, currentHumanId, currentHumanName);
}

class _ChatScreenState extends State<ChatScreen> {
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  final String friendId;
  final String friendName;
  final String currentHumanId;
  final String currentHumanName;
  // final currentUserId = FirebaseAuth.instance.currentUser?.email;
  var conversationId;

  _ChatScreenState(
      this.friendId, this.friendName, this.currentHumanId, this.currentHumanName);


  @override
  initState() {
    chats.where('users', isEqualTo: {friendId:friendName, currentHumanId:currentHumanName})
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          conversationId = querySnapshot.docs.single.id;
          markConversationAsRead();
        });
      } else {
        chats.add({
          'users': {currentHumanId: currentHumanName, friendId: friendName}
        }).then((value) {
          setState(() {
            conversationId = value.id;
            markConversationAsRead();  // Call the method here as well
          });
        });
      }
    }).catchError((error) {});
    super.initState();
  }

  //Leaving this hear in case chosen in future (or combine with markconvasread)
  void markMessagesAsRead() async {
    final messagesQuery = chats.doc(conversationId).collection('messages')
        .where('receiverId', isEqualTo: currentHumanId)
        .where('read', isEqualTo: false);

    final messagesSnapshot = await messagesQuery.get();

    for (var messageDoc in messagesSnapshot.docs) {
      messageDoc.reference.update({
        'read': true
      });
    }
  }


  void markConversationAsRead() async {
    final conversationDoc = chats.doc(conversationId);
    final conversationSnapshot = await conversationDoc.get();
    final conversationData = conversationSnapshot.data() as Map<String, dynamic>;

    if (conversationData['lastMessageReceiverId'] == currentHumanId && !conversationData['lastMessageRead']) {
      conversationDoc.update({
        'lastMessageRead': true
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(friendName),
      ),
      // drawer: AppDrawer(loggedInUser: null,),
      body: Column(
        children: [
          Expanded(child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .doc(conversationId)
                .collection('messages')
                .orderBy('createdAt', descending: true)
                .snapshots(),
                // .transform(Utils.transformer(Message.fromJson)),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if(snapshot.hasError) {
                return const Center(child: Text('Something went wrong!'),);
              }
              if(snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(),);
              }
              if (snapshot.hasData) {
                final messages = snapshot.data!.docs.map((doc) => doc.data()!).toList();
                var data;
                // print('THESE SHOULD BE MY MESSAGES: $messages');
                return messages.isEmpty
                    ? const Center(child: Text('Say something nice...'),)
                    : ListView(
                        reverse: true,
                        children: snapshot.data!.docs.map((DocumentSnapshot document) {
                          data = document.data()!;
                          return BubbleSpecialThree(
                            text: data['message'],
                            color: (data['senderId'] == currentHumanId)
                              ? Colors.blue
                              : Colors.grey,
                            tail: true,
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 16
                            ),
                            isSender: data['senderId'] == currentHumanId,
                          );
                        }).toList(),
                      );
              }
              return Container();
            },
          )),
          if (conversationId != null)
            MessageInput(
              conversationId: conversationId,
              friendId: friendId,
              userId: currentHumanId,
            ),
        ],
      ),
    );
  }
}
