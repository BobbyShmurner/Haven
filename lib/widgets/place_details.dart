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
                title: Row(
                  children: [
                    Text(
                      details.name,
                      style: const TextStyle(fontSize: 28),
                    ),
                    if (details.verified)
                      const Icon(
                        Icons.verified,
                        color: Colors.blue,
                      ),
                  ],
                ),
                subtitle: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (details.type != null) Text(details.type!.displayName),
                    if (details.rating != null)
                      Rating(
                        rating: details.rating!,
                        amount: details.userRatingsTotal,
                      ),
                    const Divider(),
                    if (details.internationalPhoneNumber != null ||
                        details.formattedPhoneNumber != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.call,
                            size: 18,
                          ),
                          Text(
                              "· ${details.formattedPhoneNumber ?? details.internationalPhoneNumber}"),
                        ],
                      ),
                    if (details.wheelchairAccessibleEntrance != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: details.wheelchairAccessibleEntrance!
                            ? const [
                                Icon(
                                  Icons.accessible,
                                  size: 18,
                                ),
                                Text("· Wheelchair Accessible Entrance"),
                              ]
                            : const [
                                Icon(
                                  Icons.not_accessible,
                                  size: 18,
                                ),
                                Text("· No Wheelchair Accessible Entrance"),
                              ],
                      ),
                    if (details.formattedAddress != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 18,
                          ),
                          const Text("· "),
                          Expanded(
                            child: Text(details.formattedAddress!),
                          ),
                        ],
                      ),
                    const Divider(),
                  ],
                ),
              ),
              if (details.website != null ||
                  details.internationalPhoneNumber != null ||
                  details.verified) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: [
                      if (details.verified) ...[
                        const FloatingActionButton.extended(
                          onPressed: null,
                          icon: Icon(Icons.message),
                          label: Text("Message"),
                        ),
                        const SizedBox(width: 20),
                      ],
                      if (details.website != null) ...[
                        FloatingActionButton.extended(
                          onPressed: () => launchUrl(
                            Uri.parse(details.website!),
                            mode: LaunchMode.externalApplication,
                          ),
                          icon: const Icon(Icons.language),
                          label: const Text("Open Website"),
                        ),
                        const SizedBox(width: 20),
                      ],
                      if (details.internationalPhoneNumber != null)
                        FloatingActionButton.extended(
                          onPressed: () {
                            launchUrl(
                              Uri.parse(
                                  "tel:${details.internationalPhoneNumber!.replaceAll(' ', '')}"),
                              mode: LaunchMode.platformDefault,
                            );
                          },
                          icon: const Icon(Icons.call),
                          label: const Text("Call"),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (details.url != null) ...[
                FloatingActionButton.extended(
                  onPressed: () => launchUrl(
                    Uri.parse(details.url!),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.location_on_rounded),
                  label: const Text("Open on Google Maps"),
                ),
                const SizedBox(height: 20),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
