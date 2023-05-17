import 'package:haven/src/messages.dart';
import 'package:haven/src/place.dart';

import 'package:haven/pages/map.dart';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PlaceTypeExtensions.init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Setup an example chat
  Chat(
    chatId: "example_chat",
    name: "Example Chat",
    participantIds: ['0', '-1'],
    defaultMessages: [
      Message(
        senderId: '-1',
        body: "Hello World!",
        sentAt: DateTime.now(),
      )
    ],
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Haven',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MapPage(title: "Haven"),
    );
  }
}
