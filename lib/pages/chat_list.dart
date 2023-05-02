import 'package:flutter/material.dart';

import '../src/messages.dart';
import '../widgets/chat_preview.dart';

import 'chat.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Messages"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, i) {
          if (i >= Chat.chatCount) return null;
          String chatId = Chat.chatIds()[i];

          return ChatPreview(
            chatId: chatId,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(chatId: chatId),
                ),
              ).then((_) => setState(() {}));
            },
          );
        },
      ),
    );
  }
}
