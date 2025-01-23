import 'package:chat_app/groupchatlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search here...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .where('participants', arrayContains: user!.uid)
                    .where('type', isEqualTo: 'direct')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final chats = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      // Find the other participant's ID
                      final otherParticipantId = chats[index]['participants']
                          .firstWhere((id) => id != user.uid);

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(otherParticipantId)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return const SizedBox.shrink();
                          }

                          final otherUser = userSnapshot.data!;
                          return ListTile(
                            onTap: () {
                              Navigator.pushNamed(context, '/conversation',
                                  arguments: {
                                    'chatId': chats[index].id,
                                    'userId': otherParticipantId
                                  });
                            },
                            leading: const CircleAvatar(
                              backgroundImage: AssetImage(
                                'assets/profile_pic.jpg',
                              ),
                            ),
                            title:
                                Text(otherUser['name'] ?? otherUser['email']),
                            subtitle: Text(chats[index]['lastMessage'] ?? ''),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),

              // child: BottomNavigationBar(
              //   items: const [
              //     BottomNavigationBarItem(
              //       icon: Icon(
              //         Icons.message
              //         ),
              //     ),
              //     BottomNavigationBarItem(
              //       icon: Icon(
              //         Icons.person_outline
              //         ),
              //     ),
              //   ],
              // ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.message),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  GroupChatsListScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                                position: offsetAnimation, child: child);
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.group_outlined),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                    icon: const Icon(Icons.person_outline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0, right: 8.0),
        child: FloatingActionButton(
          backgroundColor: Colors.black,
          child: const Icon(Icons.person_add, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/addfriend'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
