import 'package:flutter/material.dart';

class AutocompleteButton extends StatelessWidget {
  const AutocompleteButton({super.key, required this.text, this.onTap});

  final void Function()? onTap;
  final Text text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(
          left: 4,
          right: 4,
          top: 1,
          bottom: 1,
        ),
        child: ListTile(
          leading: const Icon(Icons.place_rounded),
          title: text,
        ),
      ),
    );
  }
}
