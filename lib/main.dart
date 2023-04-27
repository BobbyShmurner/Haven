import 'location.dart';
import 'place.dart';

import 'package:flutter/material.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

void main() {
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

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.title});
  final String title;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _controller;

  CameraPosition? _cameraPos;
  bool _isSearching = false;
  Set<Marker> _markers = <Marker>{};
  int _placeMask = PlaceType.values.flag;

  @override
  void initState() {
    super.initState();
    PlaceTypeExtensions.init();
  }

  GoogleMap _createMainMap() {
    return GoogleMap(
      mapType: MapType.normal,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      tiltGesturesEnabled: false,
      initialCameraPosition: _cameraPos!,
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
        _controller.setMapStyle(mapStyle);
      },
      markers: _markers,
      onCameraMove: (pos) {
        _cameraPos = pos;
      },
    );
  }

  Future<void> searchForMarkers() async {
    setState(() => _isSearching = true);

    // Dont pask the placeMask into the search, as we want to search for all types, but only display the masked markers
    await Place.searchForPlaces(_cameraPos!.target);
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
        target: LatLng(54.330483122642576, -4.557963944971561),
        zoom: 5.45,
      );
    }

    await searchForMarkers();
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
          _createMainMap(),
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
        onPressed: _isSearching ? null : () => searchForMarkers(),
        backgroundColor: Colors.pink,
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
        label: const Text("Search For Markers"),
      ),
    );
  }
}
