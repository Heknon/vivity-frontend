import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlng/latlng.dart';

class LocationService {
  static final LocationService? _locationService = LocationService._internal();
  static final String _countryApiPath = 'http://ip-api.com/json';

  factory LocationService() {
    return _locationService!;
  }

  LocationService._internal();

  Future<Stream<Position>> getLocationUpdateStream({bool getCountryIfFail = true, LatLng? defaultLocation}) async {
    String? hasPermission = await getLocationPermission();
    if (hasPermission != null) {
      if (getCountryIfFail) {
        LatLng? result = await getCountry(defaultLocation: defaultLocation);
        if (result == null) {
          return Future.error("Failed to get country.");
        }
        return Future.error(result);
      } else {
        return Future.error(hasPermission);
      }
    }

    return Geolocator.getPositionStream(
        locationSettings: LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 10,
      timeLimit: Duration(seconds: 1),
    ));
  }

  Future<LatLng> getPosition({bool getCountryIfFail = true, LatLng? defaultLocation}) async {
    String? hasPermission = await getLocationPermission();
    if (hasPermission != null) {
      if (getCountryIfFail) {
        LatLng? result = await getCountry(defaultLocation: defaultLocation);
        if (result == null) {
          return Future.error("Failed to get country.");
        }
        return result;
      } else {
        return Future.error(hasPermission);
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  /// if result is null permission getting was success, otherwise, string is error message
  Future<String?> getLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return "Location services are disabled.";
      }
    } catch (e) {
      return 'Failed to get location';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return "Location permission are permanently denied. Cannot request permissions.";
    } else if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return 'Location permission denied.';
      }
    }

    return null;
  }

  Future<LatLng?> getCountry({LatLng? defaultLocation}) async {
    try {
      http.Response res = await http.get(Uri.parse(_countryApiPath));
      if (res.statusCode == 200) {
        dynamic parsed = json.decode(res.body);
        return LatLng(parsed["lat"], parsed["lon"]);
      } else {
        return defaultLocation;
      }
    } catch (e) {
      return defaultLocation;
    }
  }
}
