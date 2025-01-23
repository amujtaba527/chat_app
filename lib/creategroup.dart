import 'package:chat_app/groupchat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  bool _isAnonymous = false;
  List<Map<String, dynamic>> _friends = [];
  List<String> _selectedFriendIds = [];

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  Future<void> _fetchFriends() async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;

    // Fetch friend requests where the current user is the sender or receiver, and the status is "accepted"
    final friendRequestsSnapshot = await FirebaseFirestore.instance
        .collection('friendRequests')
        .where('status', isEqualTo: 'accepted')
        .where('receiverId', isEqualTo: currentUser!.uid)
        .get();

    // Combine with requests where the current user is the sender
    final sentFriendRequestsSnapshot = await FirebaseFirestore.instance
        .collection('friendRequests')
        .where('status', isEqualTo: 'accepted')
        .where('senderId', isEqualTo: currentUser.uid)
        .get();

    final List<Map<String, dynamic>> friendList = [];

    // Extract friends from requests where the current user is the receiver
    for (var doc in friendRequestsSnapshot.docs) {
      final friendDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(doc['senderId'])
          .get();

      if (friendDoc.exists) {
        friendList.add({
          'id': doc['senderId'],
          'name': friendDoc['name'] ?? friendDoc['email'],
        });
      }
    }

    // Extract friends from requests where the current user is the sender
    for (var doc in sentFriendRequestsSnapshot.docs) {
      final friendDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(doc['receiverId'])
          .get();

      if (friendDoc.exists) {
        friendList.add({
          'id': doc['receiverId'],
          'name': friendDoc['name'] ?? friendDoc['email'],
        });
      }
    }

    setState(() {
      _friends = friendList;
    });
  } catch (error) {
    print("Error fetching friends: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error fetching friends')),
    );
  }
}


  Future<void> _createGroup() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (_groupNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    // Include current user and selected friends
    final participants = [currentUser!.uid, ..._selectedFriendIds];

    final groupRef = await FirebaseFirestore.instance.collection('groups').add({
      'name': _groupNameController.text,
      'createdBy': currentUser.uid,
      'participants': participants,
      'isAnonymous': _isAnonymous,
      'createdAt': Timestamp.now(),
    });

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GroupChatScreen(
            groupId: groupRef.id,
            groupName: _groupNameController.text,
            isAnonymous: _isAnonymous,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Anonymous Group'),
              value: _isAnonymous,
              onChanged: (bool value) {
                setState(() {
                  _isAnonymous = value;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Friends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _friends.length,
                itemBuilder: (context, index) {
                  final friend = _friends[index];
                  return CheckboxListTile(
                    title: Text(friend['name']),
                    secondary: CircleAvatar(
                      backgroundImage: friend['photoURL'] != null
                          ? NetworkImage(friend['photoURL'])
                          : null,
                      child: friend['photoURL'] == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    value: _selectedFriendIds.contains(friend['id']),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedFriendIds.add(friend['id']);
                        } else {
                          _selectedFriendIds.remove(friend['id']);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createGroup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }
}
