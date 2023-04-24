import 'location.dart';
import 'place.dart';

import 'package:flutter/material.dart';
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
      home: const MapPage(title: 'Kainos Map'),
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

    await Place.searchForPlaces(_cameraPos!.target);
    Set<Marker> markers = Place.getPlaceMarkers().toSet();

    setState(() {
      _markers = markers;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool firstLoad = _cameraPos == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: const Icon(Icons.location_on),
      ),
      body: FutureBuilder<LatLng?>(
        // We only want to get the location on the first load.
        // Every rebuild after the first should just use the current camera location,
        // So there's no need to get users location again
        future: firstLoad ? getDeviceLocation() : Future.delayed(Duration.zero),
        builder: (BuildContext context, AsyncSnapshot<LatLng?> location) {
          // We only want to show the loading screen while waiting for the location
          if (firstLoad) {
            if (location.connectionState != ConnectionState.done) {
              return Center(
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
              );
            }

            // If we don't return, loading is finished and we have our location

            _cameraPos = location.hasError
                ? const CameraPosition(
                    target: LatLng(54.330483122642576, -4.557963944971561),
                    zoom: 5.45,
                  )
                : CameraPosition(
                    target: location.data!,
                    zoom: 12.0,
                  );

            WidgetsBinding.instance
                .addPostFrameCallback((_) => searchForMarkers());
          }

          return _createMainMap();
        },
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
