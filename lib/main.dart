import 'src/location.dart';
import 'src/place.dart';

import 'widgets/loading_page.dart';
import 'widgets/map_search_bar.dart';

import 'dart:async';

import 'package:flutter/material.dart';
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
  await PlaceTypeExtensions.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kainos Map',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MapPage(title: "Kainos Map"),
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
  GoogleMapController? _mapsController;
  CameraPosition? _cameraPos;
  CameraPosition? _lastCameraPos;

  final List<LatLng> _searchPoints = <LatLng>[];
  bool _isSearching = false;
  Set<Marker> _markers = <Marker>{};
  int _placeMask = PlaceType.values.flag;

  @override
  void initState() {
    super.initState();

    Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) async {
        if (_mapsController == null) return;
        if (_cameraPos != _lastCameraPos) {
          _lastCameraPos = _cameraPos;
          return;
        }

        _lastCameraPos = _cameraPos;
        searchForMarkers(_cameraPos!.target);

        // --- NOTE: This code below works, but it can get quite expensive ---

        // // We walk from the top right to bottom left, moving down then left
        // LatLng searchPos = cameraBounds.northeast;
        // LatLng lowerBound = cameraBounds.southwest.offset(
        //   -searchRadius.toDouble(),
        //   -searchRadius.toDouble(),
        // );

        // while (true) {
        //   bool shouldSearch = true;
        //   for (LatLng existingSearchPoint in _searchPoints) {
        //     if (existingSearchPoint.dist(searchPos) < searchRadius) {
        //       shouldSearch = false;
        //       break;
        //     }
        //   }

        //   if (shouldSearch) {
        //     searchForMarkers(searchPos);
        //   }

        //   searchPos = searchPos.offset(-2.0 * searchRadius, 0);
        //   if (searchPos.latitude < lowerBound.latitude) {
        //     searchPos = LatLng(
        //       cameraBounds.northeast.latitude,
        //       searchPos.offset(0, -2.0 * searchRadius).longitude,
        //     );
        //   }
        //   if (searchPos.longitude < lowerBound.longitude) {
        //     break;
        //   }
        // }
        //
        // -------------------------------------------------------------------
      },
    );
  }

  Future<void> searchForMarkers(LatLng searchPoint,
      {bool forceSearch = false}) async {
    if (!forceSearch && _searchPoints.contains(searchPoint)) return;
    _searchPoints.add(searchPoint);

    while (_isSearching) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!forceSearch) {
      for (LatLng existingSearchPoint in _searchPoints) {
        if (searchPoint == existingSearchPoint) continue;
        if (existingSearchPoint.dist(searchPoint) < searchRadius * 0.75) {
          return;
        }
      }
    }

    setState(() => _isSearching = true);

    // Dont pask the placeMask into the search, as we want to search for all types, but only display the masked markers
    await Place.searchForPlaces(searchPoint, radius: searchRadius);
    await rebuildMarkers();

    setState(() {
      _isSearching = false;
    });
  }

  Future<void> rebuildMarkers() async {
    Set<Marker> markers = Place.getPlaceMarkers(mask: _placeMask).toSet();
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

    await searchForMarkers(_cameraPos!.target);
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
      appBar: AppBar(
        title: Text(widget.title),
        leading: const Icon(Icons.location_on),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 58.0),
            child: GoogleMap(
              markers: _markers,
              mapType: MapType.normal,
              myLocationEnabled: true,
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
                        Place? place = await autocomplete.toPlace();
                        if (place == null) return;

                        searchForMarkers(place.position);
                        _mapsController?.animateCamera(
                            CameraUpdate.newLatLng(place.position));
                      },
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: PopupMenuButton(
                        position: PopupMenuPosition.under,
                        iconSize: 56,
                        icon: const CircleAvatar(
                          backgroundColor: Colors.pink,
                          radius: 56,
                          child: Icon(
                            Icons.filter_list_rounded,
                            color: Colors.white,
                          ),
                        ),
                        itemBuilder: (context) => PlaceType.values
                            .map(
                              (place) => PopupMenuItem(
                                child: StatefulBuilder(
                                  builder: (context, setState) =>
                                      CheckboxListTile(
                                    value: _placeMask.hasFlag(place),
                                    onChanged: (newVal) => setState(
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
                            .toList(),
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
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const [
                          Align(
                            child: Text("Hello World!"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
