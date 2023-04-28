import 'maps_api.dart' as maps_api;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:enum_flag/enum_flag.dart';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

enum PlaceType with EnumFlag {
  foodBank,
  homelessShelter,
  abuse,
  police,
  suicide,
}

extension PlaceTypeExtensions on PlaceType {
  static final Map<PlaceType, BitmapDescriptor> _bitmaps =
      <PlaceType, BitmapDescriptor>{};

  String get displayName {
    switch (this) {
      case PlaceType.foodBank:
        return "Food Bank";
      case PlaceType.homelessShelter:
        return "Homeless Shelter";
      case PlaceType.abuse:
        return "Abuse Center";
      case PlaceType.police:
        return "Police Station";
      case PlaceType.suicide:
        return "Sucide Prevention & Awearness";
    }
  }

  String get pluralName {
    switch (this) {
      case PlaceType.foodBank:
        return "Food Banks";
      case PlaceType.homelessShelter:
        return "Homeless Shelters";
      case PlaceType.abuse:
        return "Abuse Centers";
      case PlaceType.police:
        return "Police Stations";
      case PlaceType.suicide:
        return "Sucide Prevention Centers";
    }
  }

  String get keyword {
    switch (this) {
      case PlaceType.suicide:
        return "Suicide Help";
      default:
        return displayName;
    }
  }

  BitmapDescriptor get icon {
    return _bitmaps[this]!;
  }

  static Future<void> init() async {
    _createBitmapFromDefault(PlaceType.foodBank, 60);
    _createBitmapFromDefault(PlaceType.homelessShelter, 200);
    _createBitmapFromDefault(PlaceType.abuse, 140);
    _createBitmapFromDefault(PlaceType.police, 0);
    _createBitmapFromDefault(PlaceType.suicide, 280);
  }

  static Future<void> _createBitmap(PlaceType type, String assetName) async {
    _bitmaps[type] = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      assetName,
      bundle: rootBundle,
    );
  }

  static void _createBitmapFromDefault(PlaceType marker, double hue) {
    _bitmaps[marker] = BitmapDescriptor.defaultMarkerWithHue(hue);
  }
}

class Place {
  final String id;
  final String name;
  final LatLng position;
  final PlaceType? type;

  late InfoWindow _info;
  Marker? _marker;

  static final Map<PlaceType, List<Place>> _cachedPlaces =
      <PlaceType, List<Place>>{};

  Place({
    required this.name,
    required this.id,
    required this.position,
    this.type,
  }) {
    _info = InfoWindow(title: name, snippet: type?.displayName);
  }

  Marker get marker {
    _marker ??= Marker(
      markerId: MarkerId(id),
      position: position,
      infoWindow: _info,
      icon: type != null ? type!.icon : BitmapDescriptor.defaultMarker,
    );

    return _marker!;
  }

  static Future<Place> fromPlaceId(String placeId) async {
    var response = await maps_api.getPlaceDetials(placeId);
    return _parsePlace(response['result'], placeId: placeId);
  }

  static List<Place> getPlaces({int? mask}) {
    mask ??= PlaceType.values.flag;

    List<Place> places = <Place>[];
    Iterable<PlaceType> placeTypes =
        mask.getFlags(PlaceType.values) as Iterable<PlaceType>;

    for (PlaceType type in placeTypes) {
      if (!Place._cachedPlaces.containsKey(type)) continue;
      places.addAll(Place._cachedPlaces[type]!);
    }

    return places;
  }

  static List<Marker> getPlaceMarkers({int? mask}) {
    List<Marker> markers = <Marker>[];

    for (Place place in Place.getPlaces(mask: mask)) {
      markers.add(place.marker);
    }

    return markers;
  }

  static Future<List<Place>> searchForPlaces(LatLng searchPos,
      {int? placeMask, required int radius}) async {
    placeMask ??= PlaceType.values.flag;

    Iterable<PlaceType> placeTypes =
        placeMask.getFlags(PlaceType.values) as Iterable<PlaceType>;

    for (PlaceType type in placeTypes) {
      await _searchForPlacesOfType(searchPos, placeType: type, radius: radius);
    }

    return getPlaces(mask: placeMask);
  }

  static Future<void> _searchForPlacesOfType(LatLng searchPos,
      {required PlaceType placeType, required int radius}) async {
    var response = await maps_api.searchMaps(searchPos,
        keyword: placeType.keyword, radius: radius);

    for (Map<String, dynamic> placeResponse in response['results']) {
      if (!placeResponse.containsKey("geometry") ||
          !placeResponse.containsKey("place_id") ||
          !placeResponse.containsKey("name")) {
        continue;
      }

      Place place = _parsePlace(
        placeResponse,
        placeId: placeResponse['place_id'],
        placeType: placeType,
      );

      if (_cachedPlaces.containsKey(placeType)) {
        if (_cachedPlaces[placeType]!.contains(place)) continue;
        _cachedPlaces[placeType]!.add(place);
      } else {
        _cachedPlaces[placeType] = <Place>[place];
      }
    }
  }

  static Place _parsePlace(Map<String, dynamic> response,
      {required String placeId, PlaceType? placeType}) {
    String placeName = response['name'];

    LatLng placePos = LatLng(
      response['geometry']['location']['lat'],
      response['geometry']['location']['lng'],
    );

    return Place(
      id: placeId,
      name: placeName,
      position: placePos,
      type: placeType,
    );
  }
}
