import 'env/env.dart';
import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> searchMaps(LatLng location,
    {String? keyword, required int radius}) async {
  if (radius <= 0) return null;

  String url =
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${location.latitude},${location.longitude}&radius=$radius&key=${Env.mapsApiKey}";
  if (keyword != null) url += "&keyword=$keyword";

  var response = await http.get(Uri.parse(url));
  if (response.statusCode != 200) throw response.statusCode;

  return jsonDecode(response.body);
}

Future<Map<String, dynamic>?> getPlaceDetials(String placeId,
    {List<String> fields = const ["name", "geometry"]}) async {
  if (placeId.isEmpty) return null;

  String url =
      "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=${fields.join('%2C')}&key=${Env.mapsApiKey}";

  var response = await http.get(Uri.parse(url));
  if (response.statusCode != 200) throw response.statusCode;

  return jsonDecode(response.body);
}

Future<Map<String, dynamic>?> autocomplete(String keyword,
    {LatLng? location, required int radius}) async {
  if (keyword.isEmpty || radius <= 0) return null;

  String url =
      "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$keyword&radius=$radius&key=${Env.mapsApiKey}";
  if (location != null) {
    url += "&location=${location.latitude},${location.longitude}";
  }

  var response = await http.get(Uri.parse(url));
  if (response.statusCode != 200) throw response.statusCode;

  return jsonDecode(response.body);
}
