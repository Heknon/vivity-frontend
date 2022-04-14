part of 'explore_bloc.dart';

@immutable
abstract class ExploreEvent {}

class ExploreSearchEvent extends ExploreEvent {
  final double radius;
  final LatLng location;

  ExploreSearchEvent({required this.radius, required this.location});
}

class ExploreUnload extends ExploreEvent {}
class ExploreLoad extends ExploreEvent {}
