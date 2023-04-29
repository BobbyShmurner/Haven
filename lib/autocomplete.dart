import 'place.dart';
import 'maps_api.dart' as maps_api;

import 'package:google_maps_flutter/google_maps_flutter.dart';

class AutocompleteResult {
  final String placeId;
  final String name;

  const AutocompleteResult({required this.placeId, required this.name});

  static Future<List<AutocompleteResult>> get(String keyword,
      {LatLng? location, required int radius}) async {
    Map<String, dynamic>? response = await maps_api.autocomplete(keyword,
        radius: radius, location: location);

    if (response == null) return [];

    List<AutocompleteResult> results = <AutocompleteResult>[];

    for (Map<String, dynamic> autocomplete in response['predictions']) {
      if (!autocomplete.containsKey("place_id")) {
        continue;
      }

      results.add(
        AutocompleteResult(
          placeId: autocomplete['place_id'],
          name: autocomplete['description'],
        ),
      );
    }

    return results;
  }

  Future<Place?> toPlace() async {
    return await Place.fromPlaceId(placeId);
  }
}
