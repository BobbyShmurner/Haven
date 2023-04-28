import 'autocomplete.dart';
import 'location.dart';
import 'place.dart';

import 'dart:async';
import 'dart:math' as math;

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

class LoadingPage extends StatelessWidget {
  LoadingPage(
    Future<dynamic> Function() load, {
    super.key,
    void Function(dynamic)? onLoad,
    this.appBar,
  }) {
    load().then((value) => onLoad != null ? onLoad(value) : null);
  }

  final AppBar? appBar;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: appBar ??
            AppBar(
              leading: Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.only(left: 17.5),
                    child: SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ],
              ),
              title: const Text("Loading"),
            ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "Loading...",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30),
              ),
              Padding(padding: EdgeInsets.all(10.0)),
              CircularProgressIndicator()
            ],
          ),
        ),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }
}

class MapSearchBar extends StatefulWidget {
  const MapSearchBar({
    super.key,
    this.cameraPos,
    this.onAutocompleTapped,
  });

  final CameraPosition? cameraPos;
  final void Function(AutocompleteResult)? onAutocompleTapped;

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  List<AutocompleteResult> _autocompleteResults = <AutocompleteResult>[];

  bool showAutocomplete = false;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() async {
      var results = await AutocompleteResult.get(
        _searchController.text,
        location: widget.cameraPos?.target,
        radius: searchRadius,
      );

      setState(() => _autocompleteResults = results);
    });
  }

  void unfocus() {
    showAutocomplete = false;
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10.0, right: 60.0),
      child: TapRegion(
        onTapOutside: (event) => unfocus(),
        child: Column(
          children: [
            Card(
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.search_rounded),
                trailing: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.cancel_rounded),
                        onPressed: () => _searchController.clear(),
                      ),
                title: TextField(
                  autocorrect: false,
                  controller: _searchController,
                  keyboardType: TextInputType.streetAddress,
                  onTap: () => showAutocomplete = true,
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            if (showAutocomplete)
              Column(
                children: [
                  SizedBox(
                    height: math.min(_autocompleteResults.length * 58, 58 * 3),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, i) {
                        if (i >= _autocompleteResults.length) return null;

                        return GestureDetector(
                          onTap: widget.onAutocompleTapped != null
                              ? () {
                                  unfocus();

                                  widget.onAutocompleTapped!(
                                      _autocompleteResults[i]);
                                }
                              : null,
                          child: Card(
                            margin: const EdgeInsets.only(
                              left: 4,
                              right: 4,
                              top: 1,
                              bottom: 1,
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.place_rounded),
                              title: Text(_autocompleteResults[i].name),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
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
    if (_searchPoints.contains(searchPoint)) return;
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
        children: <Widget>[
          GoogleMap(
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
          MapSearchBar(
            cameraPos: _cameraPos,
            onAutocompleTapped: (autocomplete) async {
              Place place = await autocomplete.toPlace();
              _mapsController
                  ?.animateCamera(CameraUpdate.newLatLng(place.position));
            },
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: PopupMenuButton(
              iconSize: 56,
              icon: const CircleAvatar(
                backgroundColor: Colors.pink,
                radius: 56,
                child: Icon(Icons.filter_list_rounded),
              ),
              itemBuilder: (context) => PlaceType.values
                  .map(
                    (place) => PopupMenuItem(
                      child: StatefulBuilder(
                        builder: (context, setState) => CheckboxListTile(
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            _isSearching ? null : () => searchForMarkers(_cameraPos!.target),
        backgroundColor: _isSearching ? Colors.pink.shade800 : Colors.pink,
        disabledElevation: 0.0,
        icon: _isSearching
            ? const SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : const Icon(
                Icons.location_on_outlined,
                size: 25.0,
              ),
        label: Text(_isSearching ? "Searching..." : "Search For Markers"),
      ),
    );
  }
}
