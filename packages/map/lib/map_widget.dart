import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

class MapWidget {
  const MapWidget({required this.location, required this.child, this.size = const Size(30, 30)});

  final LatLng location;
  final Widget child;
  final Size size;

  @override
  int get hashCode => location.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! MapWidget) {
      return false;
    }

    return location == other.location;
  }
}