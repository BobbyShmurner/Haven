import 'location.dart';
import 'marker.dart';

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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke+
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
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
  final List<Marker> _markers = <Marker>[];

  @override
  void initState() {
    super.initState();
    MarkersExtension.init();
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
      markers: _markers.toSet(),
      onCameraMove: (pos) {
        _cameraPos = pos;
      },
    );
  }

  void addMarker(String id, LatLng position, {MarkerIcons? icon}) {
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId(id),
          position: position,
          icon: icon != null ? icon.icon : BitmapDescriptor.defaultMarker));

      _createMainMap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: const Icon(Icons.location_on),
      ),
      body: FutureBuilder<LatLng?>(
        // We only want to get the location for the inital creation of the map
        // Every rebuild after the first should just use the current camera location,
        // So there's no need to get users location again
        future: _cameraPos == null
            ? getDeviceLocation()
            : Future.delayed(Duration.zero),
        builder: (BuildContext context, AsyncSnapshot<LatLng?> location) {
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
          } else {
            if (location.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "TODO: Put a serach bar so people can choose their location",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 30),
                      softWrap: true,
                    ),
                  ],
                ),
              );
            }

            _cameraPos ??= CameraPosition(target: location.data!, zoom: 15.0);
            return _createMainMap();
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          addMarker(DateTime.now().millisecondsSinceEpoch.toString(),
              _cameraPos!.target,
              icon: MarkerIcons.testMarker);
        },
        backgroundColor: Colors.pink,
        icon: const Icon(Icons.location_on_outlined),
        label: const Text("Add Marker"),
      ),
    );
  }
}
