import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _searchController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String _searchQuery = '';

  Future<void> sendFriendRequest(String receiverId) async {
    try {
      await _firestore.collection('friendRequests').add({
        'senderId': _auth.currentUser!.uid,
        'senderEmail': _auth.currentUser!.email,
        'receiverId': receiverId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request sent!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> acceptFriendRequest(String requestId) async {
    try {
      await _firestore.collection('friendRequests')
          .doc(requestId)
          .update({'status': 'accepted'});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request accepted!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friends'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Colors.black,
                    tabs: [
                      Tab(text: 'Search Results'),
                      Tab(text: 'Friend Requests'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Search Results Tab
                        StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('users')
                              .where('email', isGreaterThanOrEqualTo: _searchQuery)
                              .where('email', isLessThan: _searchQuery + 'z')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            }
                            if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final users = snapshot.data!.docs;
                            return ListView.builder(
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                final user = users[index];
                                final userId = user.id;
                                final userEmail = user['email'];

                                if (userId == _auth.currentUser!.uid) {
                                  return const SizedBox.shrink();
                                }

                                return ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  title: Text(userEmail),
                                  trailing: ElevatedButton(
                                    onPressed: () => sendFriendRequest(userId),
                                    child: const Text('Add Friend'),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        // Friend Requests Tab
                        StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('friendRequests')
                              .where('receiverId', isEqualTo: _auth.currentUser!.uid)
                              .where('status', isEqualTo: 'pending')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            }
                            if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final requests = snapshot.data!.docs;
                            return ListView.builder(
                              itemCount: requests.length,
                              itemBuilder: (context, index) {
                                final request = requests[index];
                                final senderEmail = request['senderEmail'];

                                return ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  title: Text(senderEmail),
                                  subtitle: const Text('Sent you a friend request'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check, color: Colors.green),
                                        onPressed: () => acceptFriendRequest(request.id),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}