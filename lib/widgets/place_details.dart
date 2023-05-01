import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import 'rating.dart';
import '../src/place.dart';

class PlaceDetailsWidget extends StatelessWidget {
  const PlaceDetailsWidget(
    this.details, {
    super.key,
  });

  final PlaceDetails details;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                visualDensity: VisualDensity.comfortable,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  details.name,
                  style: const TextStyle(fontSize: 28),
                ),
                subtitle: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (details.type != null) Text(details.type!.displayName),
                    if (details.wheelchairAccessibleEntrance != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: details.wheelchairAccessibleEntrance!
                            ? const [
                                Text("Wheelchair Accessible Entrence"),
                                Icon(
                                  Icons.wheelchair_pickup_rounded,
                                  size: 18,
                                ),
                              ]
                            : const [
                                Text("No Wheelchair Accessible Entrence"),
                                Icon(
                                  Icons.error,
                                  size: 18,
                                ),
                              ],
                      ),
                    if (details.rating != null)
                      Rating(
                        rating: details.rating!,
                        amount: details.userRatingsTotal,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (details.url != null)
                Align(
                  alignment: Alignment.bottomLeft,
                  child: FloatingActionButton.extended(
                    onPressed: () => launchUrl(
                      Uri.parse(details.url!),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.location_on_rounded),
                    label: const Text("Open on Google Maps"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
