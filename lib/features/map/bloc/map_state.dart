part of 'map_bloc.dart';

@immutable
abstract class MapState {}

class MapInitial extends MapState {}

class MapDisturbedLoadingState extends MapState {}

class MapWidgetedState extends MapState {
  final Set<MapWidget> widgets;

  MapWidgetedState(this.widgets);

  MapWidgetedState copyWith({
    Set<MapWidget>? widgets,
  }) {
    return MapWidgetedState(
      widgets ?? this.widgets,
    );
  }
}

class MapLoadingState extends MapWidgetedState {
  final LatLng? location;
  final LatLngBounds? bounds;

  MapLoadingState(this.location, this.bounds, widgets) : super(widgets);

  factory MapLoadingState.fromLoaded(MapLoadedState state) {
    return MapLoadingState(state.location, state.bounds, state.widgets);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapLoadingState &&
          runtimeType == other.runtimeType &&
          location == other.location &&
          bounds == other.bounds &&
          setEquals(widgets, other.widgets);

  @override
  int get hashCode => location.hashCode ^ bounds.hashCode ^ widgets.hashCode;

  @override
  MapLoadedState copyWith({
    LatLng? location,
    LatLngBounds? bounds,
    Set<MapWidget>? widgets,
  }) {
    return MapLoadedState(
      location ?? this.location,
      bounds ?? this.bounds,
      widgets ?? this.widgets,
    );
  }
}

class MapLoadedState extends MapWidgetedState {
  final LatLng? location;
  final LatLngBounds? bounds;

  MapLoadedState(this.location, this.bounds, widgets) : super(widgets);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapLoadedState &&
          runtimeType == other.runtimeType &&
          location == other.location &&
          bounds == other.bounds &&
          setEquals(widgets, other.widgets);

  @override
  int get hashCode => location.hashCode ^ bounds.hashCode ^ widgets.hashCode;

  @override
  MapLoadedState copyWith({
    LatLng? location,
    LatLngBounds? bounds,
    Set<MapWidget>? widgets,
  }) {
    return MapLoadedState(
      location ?? this.location,
      bounds ?? this.bounds,
      widgets ?? this.widgets,
    );
  }
}
