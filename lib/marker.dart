import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

enum MarkerIcons { testMarker }

extension MarkersExtension on MarkerIcons {
  static final Map<MarkerIcons, BitmapDescriptor> _bitmaps =
      <MarkerIcons, BitmapDescriptor>{};

  static Future<void> init() async {
    await _createBitmap(MarkerIcons.testMarker, "images/test_marker.png");
  }

  static Future<void> _createBitmap(
      MarkerIcons marker, String assetName) async {
    // TODO: Figure out why the image isnt scaling
    _bitmaps[marker] = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(0.1, 0.1), devicePixelRatio: 0.1),
        assetName,
        bundle: rootBundle);
  }

  BitmapDescriptor get icon {
    return _bitmaps[this]!;
  }
}
