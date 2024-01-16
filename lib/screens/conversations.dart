import 'package:intrst/screens/chat.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/app_drawer.dart';

class ConversationsScreen extends StatefulWidget {
  static const routeName = '/conversations';
  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  final currentUserId = FirebaseAuth.instance.currentUser?.email;
  final loggedInUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
      ),
      drawer: AppDrawer(loggedInUser: loggedInUser),
      body: StreamBuilder<QuerySnapshot>(
        stream: chats.orderBy('lastMessageAt', descending: true).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong!'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No conversations yet.'));
          }

          final allConversations = snapshot.data!.docs;
          final userConversations = allConversations.where((doc) {
            final usersMap = (doc.data() as Map<String, dynamic>)['users'] as Map<String, dynamic>;
            return usersMap.containsKey(currentUserId);
          }).toList();

          return ListView.separated(
            itemCount: userConversations.length,
            itemBuilder: (ctx, index) {
              final conversationData = userConversations[index].data() as Map<String, dynamic>;
              final usersMap = conversationData['users'] as Map<String, dynamic>;

              String otherUserId = '';
              String otherUserName = '';
              String currentUserName = usersMap[currentUserId] ?? '';
              bool shouldBolden = false;  // This will determine if the display ID should be bold

              for (var entry in usersMap.entries) {
                if (entry.key == currentUserId) {
                  currentUserName = entry.value;
                } else {
                  otherUserId = entry.key;
                  otherUserName = entry.value;
                }
              }

              if (conversationData['lastMessageRead'] == false &&
                  conversationData['lastMessageReceiverId'] == currentUserId) {
                shouldBolden = true;
              }

              return ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        otherUserName,
                        style: TextStyle(
                          fontWeight: shouldBolden ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (shouldBolden)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => ChatScreen(
                      friendId: otherUserId,
                      friendName: otherUserName,
                      currentHumanId: currentUserId!,
                      currentHumanName: currentUserName,
                    ),
                  ));
                },
              );
            },
            separatorBuilder: (ctx, index) => const Divider(),
          );
        },
      ),
    );
  }
}
