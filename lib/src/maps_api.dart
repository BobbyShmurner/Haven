import 'package:flutter/foundation.dart';

import 'env/env.dart';
import 'dart:convert';
import 'package:logger/logger.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

Logger log = Logger(printer: PrettyPrinter());

// Keep this line in this format so you can easily change it
const isApiEnabled = kDebugMode ? false : true;

const basicFields = ["name", "geometry"];

Future<dynamic> _genericApiCall(String url,
    {required String apiName, required String returnKey}) async {
  if (!isApiEnabled) return null;

  log.i("Calling \"$apiName\" API...\nRequest: $url");
  url += "&key=${Env.mapsApiKey}";

  var response = await http.get(Uri.parse(url));
  if (response.statusCode != 200) throw response.statusCode;

  log.i(response.body);

  return jsonDecode(response.body)[returnKey];
}

Future<List<dynamic>?> searchMaps(
  String keyword, {
  required int radius,
  required LatLng location,
}) async {
  if (radius <= 0 || keyword.trim().isEmpty) return null;

  String url =
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${location.latitude},${location.longitude}&radius=$radius&keyword=$keyword&fields=${basicFields.join(',')}";

  dynamic response = await _genericApiCall(
    url,
    returnKey: 'results',
    apiName: "Nearby Search",
  );

  return response;
}

Future<Map<String, dynamic>?> getPlaceDetails(
  String placeId, {
  List<String> fields = const [
    "name",
    "geometry",
    "url",
    "wheelchair_accessible_entrance",
    "rating",
    "user_ratings_total",
  ],
}) async {
  if (placeId.trim().isEmpty) return null;

  String url =
      "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=${fields.join(',')}";

  dynamic response = await _genericApiCall(
    url,
    returnKey: 'result',
    apiName: "Place Details",
  );

  return response;
}

Future<Map<String, dynamic>?> getBasicPlaceDetails(
  String placeId,
) async {
  if (placeId.trim().isEmpty) return null;

  return await getPlaceDetails(placeId, fields: basicFields);
}

Future<List<dynamic>?> autocomplete(
  String keyword, {
  LatLng? location,
  required int radius,
}) async {
  if (keyword.isEmpty || radius <= 0) return null;

  String url =
      "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$keyword&radius=$radius";

  if (location != null) {
    url += "&location=${location.latitude},${location.longitude}";
  }

  dynamic response = await _genericApiCall(
    url,
    returnKey: 'predictions',
    apiName: "Autocomplete",
  );

  return response;
}
