part of 'map_bloc.dart';

@immutable
abstract class MapEvent {}

class MapBoundsModifiedEvent extends MapEvent {
  final LatLngBounds bounds;

  MapBoundsModifiedEvent(this.bounds);
}

class MapLocationModifiedEvent extends MapEvent {
  final LatLng location;

  MapLocationModifiedEvent(this.location);
}

class MapRefreshLocationEvent extends MapEvent {
  final bool disturbed;
  final LatLng? defaultLocation;

  MapRefreshLocationEvent(this.defaultLocation, {this.disturbed = false});
}

class MapWidgetAddEvent extends MapEvent {
  final Iterable<MapWidget> widgets;

  MapWidgetAddEvent(this.widgets);
}

class MapWidgetRemoveEvent extends MapEvent {
  final Iterable<LatLng> positions;

  MapWidgetRemoveEvent(this.positions);
}
