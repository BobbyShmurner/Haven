class Message {
  const Message({
    required this.senderId,
    required this.body,
    required this.sentAt,
  });

  final String body;
  final String senderId;
  final DateTime sentAt;

  bool get isFromMe {
    return senderId == "0";
  }
}

class Chat {
  final String name;
  final String chatId;
  final List<String> participantIds;

  List<Message> messages = <Message>[];

  static final Map<String, Chat> _chats = <String, Chat>{};

  static int get chatCount {
    return _chats.length;
  }

  static Chat? getChat(String chatId) {
    return _chats[chatId];
  }

  static bool exist(String chatId) {
    return _chats.containsKey(chatId);
  }

  static List<String> chatIds() {
    return _chats.keys.toList();
  }

  Chat({
    required this.name,
    required this.chatId,
    required this.participantIds,
    List<Message>? defaultMessages,
  }) {
    if (_chats.containsKey(chatId)) {
      throw "Chat with id $chatId already exists!";
    }

    if (defaultMessages != null) messages = defaultMessages;
    _chats[chatId] = this;
  }

  void addParticipant(String id) {
    if (participantIds.contains(id.trim())) return;

    participantIds.add(id.trim());
  }

  void sendMessage(String body, String senderId) {
    if (!participantIds.contains(senderId.trim())) {
      throw "Sender \"$senderId\" is not part of this chat";
    }

    String messageBody = body.trim();
    if (messageBody.isEmpty) return;

    messages.add(
      Message(
        body: messageBody,
        senderId: senderId,
        sentAt: DateTime.now(),
      ),
    );
  }
}
