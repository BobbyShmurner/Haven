import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

enum MarkerIcons { foodBank, homelessShelter }

Marker createMarker(String id, LatLng position,
    {MarkerIcons? icon, InfoWindow? info}) {
  return Marker(
    markerId: MarkerId(id),
    position: position,
    icon: icon != null ? icon.icon : BitmapDescriptor.defaultMarker,
    infoWindow: info ?? InfoWindow.noText,
  );
}

extension MarkersExtension on MarkerIcons {
  static final Map<MarkerIcons, BitmapDescriptor> _bitmaps =
      <MarkerIcons, BitmapDescriptor>{};

  static Future<void> init() async {
    _createBitmapFromDefault(MarkerIcons.foodBank, BitmapDescriptor.hueOrange);
    _createBitmapFromDefault(
        MarkerIcons.homelessShelter, BitmapDescriptor.hueBlue);
  }

  static Future<void> _createBitmap(
      MarkerIcons marker, String assetName) async {
    // TODO: Figure out why the image isnt scaling
    _bitmaps[marker] = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(0.1, 0.1), devicePixelRatio: 0.1),
        assetName,
        bundle: rootBundle);
  }

  static void _createBitmapFromDefault(MarkerIcons marker, double hue) {
    _bitmaps[marker] = BitmapDescriptor.defaultMarkerWithHue(hue);
  }

  BitmapDescriptor get icon {
    return _bitmaps[this]!;
  }
}
