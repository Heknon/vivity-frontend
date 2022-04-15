import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/user/models/user.dart';
import 'package:vivity/features/user/repo/user_repository.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final UserRepository _userRepository = UserRepository();

  FavoritesBloc() : super(FavoritesUnloaded()) {
    on<FavoritesLoadEvent>((event, emit) async {
      emit(FavoritesLoading());
      List<ItemModel> likedItems = (await _userRepository.getUser()).likedItems;
      emit(FavoritesLoaded(likedItems));
    });

    on<FavoritesFavoriteItemEvent>((event, emit) async {
      User user = await _userRepository.addLikedItem(likedItemId: event.item.id.hexString);
      List<ItemModel> likedItems = user.likedItems;
      emit(FavoritesLoaded(likedItems));
    });

    on<FavoritesUnfavoriteItemEvent>((event, emit) async {
      User user = await _userRepository.removeLikedItem(likedItemId: event.item.id.hexString);
      List<ItemModel> likedItems = user.likedItems;
      emit(FavoritesLoaded(likedItems));
    });
  }
}
