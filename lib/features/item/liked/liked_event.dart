part of 'liked_bloc.dart';

@immutable
abstract class LikedEvent {}

class LikedLoadEvent extends LikedEvent {}

class LikedAddItemEvent extends LikedEvent {
  final String itemId;

  LikedAddItemEvent(this.itemId);
}

class LikedRemoveItemEvent extends LikedEvent {
  final String itemId;

  LikedRemoveItemEvent(this.itemId);
}
