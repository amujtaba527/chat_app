import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/message_bubble.dart';

class ConversationScreen extends StatelessWidget {
  const ConversationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final chatId = args['chatId'];
    final userId = args['userId'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: FutureBuilder<DocumentSnapshot>(
  future: FirebaseFirestore.instance
      .collection('users')
      .doc(args['otherUserId'])
      .get(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Text(
        'Loading...',
        style: TextStyle(color: Colors.black),
      );
    }
    if (snapshot.hasError) {
      return const Text(
        'Error',
        style: TextStyle(color: Colors.black),
      );
    }
    if (!snapshot.hasData || !snapshot.data!.exists) {
      return const Text(
        'User',
        style: TextStyle(color: Colors.black),
      );
    }

    final data = snapshot.data!.data() as Map<String, dynamic>?;

    return Text(
      data?['name'] ?? 'user',
      style: const TextStyle(color: Colors.black),
    );
  },
),

        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index].data() as Map<String, dynamic>;
                    return MessageBubble(
                      message: messageData['text'],
                      isMe: messageData['senderId'] == userId,
                      time: _formatTimestamp(messageData['timestamp']),
                    );
                  },
                );
              },
            ),
          ),
          MessageInputField(chatId: chatId, userId: userId),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    // Implement your timestamp formatting logic
    return '${timestamp.toDate().hour}:${timestamp.toDate().minute}';
  }
}

class MessageInputField extends StatefulWidget {
  final String chatId;
  final String userId;

  const MessageInputField({
    super.key, 
    required this.chatId, 
    required this.userId
  });

  @override
  _MessageInputFieldState createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  final _messageController = TextEditingController();

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'text': _messageController.text.trim(),
        'senderId': widget.userId,
        'timestamp': Timestamp.now(),
      });

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          // IconButton(
          //   icon: const Icon(Icons.add),
          //   onPressed: () {},
          // ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Write message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}