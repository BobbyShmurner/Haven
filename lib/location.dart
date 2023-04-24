import 'marker.dart';
import 'dart:convert';
import 'env/env.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

extension PositionExtensions on Position {
  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }
}

Future<LatLng> getDeviceLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return (await Geolocator.getCurrentPosition()).toLatLng();
}

Future<Map<String, dynamic>> searchForLocations(LatLng location, int radius,
    {String? keyword}) async {
  String url =
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${location.latitude},${location.longitude}&radius=$radius&key=${Env.mapsApiKey}";
  if (keyword != null) url += "&keyword=$keyword";

  var response = await http.get(Uri.parse(url));
  if (response.statusCode != 200) throw response.statusCode;

  return jsonDecode(response.body);
}

Future<List<Marker>> createMarkersFromSearch(LatLng location,
    {String? keyword, MarkerIcons? icon, int radius = 50000}) async {
  var response = await searchForLocations(location, radius, keyword: keyword);
  List<Marker> markers = <Marker>[];

  for (Map<String, dynamic> place in response['results']) {
    if (!place.containsKey("geometry") || !place.containsKey("place_id")) {
      continue;
    }

    String placeId = place['place_id'];

    LatLng position = LatLng(
      place['geometry']['location']['lat'],
      place['geometry']['location']['lng'],
    );

    markers.add(
      createMarker(
        placeId,
        position,
        icon: icon,
        info: InfoWindow(
            title: place.containsKey('name') ? place['name'] : null,
            snippet: keyword),
      ),
    );
  }

  return markers;
}
