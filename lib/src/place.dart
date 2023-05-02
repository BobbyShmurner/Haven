import 'maps_api.dart' as maps_api;
import 'location.dart';

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

class PlaceDetails {
  final String id;
  final PlaceType? type;
  final bool verified;

  late String name;
  late LatLng position;
  late String? url;
  late String? formattedAddress;
  late bool? wheelchairAccessibleEntrance;
  late String? website;
  late String? formattedPhoneNumber;
  late String? internationalPhoneNumber;
  late double? rating;
  late int? userRatingsTotal;

  PlaceDetails({
    required this.id,
    required this.name,
    required this.position,
    required this.verified,
    this.type,
    this.url,
    this.formattedAddress,
    this.wheelchairAccessibleEntrance,
    this.website,
    this.formattedPhoneNumber,
    this.internationalPhoneNumber,
    this.rating,
    this.userRatingsTotal,
  });

  PlaceDetails.fromJson(
    Map<String, dynamic> json, {
    required this.type,
    required this.id,
    required this.verified,
  }) {
    // Required
    name = json['name']!;
    position = LatLngExtensions.fromGeometryJson(json['geometry']!);

    // Baisc
    url = json['url'];
    formattedAddress = json['formatted_address'];
    wheelchairAccessibleEntrance = json['wheelchair_accessible_entrance'];

    // Contact
    website = json['website'];
    formattedPhoneNumber = json['formatted_phone_number'];
    internationalPhoneNumber = json['international_phone_number'];

    // Atmosphere
    rating = json['rating'] != null ? (json['rating'] as num).toDouble() : null;
    userRatingsTotal = json['user_ratings_total'];
  }
}

class Place {
  final String id;
  final String name;
  final LatLng position;
  final PlaceType? type;
  final bool verified;

  PlaceDetails? detials;

  late InfoWindow _info;
  Marker? _marker;

  static final Map<PlaceType, List<Place>> _cachedPlacesOfType =
      <PlaceType, List<Place>>{};

  static final Map<String, Place> _cachedPlaces = <String, Place>{};
  static final Map<String, PlaceDetails> _cachedPlaceDetails =
      <String, PlaceDetails>{};

  Place({
    required this.name,
    required this.id,
    required this.position,
    required this.verified,
    this.type,
  }) {
    _info = InfoWindow(title: name, snippet: type?.displayName);
  }

  Marker createMarker(void Function(Place)? onTap) {
    _marker ??= Marker(
      markerId: MarkerId(id),
      position: position,
      infoWindow: _info,
      icon: type != null ? type!.icon : BitmapDescriptor.defaultMarker,
      onTap: onTap != null ? () => onTap(this) : null,
    );

    return _marker!;
  }

  Future<PlaceDetails?> fetchPlaceDetails() async {
    if (_cachedPlaceDetails.containsKey(id)) {
      return _cachedPlaceDetails[id];
    }

    Map<String, dynamic>? response = await maps_api.getPlaceDetails(id);
    if (response == null) return null;

    PlaceDetails details = PlaceDetails.fromJson(
      response,
      type: type,
      id: id,
      verified: verified,
    );
    _cachedPlaceDetails[id] = details;

    return details;
  }

  static Future<Place?> fetchBasicPlaceFromId(String placeId) async {
    if (_cachedPlaces.containsKey(placeId)) return _cachedPlaces[placeId];

    Map<String, dynamic>? response =
        await maps_api.getBasicPlaceDetails(placeId);
    if (response == null) return null;

    Place place = _parsePlace(response, placeId: placeId);
    _cachedPlaces[placeId] = place;

    return place;
  }

  static List<Place> getPlaces({int? mask}) {
    mask ??= PlaceType.values.flag;

    List<Place> places = <Place>[];
    Iterable<PlaceType> placeTypes =
        mask.getFlags(PlaceType.values) as Iterable<PlaceType>;

    for (PlaceType type in placeTypes) {
      if (!Place._cachedPlacesOfType.containsKey(type)) continue;
      places.addAll(Place._cachedPlacesOfType[type]!);
    }

    return places;
  }

  static List<Marker> getPlaceMarkers(
      {int? mask, void Function(Place)? onTap}) {
    List<Marker> markers = <Marker>[];

    for (Place place in Place.getPlaces(mask: mask)) {
      markers.add(place.createMarker(onTap));
    }

    return markers;
  }

  static Future<List<Place>> fetchPlaces(LatLng searchPos,
      {int? placeMask, required int radius}) async {
    placeMask ??= PlaceType.values.flag;

    Iterable<PlaceType> placeTypes =
        placeMask.getFlags(PlaceType.values) as Iterable<PlaceType>;

    for (PlaceType type in placeTypes) {
      await _fetchPlacesOfType(searchPos, placeType: type, radius: radius);
    }

    return getPlaces(mask: placeMask);
  }

  static Future<void> _fetchPlacesOfType(LatLng searchPos,
      {required PlaceType placeType, required int radius}) async {
    List<dynamic>? response = await maps_api.searchMaps(
      placeType.keyword,
      location: searchPos,
      radius: radius,
    );

    if (response == null) return;

    for (Map<String, dynamic> placeResponse in response) {
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

      _cachedPlaces[placeResponse['place_id']] = place;

      if (_cachedPlacesOfType.containsKey(placeType)) {
        if (_cachedPlacesOfType[placeType]!.contains(place)) continue;
        _cachedPlacesOfType[placeType]!.add(place);
      } else {
        _cachedPlacesOfType[placeType] = <Place>[place];
      }
    }
  }

  static Place _parsePlace(Map<String, dynamic> response,
      {required String placeId, PlaceType? placeType}) {
    String placeName = response['name'];

    LatLng placePos = LatLngExtensions.fromGeometryJson(response['geometry']);

    return Place(
      id: placeId,
      name: placeName,
      position: placePos,
      type: placeType,
      verified: placeId == "id",
    );
  }
}
