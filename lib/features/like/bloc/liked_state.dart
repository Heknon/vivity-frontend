part of 'liked_bloc.dart';

@immutable
abstract class LikedState {}

class LikedUnloaded extends LikedState {}

class LikedLoaded extends LikedState {
  final Set<String> likedItems;

  LikedLoaded(this.likedItems);
}
