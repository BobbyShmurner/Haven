import 'place.dart';
import 'maps_api.dart' as maps_api;

import 'package:google_maps_flutter/google_maps_flutter.dart';

class AutocompleteResult {
  final String placeId;
  final String name;

  static final Map<String, List<AutocompleteResult>> _cachedResults =
      <String, List<AutocompleteResult>>{};

  Place? _place;
  bool _searchedForPlace = false;

  AutocompleteResult({required this.placeId, required this.name});

  static Future<List<AutocompleteResult>> fetch(String keyword,
      {LatLng? location, required int radius}) async {
    String searchTerm = keyword.toLowerCase().trim();

    if (_cachedResults.containsKey(searchTerm)) {
      return _cachedResults[searchTerm]!;
    }

    Map<String, dynamic>? response = await maps_api.autocomplete(searchTerm,
        radius: radius, location: location);

    if (response == null) {
      _cachedResults[searchTerm] = [];
      return [];
    }

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

    _cachedResults[searchTerm] = results;
    return results;
  }

  Future<Place?> fetchPlace() async {
    if (_searchedForPlace) return _place;

    _place = await Place.fetchPlacefromId(placeId);
    _searchedForPlace = true;
    return _place;
  }
}
