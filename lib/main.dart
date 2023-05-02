import 'src/maps_api.dart' as maps_api;
import 'src/messages.dart';
import 'src/location.dart';
import 'src/place.dart';

import 'widgets/chat_list_page.dart';
import 'widgets/loading_page.dart';
import 'widgets/login_page.dart';
import 'widgets/place_details.dart';
import 'widgets/map_search_bar.dart';
import 'widgets/loading_indicator.dart';

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const int searchRadius = 50000;

const String mapStyle = """[
  {
    "featureType": "administrative.land_parcel",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "administrative.neighborhood",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  }
]""";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PlaceTypeExtensions.init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  Chat(
    chatId: "example_chat",
    name: "Example Chat",
    participantIds: ['0', '-1'],
    defaultMessages: [
      Message(
        senderId: '-1',
        body: "Hello World!",
        sentAt: DateTime(2023, 05, 02, 18, 32, 15),
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
      home: const MapPage(title: "Haven "),
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.title});
  final String title;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final List<LatLng> _searchPoints = <LatLng>[];

  GoogleMapController? _mapsController;
  CameraPosition? _cameraPos;
  CameraPosition? _lastCameraPos;

  bool _isSearching = false;
  bool _onlyVerified = false;
  Set<Marker> _markers = <Marker>{};
  int _placeMask = PlaceType.values.flag;
  Place? _selectedPlace;

  @override
  void initState() {
    super.initState();

    Timer.periodic(
      const Duration(seconds: 1),
      (timer) async {
        if (_mapsController == null) return;
        if (_cameraPos != _lastCameraPos) {
          _lastCameraPos = _cameraPos;
          return;
        }

        _lastCameraPos = _cameraPos;
        fetchMarkers(_cameraPos!.target);
      },
    );
  }

  Future<void> fetchMarkers(
    LatLng searchPoint, {
    bool shouldRebuildMarkers = true,
  }) async {
    if (!maps_api.isApiEnabled || _searchPoints.contains(searchPoint)) return;
    _searchPoints.add(searchPoint);

    while (_isSearching) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    for (LatLng existingSearchPoint in _searchPoints) {
      if (searchPoint == existingSearchPoint) continue;
      if (existingSearchPoint.dist(searchPoint) < searchRadius * 0.75) {
        return;
      }
    }

    setState(() => _isSearching = true);

    await Place.fetchPlaces(searchPoint, radius: searchRadius);
    if (shouldRebuildMarkers) await rebuildMarkers();

    setState(() {
      _isSearching = false;
    });
  }

  Future<void> rebuildMarkers() async {
    Set<Marker> markers = Place.getPlaceMarkers(
      mask: _placeMask,
      onlyVerified: _onlyVerified,
      onTap: (place) {
        setState(() => _selectedPlace = place);
      },
    ).toSet();
    setState(() => _markers = markers);
  }

  Future<void> _firstLoad() async {
    try {
      LatLng location = await getDeviceLocation();

      _cameraPos = CameraPosition(
        target: location,
        zoom: 12.0,
      );
    } catch (_) {
      _cameraPos = const CameraPosition(
        target: LatLng(54.5869277, -5.9377212), // Kainos, Belfast
        zoom: 5.45,
      );
    }

    // Don't rebuild inside of the fetch, cus if the fetch returns early (for whatever reason)
    // The map won't ever be created
    await fetchMarkers(_cameraPos!.target, shouldRebuildMarkers: false);
    await rebuildMarkers();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraPos == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LoadingPage(
              _firstLoad,
              onLoad: (_) {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      );

      return const Scaffold();
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
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Align(
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
                        "Find safety and comfort near you",
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
                    // TODO: Add About Page
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("TODO: Add About Page"),
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
            child: GoogleMap(
              markers: _markers,
              mapType: MapType.normal,
              myLocationEnabled: true,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              tiltGesturesEnabled: false,
              initialCameraPosition: _cameraPos!,
              minMaxZoomPreference: const MinMaxZoomPreference(10.0, 20.0),
              onMapCreated: (GoogleMapController controller) {
                _mapsController = controller;
                _mapsController!.setMapStyle(mapStyle);
              },
              onCameraMove: (pos) {
                _cameraPos = pos;
              },
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Stack(
                  children: <Widget>[
                    MapSearchBar(
                      cameraPos: _cameraPos,
                      onAutocompleTapped: (autocomplete) async {
                        Place? place = await autocomplete.fetchPlace();
                        if (place == null) return;

                        _mapsController?.animateCamera(
                          CameraUpdate.newLatLng(place.position),
                        );
                      },
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: PopupMenuButton(
                        position: PopupMenuPosition.under,
                        iconSize: 56,
                        icon: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(56),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 3,
                                blurRadius: 3,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            backgroundColor: Colors.pink,
                            radius: 56,
                            child: Icon(
                              Icons.filter_list_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        itemBuilder: (context) {
                          List<PopupMenuEntry<dynamic>> items = PlaceType.values
                              .map(
                                (place) => PopupMenuItem(
                                  child: StatefulBuilder(
                                    builder: (context, localSetState) =>
                                        CheckboxListTile(
                                      value: _placeMask.hasFlag(place),
                                      onChanged: (newVal) => localSetState(
                                        () {
                                          _placeMask = (newVal ?? false)
                                              ? _placeMask | place.value
                                              : _placeMask & ~place.value;

                                          rebuildMarkers();
                                        },
                                      ),
                                      title: Text(place.pluralName),
                                    ),
                                  ),
                                ),
                              )
                              .toList();

                          items.add(const PopupMenuItem(child: Divider()));

                          items.add(
                            PopupMenuItem(
                              child: StatefulBuilder(
                                builder: (context, localSetState) {
                                  return CheckboxListTile(
                                    value: _onlyVerified,
                                    onChanged: (newVal) => localSetState(
                                      () {
                                        _onlyVerified = !_onlyVerified;

                                        rebuildMarkers();
                                      },
                                    ),
                                    title: const Text("Only Verified"),
                                  );
                                },
                              ),
                            ),
                          );

                          return items;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              ExpansionTile(
                collapsedBackgroundColor: Colors.blue,
                backgroundColor: Colors.blue,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        maps_api.isApiEnabled
                            ? _selectedPlace != null
                                ? FutureBuilder(
                                    future: _selectedPlace!.fetchPlaceDetails(),
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

                                      return PlaceDetailsWidget(snapshot.data!);
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
                                  position: _cameraPos!.target,
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
                ],
              ),
            ],
          ),
          LoadingIndicator(
            active: _isSearching,
          ),
        ],
      ),
    );
  }
}
