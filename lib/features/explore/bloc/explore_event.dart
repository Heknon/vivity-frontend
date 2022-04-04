part of 'explore_bloc.dart';

@immutable
abstract class ExploreEvent {}

class ExploreControllerUpdateEvent extends ExploreEvent {
  final MapControllerImpl controller;
  final String token;

  ExploreControllerUpdateEvent(this.controller, this.token);
}

class ExploreUpdateEvent extends ExploreEvent {

}

class ExploreMovementEvent extends ExploreEvent {

}

class ExploreUnload extends ExploreEvent {}
