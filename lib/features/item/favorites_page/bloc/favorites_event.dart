part of 'favorites_bloc.dart';

@immutable
abstract class FavoritesEvent {}

class FavoritesLoadEvent extends FavoritesEvent {}

class FavoritesUnfavoriteItemEvent extends FavoritesEvent {
  final ItemModel item;

  FavoritesUnfavoriteItemEvent(this.item);
}

class FavoritesFavoriteItemEvent extends FavoritesEvent {
  final ItemModel item;

  FavoritesFavoriteItemEvent(this.item);
}
