import 'package:flutter/material.dart';

import '../src/place.dart';

class PlaceDetails extends StatelessWidget {
  const PlaceDetails(
    this.place, {
    super.key,
  });

  final Place place;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.comfortable,
      title: Text(
        place.name,
        style: const TextStyle(fontSize: 18),
      ),
      subtitle: place.type != null ? Text(place.type!.displayName) : null,
    );
  }
}
