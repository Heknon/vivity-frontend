part of 'explore_bloc.dart';

@immutable
abstract class ExploreEvent {}

class ExploreMapMovementEvent extends ExploreEvent {
  final LatLng center;
  final LatLngBounds bounds;
  final String? token;

  ExploreMapMovementEvent(this.center, this.bounds, this.token);
}

class ExploreMapRegisteredMovementEvent extends ExploreEvent {
  final LatLng? center;
  final LatLngBounds? bounds;

  ExploreMapRegisteredMovementEvent({this.center, this.bounds});
}
