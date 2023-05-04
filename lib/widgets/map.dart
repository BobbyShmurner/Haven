import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'package:haven/globals.dart' as globals;

import 'package:haven/src/place.dart';
import 'package:haven/src/location.dart';
import 'package:haven/src/extensions.dart';
import 'package:haven/src/maps_api.dart' as maps_api;

import 'package:haven/widgets/place_details.dart';
import 'package:haven/widgets/map_search_bar.dart';
import 'package:haven/widgets/loading_indicator.dart';

import 'package:haven/pages/login.dart';
import 'package:haven/pages/about.dart';
import 'package:haven/pages/loading.dart';
import 'package:haven/pages/chat_list.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:async';

class MapController {
  bool loaded = false;
  bool isSearching = false;
  CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(54.5869277, -5.9377212), // Kainos, Belfast
    zoom: 5.45,
  );

  Future<void> load() async {
    try {
      LatLng location = await getDeviceLocation();

      cameraPosition = CameraPosition(
        target: location,
        zoom: 12.0,
      );
    } catch (_) {}

    // Don't rebuild inside of the first fetch because if the fetch returns early,
    // for whatever reason, the map won't ever load
    await fetchMarkers(cameraPosition.target, shouldRebuildMarkers: false);
    await rebuildMarkers();

    loaded = true;
  }

  Future<void> fetchMarkers(
    LatLng searchPoint, {
    bool shouldRebuildMarkers = true,
  }) async {
    if (!maps_api.isApiEnabled || _searchPoints.contains(searchPoint)) return;
    _searchPoints.add(searchPoint);

    while (_isSearching) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    for (LatLng existingSearchPoint in _searchPoints) {
      if (searchPoint == existingSearchPoint) continue;
      if (existingSearchPoint.dist(searchPoint) < globals.searchRadius * 0.75) {
        return;
      }
    }

    setState(() => _isSearching = true);

    await Place.fetchPlaces(searchPoint, radius: globals.searchRadius);
    if (shouldRebuildMarkers) await rebuildMarkers();

    setState(() {
      _isSearching = false;
    });
  }

  Future<void> rebuildMarkers() async {
    Set<Marker> markers = Place.getPlaceMarkers(
      mask: _placeMask,
      onlyVerified: _onlyVerified,
      onTap: (place) {
        setState(() => _selectedPlace = place);
      },
    ).toSet();
    setState(() => _markers = markers);
  }
}

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  final List<LatLng> _searchPoints = <LatLng>[];

  GoogleMapController? _mapsController;
  CameraPosition? _lastCameraPos;
  CameraPosition? _cameraPos;

  int _placeMask = PlaceType.values.flag;
  Set<Marker> _markers = <Marker>{};
  Place? _selectedPlace;

  bool _isSearching = false;
  bool _onlyVerified = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _firstLoad();
    });

    Timer.periodic(
      const Duration(seconds: 1),
      (timer) async {
        if (_mapsController == null) return;
        if (_cameraPos != _lastCameraPos) {
          _lastCameraPos = _cameraPos;
          return;
        }

        _lastCameraPos = _cameraPos;
        fetchMarkers(_cameraPos!.target);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      markers: _markers,
      mapType: MapType.normal,
      myLocationEnabled: true,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      tiltGesturesEnabled: false,
      initialCameraPosition: _cameraPos!,
      minMaxZoomPreference: const MinMaxZoomPreference(10.0, 20.0),
      onMapCreated: (GoogleMapController controller) {
        _mapsController = controller;
        _mapsController!.setMapStyle(globals.mapStyle);
      },
      onCameraMove: (pos) {
        _cameraPos = pos;
      },
    );
  }
}
