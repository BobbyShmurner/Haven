import 'package:haven/globals.dart' as globals;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 50, right: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            Text(
              "Haven",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 80,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            const Text(
              globals.tagLine,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const Spacer(),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
                children: [
                  const TextSpan(
                    text:
                        """Haven is a prototype app designed to help out those who are in need of a place of refuge.

This prototype was created by Matthew Jordan in 2 weeks for the annual competition hosted by BelTech EDU and Kainos to design an app to transform the world for the greater good

Regardless of if I win or not, I've loved every second of creating this app, """,
                  ),
                  TextSpan(
                    text: "Despite the ups and downs, ",
                    style: const TextStyle(
                      color: Colors.blue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(
                          Uri.parse("https://ibb.co/j8nLn4D"),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                  ),
                  const TextSpan(
                    text:
                        """so I want to thank everyone involved for giving me this opportunity to get out of my comfort zone and create something new.

The source code for the app can be found """,
                  ),
                  TextSpan(
                    text: "Here.",
                    style: const TextStyle(
                      color: Colors.blue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(
                          Uri.parse("https://github.com/BobbyShmurner/Haven"),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
