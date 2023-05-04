import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:math' as math;

extension LatLngExtensions on LatLng {
  static LatLng fromGeometryJson(Map<String, dynamic> geometryJson) {
    return LatLng(
      geometryJson['location']['lat'],
      geometryJson['location']['lng'],
    );
  }

  double dist(LatLng other) {
    // Convert from degrees to radians
    final latA = latitude * 0.0174533;
    final longA = longitude * 0.0174533;
    final latB = other.latitude * 0.0174533;
    final longB = other.longitude * 0.0174533;

    // Haversine Formula
    // 12742000 = Diameter of Earth
    return 12742000 *
        (math.sin(
              math.sqrt(
                math.pow(
                      math.sin(
                        (latB - latA) * 0.5,
                      ),
                      2,
                    ) +
                    math.cos(latA) *
                        math.cos(latB) *
                        math.pow(
                          math.sin(
                            (longB - longA) * 0.5,
                          ),
                          2,
                        ),
              ),
            ) /
            1);
  }

  LatLng offset(double deltaLat, double deltaLng) {
    // 57.2957795 = 180 / Pi
    // 6371000 = Earths radius
    // 0.0174533 = Radians per Degree

    return LatLng(
      latitude + (deltaLat / 6371000) * 57.2957795,
      longitude +
          (deltaLng / 6371000) * 57.2957795 / math.cos(latitude * 0.0174533),
    );
  }
}
