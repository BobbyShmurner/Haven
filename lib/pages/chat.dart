import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:haven/src/date_time_extensions.dart';

import '../widgets/message_bubble.dart';

import '../src/messages.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    required this.chatId,
    super.key,
  });

  final String chatId;

  Chat? get chat {
    return Chat.getChat(chatId);
  }

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late TextEditingController _textController;
  late ScrollController _scrollController;

  @override
  void initState() {
    _textController = TextEditingController();
    _scrollController = ScrollController();

    super.initState();
  }

  void scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chat!.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(10),
              controller: _scrollController,
              itemBuilder: (context, i) {
                if (i >= widget.chat!.messages.length) {
                  return null;
                }

                Message message = widget.chat!.messages[i];

                return Column(
                  children: [
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        if (message.isFromMe) const Spacer(),
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.9,
                          ),
                          child: MessageBubble(
                            message: message,
                            backgroundColor: message.isFromMe
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade300,
                            textColor:
                                message.isFromMe ? Colors.white : Colors.black,
                          ),
                        ),
                        if (!message.isFromMe) const Spacer(),
                      ],
                    ),
                    if (i >= widget.chat!.messages.length - 1 ||
                        widget.chat!.messages[i + 1].isFromMe !=
                            message.isFromMe ||
                        widget.chat!.messages[i + 1].sentAt
                                .difference(message.sentAt)
                                .inMinutes >=
                            5)
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 5, left: 15, right: 15),
                        child: Align(
                          alignment: message.isFromMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Text(
                            message.sentAt.toShortString(),
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                      )
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                    child: Container(
                      color: Theme.of(context).primaryColor,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: TextField(
                          controller: _textController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          cursorColor: Colors.white,
                          decoration: const InputDecoration(
                            hintText: 'Type Message',
                            hintStyle: TextStyle(color: Colors.white),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      widget.chat!
                          .sendMessage(_textController.text.trim(), '0');
                      _textController.clear();

                      if (_scrollController.position.pixels ==
                          _scrollController.position.maxScrollExtent) {
                        SchedulerBinding.instance.addPostFrameCallback(
                          (_) => scrollToBottom(),
                        );
                      }

                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
