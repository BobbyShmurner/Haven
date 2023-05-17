import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:haven/src/place.dart';
import 'package:haven/src/messages.dart';
import 'package:haven/pages/chat.dart';

import 'package:haven/widgets/rating.dart';

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
                title: Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 28),
                    children: [
                      TextSpan(text: details.name),
                      if (details.verified)
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(width: 10),
                              Icon(
                                Icons.verified,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
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
                    if (details.website != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.language,
                            size: 18,
                          ),
                          Expanded(
                            child: Text(
                              "· ${details.website}",
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
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
                        FloatingActionButton.extended(
                          heroTag: null,
                          icon: const Icon(Icons.message),
                          label: const Text("Message"),
                          onPressed: () {
                            if (!Chat.exist(details.id)) {
                              Chat(
                                name: details.name,
                                chatId: details.id,
                                participantIds: ['0', details.id],
                              );
                            }

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return ChatPage(chatId: details.id);
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 20),
                      ],
                      if (details.website != null) ...[
                        FloatingActionButton.extended(
                          heroTag: null,
                          onPressed: () => launchUrl(
                            Uri.parse(details.website!),
                            mode: LaunchMode.externalApplication,
                          ),
                          icon: const Icon(Icons.language),
                          label: const Text("Website"),
                        ),
                        const SizedBox(width: 20),
                      ],
                      if (details.internationalPhoneNumber != null)
                        FloatingActionButton.extended(
                          heroTag: null,
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
                  heroTag: null,
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
