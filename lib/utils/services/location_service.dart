import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:vivity/constants/app_constants.dart';
import 'package:latlong2/latlong.dart';

Future<LatLng> getPosition({bool getCountryIfFail = true, LatLng? defaultLocation}) async {
  bool serviceEnabled;
  LocationPermission permission;

  try {
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are disabled.");
    }
  } catch (e) {
    LatLng? result = await getCountry(defaultLocation: defaultLocation);
    if (result == null) {
      return Future.error("Failed to get country.");
    }

    return result;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.deniedForever) {
    if (getCountryIfFail) {
      LatLng? result = await getCountry(defaultLocation: defaultLocation);
      if (result == null) {
        return Future.error("Failed to get country.");
      }
      return result;
    }

    return Future.error("Location permission are permanently denied. Cannot request permissions.");
  }

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      if (getCountryIfFail) {
        LatLng? result = await getCountry(defaultLocation: defaultLocation);
        if (result == null) {
          return Future.error("Location permissions are denied.");
        }
        return result;
      }

      return Future.error("Location permissions are denied.");
    }
  }

  Position position = await Geolocator.getCurrentPosition();
  return LatLng(position.latitude, position.longitude);
}

Future<LatLng?> getCountry({LatLng? defaultLocation}) async {
  try {
    http.Response res = await http.get(Uri.parse(ipApiPath));
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