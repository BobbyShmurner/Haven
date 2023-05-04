import 'package:flutter/material.dart';

import 'package:haven/src/date_time_extensions.dart';
import 'package:haven/src/messages.dart';

class ChatPreview extends StatefulWidget {
  const ChatPreview({
    required this.chatId,
    this.onTap,
    super.key,
  });

  final String chatId;
  final void Function()? onTap;

  Chat? get chat {
    return Chat.getChat(chatId);
  }

  @override
  State<ChatPreview> createState() => _ChatPreviewState();
}

class _ChatPreviewState extends State<ChatPreview> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: ListTile(
        onTap: widget.onTap,
        minVerticalPadding: 20,
        title: Text(
          widget.chat!.name,
          style: const TextStyle(
            fontSize: 28,
          ),
        ),
        subtitle: widget.chat!.messages.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.chat!.messages.last.body,
                        style: const TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Text(
                      widget.chat!.messages.last.sentAt.toShortString(),
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}
