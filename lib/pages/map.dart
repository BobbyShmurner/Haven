import 'package:haven/globals.dart' as globals;

import 'package:haven/src/place.dart';
import 'package:haven/src/maps_api.dart' as maps_api;

import 'package:haven/widgets/map.dart';
import 'package:haven/widgets/place_details.dart';
import 'package:haven/widgets/map_search_bar.dart';
import 'package:haven/widgets/loading_indicator.dart';
import 'package:haven/widgets/map_filter_button.dart';

import 'package:haven/pages/login.dart';
import 'package:haven/pages/about.dart';
import 'package:haven/pages/loading.dart';
import 'package:haven/pages/chat_list.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.title});
  final String title;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    if (!_mapController.loaded) {
      SchedulerBinding.instance.addPostFrameCallback(
        (_) => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LoadingPage(
              _mapController.load,
              onLoad: (_) => Navigator.of(context).pop(),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: const Align(
                    child: ListTile(
                      textColor: Colors.white,
                      title: Text(
                        "Haven",
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        globals.tagLine,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.chat),
                  title: const Text("Messages"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatListPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text("Settings"),
                  onTap: () {
                    // TODO: Add Settings Page
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("TODO: Add Settings Page"),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text("About"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const Spacer(),
            const Divider(),
            ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                if (kDebugMode)
                  ListTile(
                    leading: const Icon(Icons.api),
                    title: Text(
                      maps_api.isApiEnabled ? "Disable API" : "Enable API",
                    ),
                    onTap: () {
                      setState(
                        () => maps_api.isApiEnabled = !maps_api.isApiEnabled,
                      );
                      Navigator.pop(context);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text("Business Login"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 58.0),
            child: Map(
              controller: _mapController,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Stack(
                  children: <Widget>[
                    AnimatedBuilder(
                      animation: _mapController,
                      builder: (context, _) => MapSearchBar(
                        cameraPos: _mapController.cameraPosition,
                        onAutocompleTapped: (autocomplete) async {
                          Place? place = await autocomplete.fetchPlace();
                          if (place == null) return;

                          _mapController.googleMapController?.animateCamera(
                            CameraUpdate.newLatLng(place.position),
                          );
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: MapFilterButton(mapController: _mapController),
                    ),
                  ],
                ),
              ),
              ExpansionTile(
                collapsedBackgroundColor: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).primaryColor,
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,
                textColor: Colors.white,
                collapsedTextColor: Colors.white,
                title: const Text(
                  "Place Details",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                children: [
                  Container(
                    height: 300,
                    color: Colors.white,
                    child: AnimatedBuilder(
                      animation: _mapController,
                      builder: (context, _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          maps_api.isApiEnabled
                              ? _mapController.selectedPlace != null
                                  ? FutureBuilder(
                                      future: _mapController.selectedPlace!
                                          .fetchPlaceDetails(),
                                      builder: ((context, snapshot) {
                                        if (snapshot.connectionState !=
                                            ConnectionState.done) {
                                          return const Center(
                                            child: Text(
                                              "Loading...",
                                              style: TextStyle(
                                                fontSize: 30,
                                              ),
                                            ),
                                          );
                                        }

                                        return PlaceDetailsWidget(
                                            snapshot.data!);
                                      }),
                                    )
                                  : const Center(
                                      child: Text(
                                        "No Place Selected!",
                                        style: TextStyle(
                                          fontSize: 30,
                                        ),
                                      ),
                                    )
                              : PlaceDetailsWidget(
                                  PlaceDetails(
                                    id: "testPlaceId",
                                    name: "Test Place",
                                    position:
                                        _mapController.cameraPosition.target,
                                    type: PlaceType.suicide,
                                    rating: 4.2,
                                    userRatingsTotal: 31,
                                    wheelchairAccessibleEntrance: true,
                                    url:
                                        "https://maps.google.com/?cid=1603406668482336744",
                                    website: "https://google.com",
                                    formattedAddress:
                                        "Unit 2, North City Business Centre, 2 Duncairn Gardens, Belfast BT15 2GG, UK",
                                    formattedPhoneNumber: "(02) 9374 4000",
                                    internationalPhoneNumber: "+61 2 9374 4000",
                                    verified: true,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          AnimatedBuilder(
            animation: _mapController,
            builder: (context, _) => LoadingIndicator(
              active: _mapController.isSearching,
            ),
          ),
        ],
      ),
    );
  }
}
