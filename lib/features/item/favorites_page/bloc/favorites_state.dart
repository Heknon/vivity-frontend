part of 'favorites_bloc.dart';

@immutable
abstract class FavoritesState {}

class FavoritesUnloaded extends FavoritesState {}

class FavoritesLoading extends FavoritesUnloaded {}

class FavoritesLoaded extends FavoritesState {
  final List<ItemModel> favoritedItems;

  FavoritesLoaded(this.favoritedItems);
}
