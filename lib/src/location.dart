import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

extension PositionExtensions on Position {
  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }
}

extension LatLngExtensions on LatLng {
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

Future<LatLng> getDeviceLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return (await Geolocator.getCurrentPosition()).toLatLng();
}
