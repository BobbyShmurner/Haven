import 'package:haven/globals.dart' as globals;

import 'package:haven/src/maps_api.dart' as maps_api;
import 'package:haven/src/location.dart';
import 'package:haven/src/place.dart';

import 'package:flutter/material.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:async';

class MapController extends ChangeNotifier {
  Set<Marker> markers = <Marker>{};
  GoogleMapController? googleMapController;

  CameraPosition? _prevCameraPos;
  CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(54.5869277, -5.9377212), // Kainos, Belfast
    zoom: 5.45,
  );

  bool _isSearching = false;
  bool get isSearching {
    return _isSearching;
  }

  Place? _selectedPlace;
  Place? get selectedPlace {
    return _selectedPlace;
  }

  bool _loading = false;
  bool get loading {
    return _loading;
  }

  bool _loaded = false;
  bool get loaded {
    return _loaded;
  }

  bool _onlyVerified = false;
  bool get onlyVerified {
    return _onlyVerified;
  }

  set onlyVerified(bool value) {
    _onlyVerified = value;
    rebuildMarkers();
  }

  int _placeMask = PlaceType.values.flag;
  int get placeMask {
    return _placeMask;
  }

  MapController() {
    Timer.periodic(
      const Duration(seconds: 1),
      (timer) async {
        if (!loaded) return;

        if (cameraPosition != _prevCameraPos) {
          _prevCameraPos = cameraPosition;
          return;
        }

        _prevCameraPos = cameraPosition;
        fetchMarkers(cameraPosition.target);
      },
    );
  }

  void setPlaceFlag(PlaceType place, bool enabled) {
    _placeMask = enabled ? placeMask | place.value : placeMask & ~place.value;

    rebuildMarkers();
  }

  Future<void> load() async {
    if (loaded || loading) return;
    _loading = true;

    try {
      LatLng location = await getDeviceLocation();

      cameraPosition = CameraPosition(
        target: location,
        zoom: 12.0,
      );
    } catch (_) {}

    // Don't rebuild inside of the first fetch because if the fetch returns early,
    // for whatever reason, the map won't ever load
    await fetchMarkers(
      cameraPosition.target,
      shouldRebuildMarkers: false,
      notify: false,
    );
    await rebuildMarkers(notify: false);

    _loaded = true;
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchMarkers(
    LatLng searchPoint, {
    bool shouldRebuildMarkers = true,
    bool notify = true,
  }) async {
    if (!maps_api.isApiEnabled) return;

    while (isSearching) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!Place.shouldFetchPlaces(searchPoint)) return;

    _isSearching = true;
    if (notify) notifyListeners();

    await Place.fetchPlaces(searchPoint, checkIfShouldSearch: false);
    if (shouldRebuildMarkers) await rebuildMarkers(notify: false);

    _isSearching = false;
    if (notify) notifyListeners();
  }

  Future<void> rebuildMarkers({
    bool notify = true,
  }) async {
    Set<Marker> newMarkers = Place.getPlaceMarkers(
      mask: placeMask,
      onlyVerified: onlyVerified,
      onTap: (place) {
        _selectedPlace = place;
        notifyListeners();
      },
    ).toSet();

    markers = newMarkers;
    if (notify) notifyListeners();
  }
}

class Map extends StatefulWidget {
  const Map({super.key, this.controller, this.onPlaceSelected});

  final MapController? controller;
  final void Function(Place)? onPlaceSelected;

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  MapController? _fallbackController;
  MapController get controller =>
      widget.controller ?? (_fallbackController ??= MapController());

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (!controller.loaded) return Container();

        return GoogleMap(
          markers: controller.markers,
          mapType: MapType.normal,
          myLocationEnabled: true,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          tiltGesturesEnabled: false,
          initialCameraPosition: controller.cameraPosition,
          minMaxZoomPreference: const MinMaxZoomPreference(10.0, 20.0),
          onMapCreated: (GoogleMapController googleMapController) {
            controller.googleMapController = googleMapController;
            controller.googleMapController!.setMapStyle(globals.mapStyle);
          },
          onCameraMove: (pos) {
            controller.cameraPosition = pos;
          },
        );
      },
    );
  }
}
